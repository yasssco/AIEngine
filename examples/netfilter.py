#!/usr/bin/env python

""" Example for integrate aiengine with netfilterqueue module """

__author__ = "Luis Campo Giralte"
__copyright__ = "Copyright (C) 2013-2017 by Luis Campo Giralte"
__revision__ = "$Id$"
__version__ = "0.1"

from netfilterqueue import NetfilterQueue
import sys
import os
sys.path.append("../src/")
import pyaiengine

""" Need a fake ethernet header """
ethernet_header = "\xbe\xef\x00\x00\x00\x01\xbe\xef\x00\x00\x00\x02\x08\x00"

pdis = pyaiengine.PacketDispatcher()

def netfilter_callback(packet):

    payload = ethernet_header + packet.get_payload()
    length = packet.get_payload_len() + 14

    """ Use the forwardPacket method from the PacketDispatcher object
    in order to forward the packets from netfilter """
    pdis.forward_packet(payload,length)

    if (pdis.is_packet_accepted):
          packet.accept()
    else:
          packet.drop()


if __name__ == '__main__':

    # Load an instance of a Network Stack
    st = pyaiengine.StackLan()

    # Plug the stack on the PacketDispatcher
    pdis.stack = st

    st.tcp_flows = 327680
    st.udp_flows = 163840

    """ Create a NetfilterQueue object """
    nfqueue = NetfilterQueue()

    """ Sets the callback for netfilter """
    nfqueue.bind(1, netfilter_callback)
    try:
        nfqueue.run()
    except KeyboardInterrupt:
        print("Exit netfilter queue")

    # Dump on file the statistics of the stack
    st.stats_level = 5
    f = open("statistics.log","w")
    f.write(str(st))
    f.close()

    sys.exit(0)

