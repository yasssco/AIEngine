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
#include <string>
#include "Protocol.h"
#include "Multiplexer.h"
#include "EthernetProtocol.h"

#define BOOST_TEST_DYN_LINK
#ifdef STAND_ALONE_TEST
#define BOOST_TEST_MODULE ethernettest
#endif
#include <boost/test/unit_test.hpp>

using namespace aiengine;

BOOST_AUTO_TEST_SUITE (test_suite_ethernet)

BOOST_AUTO_TEST_CASE (test01)
{
	EthernetProtocolPtr eth = EthernetProtocolPtr(new EthernetProtocol());

	BOOST_CHECK(eth->getTotalPackets() == 0);

	eth->processFlow(nullptr); // nothing to do

	CounterMap c = eth->getCounters();
}

BOOST_AUTO_TEST_CASE (test02)
{
        EthernetProtocolPtr eth = EthernetProtocolPtr(new EthernetProtocol());
        MultiplexerPtr mux = MultiplexerPtr(new Multiplexer());
	char *raw_packet = "\x00\x05\x47\x02\xa2\x5d\x00\x15\xc7\xee\x25\x98\x08\x00\x02\x5e\x08\x00";
        uint8_t *packet = reinterpret_cast <uint8_t*> (raw_packet);
        int length = 64;

	Packet pkt(packet,length,0);

        eth->setMultiplexer(mux);
	mux->setProtocol(static_cast<ProtocolPtr>(eth));
	mux->addChecker(std::bind(&EthernetProtocol::ethernetChecker,eth,std::placeholders::_1));

	pkt.setPayloadLength(10);
	BOOST_CHECK(eth->ethernetChecker(pkt) == false);
	BOOST_CHECK(mux->acceptPacket(pkt) == false);
	
	pkt.setPayloadLength(length);
	BOOST_CHECK(eth->ethernetChecker(pkt) == true);
	BOOST_CHECK(mux->acceptPacket(pkt) == true);

	BOOST_CHECK(eth->getEthernetType() == ETHERTYPE_IP);

	// The check is two packets because there is
	// two calls to the same function
	BOOST_CHECK(eth->getTotalValidPackets() == 2);
	BOOST_CHECK(eth->getTotalInvalidPackets() == 2);
}

BOOST_AUTO_TEST_SUITE_END( )
