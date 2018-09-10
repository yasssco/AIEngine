/*
 * AIEngine a new generation network intrusion detection system.
 *
 * Copyright (C) 2013-2018  Luis Campo Giralte
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Ryadnology Team; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Ryadnology Team, 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 *
 * Written by Luis Campo Giralte <me@ryadpasha.com> 
 *
 */
#include "FlowManager.h"
#include "FlowForwarder.h"
#include <iomanip> // setw
#include <netinet/in.h>
#include <arpa/inet.h>
#include <boost/format.hpp>

// http://lynxline.com/about-boost-multi-index-containers/

namespace aiengine {

FlowManager::FlowManager(const std::string &name):
	name_(name),
	now_({0, 0}),
	total_process_flows_(0),
	total_timeout_flows_(0),
	timeout_(flowTimeout),
	release_flows_(true),
	flowTable_(),
	flow_it_(),
	flow_cache_(),
	tcp_info_cache_(),
	protocol_(),
	lookup_flow_() {}

FlowManager::~FlowManager() {

	flowTable_.clear();
}

void FlowManager::addFlow(const SharedPointer<Flow> &flow) {

#ifdef DEBUG
	std::cout << __FILE__ << "(" << this << "):" << __func__ << ":flow:" << flow << " total flows:" << flowTable_.size() << std::endl;
#endif
	++total_process_flows_;
	flowTable_.insert(flow);
}

void FlowManager::removeFlow(const SharedPointer<Flow> &flow) {
	
#ifdef DEBUG
	std::cout << __FILE__ << "(" << this << "):" << __func__ << ":flow:" << flow << " total flows:" << flowTable_.size() << std::endl;
#endif
	FlowByID::iterator it = flowTable_.get<flow_table_tag_unique>().find(flow->getId());
	
	flowTable_.erase(it);
}

SharedPointer<Flow>& FlowManager::findFlow(unsigned long hash1, unsigned long hash2) {

#ifdef DEBUG
	std::cout << __FILE__ << "(" << this << "):" << __func__ << " total flows:" << flowTable_.size() << std::endl;
#endif
	flow_it_ = flowTable_.get<flow_table_tag_unique>().find(hash1);
	lookup_flow_.reset();

	if (flow_it_ == flowTable_.end()) {
		flow_it_ = flowTable_.get<flow_table_tag_unique>().find(hash2);
		if (flow_it_ == flowTable_.end()) { 
			return lookup_flow_;
		}
	}

	lookup_flow_ = (*flow_it_);
	return lookup_flow_;
}

#if defined(STAND_ALONE_TEST)
void FlowManager::showFlowsByTime() {

	auto begin = flowTable_.get<flow_table_tag_duration>().begin();
	auto end = flowTable_.get<flow_table_tag_duration>().end();

	for (auto it = begin ; it != end; ++it) {
		SharedPointer<Flow> flow = (*it);

      		std::cout << __FILE__ << ":" << __func__ << ":Checking: " << *flow.get() <<  " lastPacketTime:" << flow->getLastPacketTime() << std::endl;
	}
}

#endif

void FlowManager::updateFlowTime(const SharedPointer<Flow> &flow, time_t time) {

	auto &finxd = flowTable_.get<flow_table_tag_duration>();
	auto &finxu = flowTable_.get<flow_table_tag_unique>();

	FlowByID::const_iterator it = finxu.find(flow->getId());

	FlowByDuration::const_iterator itd = flowTable_.project<flow_table_tag_duration>(it);
	finxd.modify(itd, Flow::updateTime(time));	
}

void FlowManager::release_flow(const SharedPointer<Flow> &flow) {

	// Release to their corresponding caches the attached objects
	auto ff = flow->forwarder.lock();

	if (ff) {
		ProtocolPtr l7proto = ff->getProtocol();
		if (l7proto)
			l7proto->releaseFlowInfo(flow.get());
	}

	if (flow_cache_) 
		flow_cache_->releaseFlow(flow);
}

void FlowManager::updateTimers(std::time_t current_time) {

	auto &finx = flowTable_.get<flow_table_tag_duration>();

#if defined(RUBY_BINDING)
	std::list<SharedPointer<Flow>> flow_list;
#endif
	int expire_flows = 0;

#ifdef DEBUG
	char mbstr[64];
        std::strftime(mbstr, 64, "%D %X", std::localtime(&current_time));

        std::cout << __FILE__ << ":" << __func__ << ":Checking Timers at " << mbstr << " total flows:" << flowTable_.size() << std::endl;
#endif

	// We check the iterator backwards because the old flows will be at the end
	for (auto it = flowTable_.get<flow_table_tag_duration>().begin() ; it != flowTable_.get<flow_table_tag_duration>().end(); ) {
		SharedPointer<Flow> flow = (*it);

#ifdef DEBUG
      		std::cout << __FILE__ << ":" << __func__ << ":Checking: " << *flow.get() <<  " lastPacketTime:" << flow->getLastPacketTime();
		std::cout << " timeout:" << timeout_ << " currentTime:" << current_time;
		std::cout << " [ " << flow->getLastPacketTime() << " + " << timeout_ << " <= " << current_time << " ]" << std::endl; 
#endif
		if (flow->getLastPacketTime() + timeout_ <= current_time ) {
			Flow *tmpflow = flow.get();
			++expire_flows;
			++total_timeout_flows_;
#ifdef DEBUG
        		std::cout << __FILE__ << ":" << __func__ << ":Flow Expires: " << *flow.get() <<  " total on table:" << flowTable_.size()  <<std::endl;
#endif

			
#if (defined(PYTHON_BINDING) || defined(JAVA_BINDING) || defined(LUA_BINDING) || defined(GO_BINDING))

                        if (!protocol_.expired()) {
                                ProtocolPtr proto = protocol_.lock();

                                if (proto->getDatabaseObjectIsSet()) {
                                        proto->databaseAdaptorRemoveHandler(tmpflow);
                                }
                        }
#endif

			if (release_flows_) { // Release the flows 
				// Remove the flow from the multiindex
				it = finx.erase(it);
#ifdef DEBUG
        			std::cout << __FILE__ << ":" << __func__ << ":Flow Expires: " << *flow.get() <<  " releasing from the multi_index" <<std::endl;
#endif
		
#if defined(RUBY_BINDING)
				flow_list.push_front(flow);
#else
				release_flow(flow);
#endif
			} else { // The flow will be in memory all the time
				++it;
			}
		} else {
			// the multiset is ordered and there is no need to check more flows
			break;
		}
	} 

#if defined(RUBY_BINDING)

	// We put the flows that are gonna be remove on a list in order to prevent
	// problems with the ruby threads generated by the rb_funcall method.
	// There is an extra cost on the creation and manage of the std::list that with the other
	// compilations dont have it.

	for (auto f: flow_list) {
        	if (!protocol_.expired()) {
                	ProtocolPtr proto = protocol_.lock();

                        if (proto->getDatabaseObjectIsSet()) {
                        	proto->databaseAdaptorRemoveHandler(f.get());
                        }
		}
		release_flow(f);
	}

#endif

#ifdef DEBUG
        std::cout << __FILE__ << ":" << __func__ << ":Total expire flows " << expire_flows << " on table:" << flowTable_.size() << std::endl;
#endif
	return;
}

void FlowManager::flush() {

	auto &finx = flowTable_.get<flow_table_tag_duration>();

	for (auto it = flowTable_.get<flow_table_tag_duration>().begin() ; it != flowTable_.get<flow_table_tag_duration>().end(); ) {
		SharedPointer<Flow> flow = (*it);

		// Remove the flow from the multiindex
		it = finx.erase(it);

		release_flow(flow);
	}
}

std::ostream& operator<< (std::ostream &out, const FlowManager &fm) {

        const char *units[] = { "KBytes", "MBytes", "GBytes" };
        const char *unit = "Bytes";
        int memory = fm.getAllocatedMemory(); 

        for(auto i: units) {
        	if (memory > 1024) {
                	unit = i;
                        memory = memory / 1024;
                } else {
                	break;
                }
        }
        out << fm.name_ << " statistics" << "\n";
	out << "\t" << "Timeout:                " << std::setw(10) << fm.timeout_ << "\n";
	out << "\t" << "Total allocated:        " << std::setw(9 - std::strlen(unit)) << memory << " " << unit << "\n";
        out << "\t" << "Total process flows:    " << std::setw(10) << fm.total_process_flows_ << "\n";
        out << "\t" << "Total flows:            " << std::setw(10) << fm.flowTable_.size() << "\n";
        out << "\t" << "Total timeout flows:    " << std::setw(10) << fm.total_timeout_flows_ << std::endl;
	return out;
}


void FlowManager::print_pretty_flow(std::basic_ostream<char> &out, const Flow &flow, const char *proto_name) {

	std::ostringstream fivetuple;

	fivetuple << "[" << flow.getSrcAddrDotNotation() << ":" << flow.getSourcePort() << "]:" << flow.getProtocol();
	fivetuple << ":[" << flow.getDstAddrDotNotation() << ":" << flow.getDestinationPort() <<"]";

	out << boost::format("%-64s %-10d %-10d %-18s") % fivetuple.str() % flow.total_bytes % flow.total_packets % proto_name;

	flow.showFlowInfo(out);
}


void FlowManager::showFlows(int limit) {

	showFlows(OutputManager::getInstance()->out(), limit);
}

void FlowManager::showFlows(const std::string &protoname, int limit) { 

	showFlows(OutputManager::getInstance()->out(), protoname, limit); 
}

void FlowManager::showFlows(std::basic_ostream<char> &out, int limit) {

	int current_limit = 0;

	show_flows(out, [&] (const Flow &f) { 
		if (current_limit < limit) {
			++current_limit;		
			return true; 
		}
		return false;
	});
}

void FlowManager::showFlows(std::basic_ostream<char> &out, const std::string &protoname, 
	int limit ) {

	int current_limit = 0;

	show_flows(out, [&] (const Flow &f) {
		if (!f.forwarder.expired()) {
			SharedPointer<FlowForwarder> ff = f.forwarder.lock();	
			ProtocolPtr proto = ff->getProtocol();
			const char *name = proto->getName();
			const char *short_name = proto->getShortName();

			if ((protoname.compare(name) == 0)or(protoname.compare(short_name) == 0)) {
				if (current_limit < limit) {
					++current_limit;
					return true;
				}
			}
		}
		return false; 
	});
}
	
void FlowManager::show_flows(std::basic_ostream<char> &out, std::function<bool (const Flow&)> condition) {

	out << std::endl;
	out << boost::format("%-64s %-10s %-10s %-18s %-12s") % "Flow" % "Bytes" % "Packets" % "FlowForwarder" % "Info";
	out << std::endl;	

	int total_display = 0;

	FlowByDuration::reverse_iterator begin = flowTable_.get<flow_table_tag_duration>().rbegin();
	FlowByDuration::reverse_iterator end = flowTable_.get<flow_table_tag_duration>().rend();

	// The flows are sorted by most recent activity, so the actives will be first
	// and the ones with low activity will be the last to show
	for (auto it = begin ; it != end; ++it ) {
		SharedPointer<Flow> flow = (*it);	
		const Flow& cflow = *flow.get();

		if (condition(cflow)) {
			const char *proto_name = "None";
			if (!flow->forwarder.expired()) {
				// Some flows could be not attached to a Protocol, for example syn packets, syn/ack packets and so on
				SharedPointer<FlowForwarder> ff = flow->forwarder.lock();	
				ProtocolPtr proto = ff->getProtocol();
				proto_name = proto->getName();
			}
			++total_display;
			print_pretty_flow(out, cflow, proto_name);	
			out << '\n';
		}
	}
	out << "Total " << total_display << std::endl;
}

} // namespace aiengine 
