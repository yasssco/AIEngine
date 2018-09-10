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
#include "Multiplexer.h"
#include <iomanip> // setw

namespace aiengine {

Multiplexer::Multiplexer():
	address(),
	total_length(0),
	proto_(),
	packet_(),
	total_received_packets_(0),
	total_forward_packets_(0),
	total_fail_packets_(0),
	header_size_(0),
	offset_(0),
	protocol_id_(NO_PROTOCOL_SELECTED),
	next_protocol_id_(NO_PROTOCOL_SELECTED),
	muxUpMap_(),
	check_func_([&] (Packet&) { return true; }),
	packet_func_([&] (Packet&) { return true; })
	{}

MultiplexerPtrWeak Multiplexer::getDownMultiplexer() const { 

	return muxDown_;
}

MultiplexerPtrWeak Multiplexer::getUpMultiplexer(int key) const { 

	MuxMap::const_iterator it = muxUpMap_.find(key);
	MultiplexerPtrWeak mp;

	if (it != muxUpMap_.end())
		mp = it->second;
	
	return mp;
} 

void Multiplexer::setPacketInfo(const uint8_t *packet, int length, int prev_header_size,PacketAnomalyType pa,std::time_t packet_time) { 

	packet_.setPayload(packet);
	packet_.setPayloadLength(length);
	packet_.setPrevHeaderSize(prev_header_size);
	packet_.setPacketAnomaly(pa);
	packet_.setPacketTime(packet_time);
}

void Multiplexer::setPacket(Packet *pkt) {

	setPacketInfo(pkt->getPayload(), pkt->getLength(), pkt->getPrevHeaderSize(), pkt->getPacketAnomaly(), pkt->getPacketTime());
}

void Multiplexer::forwardPacket(Packet &packet) {

	MultiplexerPtrWeak next_mux;

#ifdef DEBUG
	std::cout << __FILE__ << "(" << this << "):forwardPacket,next proto:"<< next_protocol_id_ <<std::endl;
#endif
        ++total_received_packets_;
	next_mux = getUpMultiplexer(next_protocol_id_);
	if (!next_mux.expired()) {
		MultiplexerPtr mux = next_mux.lock();
                Packet pkt_candidate(packet); 

		// Modify just the packet payload and the length of it
		pkt_candidate.setPayload(&packet.getPayload()[header_size_]);
		pkt_candidate.setPayloadLength(packet.getLength() - header_size_);

		if (mux->acceptPacket(pkt_candidate)) { // The packet is accepted by the destination mux
    			if (mux->packet_func_(pkt_candidate)) { // Forward the packet to upper layers
                       		++total_forward_packets_;
                       		mux->forwardPacket(pkt_candidate);
	
				// Verify if the packet have been label for write on disk	
				if (pkt_candidate.haveEvidence()) {
					packet.setEvidence(pkt_candidate.haveEvidence());
				}
			}
#ifdef DEBUG
		} else {
			std::cout << "WARNING: PACKET NO ACCEPTED by Multiplexer(" << this <<")" << std::endl;
			std::cout << pkt_candidate;
#endif
		}
        } else {
                ++total_fail_packets_;
        }
}


void Multiplexer::statistics(std::basic_ostream<char> &out) {

      	out << "Multiplexer(" << this << ") statistics" << "\n";
	out << "\t" << "Plugged to object("<< proto_ << ")" <<  "\n";
        out << "\t" << "Total forward packets:  " << std::setw(10) << total_forward_packets_ << "\n";
        out << "\t" << "Total received packets: " << std::setw(10) << total_received_packets_ << "\n";
        out << "\t" << "Total fail packets:     " << std::setw(10) << total_fail_packets_ << std::endl;
}

} // namespace aiengine
