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
#ifndef _TEST_SNMP_H_
#define _TEST_SNMP_H_

#include <string>
#include <cstring>
#include "Protocol.h"
#include "StackTest.h"
#include "../ip/IPProtocol.h"
#include "../icmp/ICMPProtocol.h"
#include "../udp/UDPProtocol.h"
#include "SNMPProtocol.h"

using namespace aiengine;

struct StackSNMPtest : public StackTest
{
        //Protocols
        IPProtocolPtr ip;
        UDPProtocolPtr udp;
        SNMPProtocolPtr snmp;

        // Multiplexers
        MultiplexerPtr mux_ip;
        MultiplexerPtr mux_udp;

        // FlowManager and FlowCache
        FlowManagerPtr flow_mng;
        FlowCachePtr flow_cache;

        // FlowForwarders
        SharedPointer<FlowForwarder> ff_udp, ff_snmp;

        StackSNMPtest()
        {
                // Allocate all the Protocol objects
                udp = UDPProtocolPtr(new UDPProtocol());
                ip = IPProtocolPtr(new IPProtocol());
                snmp = SNMPProtocolPtr(new SNMPProtocol());

                // Allocate the Multiplexers
                mux_ip = MultiplexerPtr(new Multiplexer());
                mux_udp = MultiplexerPtr(new Multiplexer());

                // Allocate the flow caches and tables
                flow_mng = FlowManagerPtr(new FlowManager());
                flow_cache = FlowCachePtr(new FlowCache());

                ff_udp = SharedPointer<FlowForwarder>(new FlowForwarder());
                ff_snmp = SharedPointer<FlowForwarder>(new FlowForwarder());

                // configure the ip
                ip->setMultiplexer(mux_ip);
                mux_ip->setProtocol(static_cast<ProtocolPtr>(ip));
                mux_ip->setProtocolIdentifier(ETHERTYPE_IP);
                mux_ip->setHeaderSize(ip->getHeaderSize());
                mux_ip->addChecker(std::bind(&IPProtocol::ipChecker, ip, std::placeholders::_1));
                mux_ip->addPacketFunction(std::bind(&IPProtocol::processPacket, ip, std::placeholders::_1));

                //configure the udp
                udp->setMultiplexer(mux_udp);
                mux_udp->setProtocol(static_cast<ProtocolPtr>(udp));
                ff_udp->setProtocol(static_cast<ProtocolPtr>(udp));
                mux_udp->setProtocolIdentifier(IPPROTO_UDP);
                mux_udp->setHeaderSize(udp->getHeaderSize());
                mux_udp->addChecker(std::bind(&UDPProtocol::udpChecker, udp, std::placeholders::_1));
                mux_udp->addPacketFunction(std::bind(&UDPProtocol::processPacket, udp, std::placeholders::_1));

                // configure the snmp
                snmp->setFlowForwarder(ff_snmp);
                ff_snmp->setProtocol(static_cast<ProtocolPtr>(snmp));
                ff_snmp->addChecker(std::bind(&SNMPProtocol::snmpChecker, snmp, std::placeholders::_1));
                ff_snmp->addFlowFunction(std::bind(&SNMPProtocol::processFlow, snmp, std::placeholders::_1));

                // configure the multiplexers
                mux_eth->addUpMultiplexer(mux_ip, ETHERTYPE_IP);
                mux_ip->addDownMultiplexer(mux_eth);
                mux_ip->addUpMultiplexer(mux_udp, IPPROTO_UDP);
                mux_udp->addDownMultiplexer(mux_ip);

                // Connect the FlowManager and FlowCache
                flow_cache->createFlows(1);

                udp->setFlowCache(flow_cache);
                udp->setFlowManager(flow_mng);

                // Configure the FlowForwarders
                udp->setFlowForwarder(ff_udp);
		ff_udp->addUpFlowForwarder(ff_snmp);

		snmp->setAnomalyManager(anomaly);
        }

	void show() {
		udp->statistics(std::cout, 5);
		snmp->statistics(std::cout, 5);
	}

	void showFlows() {

		flow_mng->showFlows();
	}

        ~StackSNMPtest() {}
};

#endif
