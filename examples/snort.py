#!/usr/bin/env python

""" Example using snort rules and activating the shell for 
    interact with the engine on real time """

__author__ = "Luis Campo Giralte"
__copyright__ = "Copyright (C) 2013-2017 by Luis Campo Giralte"
__revision__ = "$Id$"
__version__ = "0.1"

import sys
import os
sys.path.append("../src/")
import pyaiengine

def callback(flow):

    r = flow.regex
    if(r):
        print("Detection of ", r.name, " on ",flow.src_ip) 


def parseSnortLine(line):
    data_raw = line.split("(msg:")[1]
    data_list = data_raw.split(";")
    name = data_list[0]
    pcre = None
    for item in data_list:
        t = item.lstrip()
        if (t.startswith("pcre:")):
            pcre = t.split(":")[1]

    return name,pcre

def loadRegexFromSnort():

    dm_tcp = pyaiengine.RegexManager()
    dm_udp = pyaiengine.RegexManager()

    # Parse the file with the snort rules
    f = open("community.rules","r")

    lines = f.readlines()
    for line in lines:
        if (line.startswith("#")):
            continue

        if (line.startswith("alert tcp")): 
            name,pcre = parseSnortLine(line)
            if (pcre != None):
                try:
                    r = pyaiengine.Regex(name,pcre)
                    r.callback = callback
                    dm_tcp.add_regex(r) 
                except:
                    print("Can not add %s %s" % (name, pcre))

        elif (line.startswith("alert udp")): 
            name,pcre = parseSnortLine(line)
            if (pcre != None):
                try:
                    r = pyaiengine.Regex(name,pcre)
                    r.callback = callback
                    dm_udp.add_regex(r) 
                except:
                    print("Can not add %s %s" % (name, pcre))

    f.close()
    return dm_tcp, dm_udp

if __name__ == '__main__':

     # Load an instance of a Network Stack 
     st = pyaiengine.StackLan()

     # Plug the stack on the PacketDispatcher
     pdis.stack = st

     r_tcp,r_udp = loadRegexFromSnort()

     st.tcp_flows = 327680
     st.udp_flows = 163840

     st.tcp_regex_manager = r_tcp
     st.udp_regex_manager = r_udp

     st.enable_nids_engine = True

     with pyaiengine.PacketDispatcher("eth0") as pd:
         pd.stack = st
         """ Enable the shell so the user can take under control
         the all system """
         pd.enable_shell = True
         pd.run()
     
     print(r_tcp)
     print(r_udp) 

     sys.exit(0)
