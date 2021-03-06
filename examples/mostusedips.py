#!/usr/bin/env python

""" Example for extract the most used DNS request of a network """

__author__ = "Luis Campo Giralte"
__copyright__ = "Copyright (C) 2013-2017 by Luis Campo Giralte"
__revision__ = "$Id$"
__version__ = "0.1"
import sys
import os
sys.path.append("../src/")
import pyaiengine

top_ips = dict()

def callback_host(flow):

    ip = flow.src_ip
    if(top_ips.has_key(ip)):
        top_ips[ip] += 1
    else:
        top_ips[ip] = 1

if __name__ == '__main__':

    # Load an instance of a Network Stack on Lan network
    st = pyaiengine.StackLan()

    dm = pyaiengine.DomainNameManager()

    dom = pyaiengine.DomainName("Service to analyze",
        "marca.com")
    dom.callback = callback_host
    dm.add_domain_name(dom)

    st.set_domain_name_manager(dm,"HTTPProtocol")

    st.tcp_flows = 327680
    st.udp_flows = 163840

    with pyaiengine.PacketDispatcher("eth0") as pd:
        # Plug the stack on the PacketDispatcher
        pd.stack = st
        pd.run()

    # Dump on file the statistics of the stack
    st.stats_level = 5
    f = open("statistics.log","w")
    f.write(str(st))
    f.close()
    
    print(top_ips)

    sys.exit(0)

