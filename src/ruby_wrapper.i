%module(directors="1") ruaiengine 
%include <std_string.i>

%{
#include <iostream>
#include "PacketDispatcher.h"
#include "regex/RegexManager.h"
#include "regex/Regex.h"
#include "ipset/IPSetManager.h"
#include "ipset/IPRadixTree.h"
#include "ipset/IPSet.h"
#include "NetworkStack.h"
#include "Flow.h"
#include "FlowInfo.h"
#include "StackLan.h"
#include "StackMobile.h"
#include "StackLanIPv6.h"
#include "StackVirtual.h"
#include "StackOpenFlow.h"
#include "StackMobileIPv6.h"
#include "names/DomainNameManager.h"
#include "names/DomainName.h"
#include "learner/LearnerEngine.h"
#ifdef HAVE_LIBLOG4CXX
#include "log4cxx/logger.h"
#include "log4cxx/basicconfigurator.h"

using namespace log4cxx;
using namespace log4cxx::helpers;
#endif

using namespace std;
%}

%apply SWIGTYPE *DISOWN { Signature* signature };
%apply SWIGTYPE *DISOWN { Regex* regex };
%apply SWIGTYPE *DISOWN { DomainName* domain };
%apply SWIGTYPE *DISOWN { IPSet* ipset };

%feature("director") DatabaseAdaptor;

%trackobjects;

%init %{ 
std::cout << "Ruby AIengine init." << std::endl;
#ifdef HAVE_LIBLOG4CXX  
        BasicConfigurator::configure();
#endif
%}

%ignore operator+;
%ignore operator[];
%ignore operator==;
%ignore operator!=;
%ignore operator/;

%ignore aiengine::free_list;

%ignore aiengine::JsonFlow;
%ignore aiengine::FlowInfo;
%ignore aiengine::FlowDirection;

%ignore aiengine::Frequencies; 
%ignore aiengine::PacketFrequencies;
%ignore aiengine::Callback::haveCallback;
%ignore aiengine::Callback::executeCallback;

%ignore aiengine::PACKET_RECVBUFSIZE;
%ignore PCAP_NETMASK_UNKNOWN;
%ignore aiengine::RegexNullDeleter;

%ignore aiengine::CacheManager;
%ignore aiengine::NetworkStack::setName;
%ignore aiengine::NetworkStack::setLinkLayerMultiplexer;
%ignore aiengine::NetworkStack::getLinkLayerMultiplexer;
%ignore aiengine::NetworkStack::enableFlowForwarders;
%ignore aiengine::NetworkStack::disableFlowForwarders;
%ignore aiengine::NetworkStack::setTCPRegexManager(const SharedPointer<RegexManager>& sig);
%ignore aiengine::NetworkStack::setUDPRegexManager(const SharedPointer<RegexManager>& sig);
%ignore aiengine::NetworkStack::setTCPIPSetManager(const SharedPointer<IPSetManager>& ipset_mng);
%ignore aiengine::NetworkStack::setUDPIPSetManager(const SharedPointer<IPSetManager>& ipset_mng);
%ignore aiengine::NetworkStack::addProtocol;
%ignore aiengine::NetworkStack::infoMessage;
%ignore aiengine::NetworkStack::setPacketDispatcher;
%ignore aiengine::NetworkStack::setDomainNameManager(const SharedPointer<DomainNameManager>& dnm, const std::string& name);
%ignore aiengine::NetworkStack::setDomainNameManager(const SharedPointer<DomainNameManager>& dnm, const std::string& name, bool allow);

%ignore aiengine::StackLan::setLinkLayerMultiplexer;
%ignore aiengine::StackLan::getLinkLayerMultiplexer;
%ignore aiengine::StackLan::getTCPRegexManager;
%ignore aiengine::StackLan::getUDPRegexManager;

%ignore aiengine::StackMobile::setLinkLayerMultiplexer;
%ignore aiengine::StackMobile::getLinkLayerMultiplexer;
%ignore aiengine::StackMobile::getTCPRegexManager;
%ignore aiengine::StackMobile::getUDPRegexManager;

%ignore aiengine::StackLanIPv6::setLinkLayerMultiplexer;
%ignore aiengine::StackLanIPv6::getLinkLayerMultiplexer;
%ignore aiengine::StackLanIPv6::getTCPRegexManager;
%ignore aiengine::StackLanIPv6::getUDPRegexManager;

%ignore aiengine::StackVirtual::setLinkLayerMultiplexer;
%ignore aiengine::StackVirtual::getLinkLayerMultiplexer;
%ignore aiengine::StackVirtual::getTCPRegexManager;
%ignore aiengine::StackVirtual::getUDPRegexManager;

%ignore aiengine::StackOpenFlow::setLinkLayerMultiplexer;
%ignore aiengine::StackOpenFlow::getLinkLayerMultiplexer;
%ignore aiengine::StackOpenFlow::getTCPRegexManager;
%ignore aiengine::StackOpenFlow::getUDPRegexManager;

%ignore aiengine::StackMobileIPv6::setLinkLayerMultiplexer;
%ignore aiengine::StackMobileIPv6::getLinkLayerMultiplexer;
%ignore aiengine::StackMobileIPv6::getTCPRegexManager;
%ignore aiengine::StackMobileIPv6::getUDPRegexManager;

%ignore aiengine::RegexManager::addRegex(const SharedPointer<Regex>& sig);
%ignore aiengine::RegexManager::removeRegex(const SharedPointer<Regex>& sig);
%ignore aiengine::RegexManager::getMatchedRegex;

%ignore aiengine::Signature::setName;
%ignore aiengine::Signature::setExpression;
%ignore aiengine::Signature::incrementMatchs;
%ignore aiengine::Signature::total_matchs_;
%ignore aiengine::Signature::total_evaluates_;

%ignore aiengine::Regex::Regex(const std::string &name, const std::string& exp,const SharedPointer<Regex>& re);
%ignore aiengine::Regex::evaluate;
%ignore aiengine::Regex::isTerminal;
%ignore aiengine::Regex::matchAndExtract;
%ignore aiengine::Regex::getExtract;
%ignore aiengine::Regex::getShowMatch;
%ignore aiengine::Regex::setShowMatch;
%ignore aiengine::Regex::setNextRegex(const SharedPointer<Regex>& reg);
%ignore aiengine::Regex::getNextRegex;
%ignore aiengine::Regex::setNextRegexManager;
%ignore aiengine::Regex::getNextRegexManager;

%rename("show_current_packet")    aiengine::PacketDispatcher::showCurrentPayloadPacket;
%ignore aiengine::PacketDispatcher::setStack(const SharedPointer<NetworkStack>& stack);
%ignore aiengine::PacketDispatcher::setDefaultMultiplexer;
%ignore aiengine::PacketDispatcher::setIdleFunction;

%ignore aiengine::Flow::setPacketAnomaly;
%ignore aiengine::Flow::getPacketAnomaly;
%ignore aiengine::Flow::ipset;
%ignore aiengine::Flow::layer4info;
%ignore aiengine::Flow::layer7info;
%ignore aiengine::Flow::getTCPInfo;
%ignore aiengine::Flow::getPOPInfo;
%ignore aiengine::Flow::getIMAPInfo;
%ignore aiengine::Flow::getSMTPInfo;
%ignore aiengine::Flow::getSSLInfo;
%ignore aiengine::Flow::getDNSInfo;
%ignore aiengine::Flow::getHTTPInfo;
%ignore aiengine::Flow::getGPRSInfo;
%ignore aiengine::Flow::getSSDPInfo;
%ignore aiengine::Flow::getSIPInfo;
%ignore aiengine::Flow::getBitcoinInfo;
%ignore aiengine::Flow::getNetbiosInfo;
%ignore aiengine::Flow::getCoAPInfo;
%ignore aiengine::Flow::getMQTTInfo;
%ignore aiengine::Flow::getDHCPInfo;
%ignore aiengine::Flow::getDHCPv6Info;
%ignore aiengine::Flow::getSMBInfo;
%ignore aiengine::Flow::getSSHInfo;
%ignore aiengine::Flow::getDCERPCInfo;
%ignore aiengine::Flow::getDestinationAddress6;
%ignore aiengine::Flow::getFlowAnomalyString;
%ignore aiengine::Flow::getIPSetInfo;
%ignore aiengine::Flow::getL7ShortProtocolName;
%ignore aiengine::Flow::getLabel;
%ignore aiengine::Flow::getSourceAddress6;
%ignore aiengine::Flow::hash;
%ignore aiengine::Flow::haveEvidence;
%ignore aiengine::Flow::isPartialReject;
%ignore aiengine::Flow::isReject;
%ignore aiengine::Flow::setLabel;
%ignore aiengine::Flow::setPartialReject;
%ignore aiengine::Flow::setReject;
%ignore aiengine::Flow::packet;
%ignore aiengine::Flow::regex;
%ignore aiengine::Flow::frequencies;
%ignore aiengine::Flow::packet_frequencies;
%ignore aiengine::Flow::forwarder;
%ignore aiengine::Flow::regex_mng;
%ignore aiengine::Flow::setId;
%ignore aiengine::Flow::getId;
%ignore aiengine::Flow::setFlowDirection;
%ignore aiengine::Flow::getFlowDirection;
%ignore aiengine::Flow::getPrevFlowDirection;
%ignore aiengine::Flow::setFiveTuple;
%ignore aiengine::Flow::setFiveTuple6;
%ignore aiengine::Flow::setArriveTime;
%ignore aiengine::Flow::setLastPacketTime;
%ignore aiengine::Flow::frequency_engine_inspected;
%ignore aiengine::Flow::reset;
%ignore aiengine::Flow::serialize;
%ignore aiengine::Flow::deserialize;
%ignore aiengine::Flow::showFlowInfo;
%ignore aiengine::Flow::getSourceAddress;
%ignore aiengine::Flow::getDestinationAddress;
%ignore aiengine::Flow::haveTag;
%ignore aiengine::Flow::setTag;
%ignore aiengine::Flow::getTotalBytes;
%ignore aiengine::Flow::getLastPacketTime;
%ignore aiengine::Flow::getDuration;
%ignore aiengine::Flow::getFrequencies;
%ignore aiengine::Flow::getPacketFrequencies;
%ignore aiengine::Flow::getFlowAnomaly;
%ignore aiengine::Flow::getTotalPackets;
%ignore aiengine::Flow::getTotalPacketsLayer7;
%ignore aiengine::Flow::updateTime;
%ignore aiengine::Flow::getAddress;

%ignore aiengine::IPSetManager::addIPSet(const SharedPointer<IPAbstractSet>& ipset);
%ignore aiengine::IPSetManager::removeIPSet(const SharedPointer<IPAbstractSet>& ipset);
%ignore aiengine::IPSetManager::getMatchedIPSet;
%ignore aiengine::IPSetManager::lookupIPAddress;

%ignore aiengine::IPAbstractSet::setRegexManager(const SharedPointer<RegexManager>& rmng);
%ignore aiengine::IPAbstractSet::getRegexManager;
%ignore aiengine::IPAbstractSet::lookupIPAddress;

%ignore aiengine::IPSet::getFalsePositiveRate;
%ignore aiengine::IPSet::lookupIPAddress;

%ignore aiengine::IPRadixTree::getFalsePositiveRate;
%ignore aiengine::IPRadixTree::lookupIPAddress;

%ignore aiengine::DomainNameManager::removeDomainName(const SharedPointer<DomainName>& domain);
%ignore aiengine::DomainNameManager::addDomainName(const SharedPointer<DomainName>& domain);
%ignore aiengine::DomainNameManager::getDomainName;

%ignore aiengine::DomainName::setHTTPUriSet(const SharedPointer<HTTPUriSet>& uset);
%ignore aiengine::DomainName::getHTTPUriSet;
%ignore aiengine::DomainName::setRegexManager;
%ignore aiengine::DomainName::getRegexManager;
%ignore aiengine::DomainName::setHTTPUriRegexManager;
%ignore aiengine::DomainName::getHTTPUriRegexManager;

%ignore aiengine::HTTPUriSet::lookupURI;
%ignore aiengine::HTTPUriSet::getFalsePositiveRate;
%ignore aiengine::HTTPUriSet::getTotalLookups;
%ignore aiengine::HTTPUriSet::getTotalLookupsIn;
%ignore aiengine::HTTPUriSet::getTotalLookupsOut;

%ignore aiengine::HTTPInfo::reset;
%ignore aiengine::HTTPInfo::serialize;
%ignore aiengine::HTTPInfo::resetStrings;
%ignore aiengine::HTTPInfo::getContentLength;
%ignore aiengine::HTTPInfo::setContentLength;
%ignore aiengine::HTTPInfo::getDataChunkLength;
%ignore aiengine::HTTPInfo::setDataChunkLength;
%ignore aiengine::HTTPInfo::setIsBanned;
%ignore aiengine::HTTPInfo::setHaveData;
%ignore aiengine::HTTPInfo::getHaveData;
%ignore aiengine::HTTPInfo::incTotalRequests;
%ignore aiengine::HTTPInfo::incTotalResponses;
%ignore aiengine::HTTPInfo::setResponseCode;
%ignore aiengine::HTTPInfo::uri;
%ignore aiengine::HTTPInfo::host_name;
%ignore aiengine::HTTPInfo::ua;
%ignore aiengine::HTTPInfo::ct;
%ignore aiengine::HTTPInfo::filename;
%ignore aiengine::HTTPInfo::matched_domain_name;
%ignore aiengine::HTTPInfo::getTotalRequests;
%ignore aiengine::HTTPInfo::getTotalResponses;
%ignore aiengine::HTTPInfo::getResponseCode;
%ignore aiengine::HTTPInfo::setBanAndRelease;
%ignore aiengine::HTTPInfo::setIsRelease;
%ignore aiengine::HTTPInfo::getIsRelease;
%ignore aiengine::HTTPInfo::setHTTPDataDirection;
%ignore aiengine::HTTPInfo::getHTTPDataDirection;

%ignore aiengine::MQTTInfo::reset;
%ignore aiengine::MQTTInfo::serialize;
%ignore aiengine::MQTTInfo::topic;
//%ignore aiengine::MQTTInfo::incTransactions;

%ignore aiengine::BitcoinInfo::reset;
%ignore aiengine::BitcoinInfo::serialize;
%ignore aiengine::BitcoinInfo::incTransactions;

%ignore aiengine::SIPInfo::reset;
%ignore aiengine::SIPInfo::serialize;
%ignore aiengine::SIPInfo::resetStrings;
%ignore aiengine::SIPInfo::uri;
%ignore aiengine::SIPInfo::from;
%ignore aiengine::SIPInfo::to;
%ignore aiengine::SIPInfo::via;

%ignore aiengine::MAX_PACKET_FREQUENCIES_VALUES;

%ignore aiengine::Frequencies::addPayload;

%ignore aiengine::PacketFrequencies::addPayload;

%ignore aiengine::DNSInfo::name;
%ignore aiengine::DNSInfo::serialize;
%ignore aiengine::DNSInfo::addIPAddress;
%ignore aiengine::DNSInfo::begin;
%ignore aiengine::DNSInfo::end;
%ignore aiengine::DNSInfo::reset;
%ignore aiengine::DNSInfo::resetStrings;
%ignore aiengine::DNSInfo::getQueryType;
%ignore aiengine::DNSInfo::setQueryType;
%ignore aiengine::DNSInfo::matched_domain_name;

%ignore aiengine::SSLInfo::reset;
%ignore aiengine::SSLInfo::serialize;
%ignore aiengine::SSLInfo::host_name;
%ignore aiengine::SSLInfo::issuer;
%ignore aiengine::SSLInfo::setIsBanned;
%ignore aiengine::SSLInfo::isBanned;
%ignore aiengine::SSLInfo::incDataPdus;
%ignore aiengine::SSLInfo::getTotalDataPdus;
%ignore aiengine::SSLInfo::matched_domain_name;
%ignore aiengine::SSLInfo::getHeartbeat;
%ignore aiengine::SSLInfo::setHeartbeat;
%ignore aiengine::SSLInfo::getVersion;
%ignore aiengine::SSLInfo::setVersion;

%ignore aiengine::SMTPInfo::reset;
%ignore aiengine::SMTPInfo::serialize;
%ignore aiengine::SMTPInfo::resetStrings;
%ignore aiengine::SMTPInfo::setIsBanned;
%ignore aiengine::SMTPInfo::isBanned;
%ignore aiengine::SMTPInfo::setCommand;
%ignore aiengine::SMTPInfo::from;
%ignore aiengine::SMTPInfo::to;
%ignore aiengine::SMTPInfo::matched_domain_name;

%ignore aiengine::IMAPInfo::reset;
%ignore aiengine::IMAPInfo::serialize;
%ignore aiengine::IMAPInfo::setIsBanned;
%ignore aiengine::IMAPInfo::isBanned;
%ignore aiengine::IMAPInfo::incClientCommands;
%ignore aiengine::IMAPInfo::incServerCommands;
%ignore aiengine::IMAPInfo::user_name;

%ignore aiengine::POPInfo::reset;
%ignore aiengine::POPInfo::serialize;
%ignore aiengine::POPInfo::setIsBanned;
%ignore aiengine::POPInfo::isBanned;
%ignore aiengine::POPInfo::incClientCommands;
%ignore aiengine::POPInfo::incServerCommands;
%ignore aiengine::POPInfo::user_name;
%ignore aiengine::POPInfo::resetStrings;

%ignore aiengine::SSDPInfo::reset;
%ignore aiengine::SSDPInfo::serialize;
%ignore aiengine::SSDPInfo::resetStrings;
%ignore aiengine::SSDPInfo::incTotalRequests;
%ignore aiengine::SSDPInfo::incTotalResponses;
%ignore aiengine::SSDPInfo::setResponseCode;
%ignore aiengine::SSDPInfo::uri;
%ignore aiengine::SSDPInfo::host_name;
%ignore aiengine::SSDPInfo::matched_domain_name;
%ignore aiengine::SSDPInfo::getTotalRequests;
%ignore aiengine::SSDPInfo::getTotalResponses;

%ignore aiengine::CoAPInfo::reset;
%ignore aiengine::CoAPInfo::serialize;
%ignore aiengine::CoAPInfo::host_name;
%ignore aiengine::CoAPInfo::uri;
%ignore aiengine::CoAPInfo::matched_domain_name;
%ignore aiengine::CoAPInfo::setIsBanned;
%ignore aiengine::CoAPInfo::isBanned;

%ignore aiengine::NetbiosInfo::reset;
%ignore aiengine::NetbiosInfo::serialize;
%ignore aiengine::NetbiosInfo::netbios_name;

%ignore aiengine::DHCPInfo::reset;
%ignore aiengine::DHCPInfo::serialize;
%ignore aiengine::DHCPInfo::host_name;
%ignore aiengine::DHCPInfo::ip;
%ignore aiengine::DHCPInfo::setLeaseTime;
%ignore aiengine::DHCPInfo::getLeaseTime;

%ignore aiengine::SMBInfo::reset;
%ignore aiengine::SMBInfo::serialize;
%ignore aiengine::SMBInfo::filename;

%ignore aiengine::DHCPv6Info::reset;
%ignore aiengine::DHCPv6Info::serialize;
%ignore aiengine::DHCPv6Info::host_name;
%ignore aiengine::DHCPv6Info::ip6;
%ignore aiengine::DHCPv6Info::setLifetime;
%ignore aiengine::DHCPv6Info::getT1;
%ignore aiengine::DHCPv6Info::getT2;
// %attribute(aiengine::DHCPv6Info, const char*, host_name, getHostName)

%ignore aiengine::SSHInfo::reset;
%ignore aiengine::SSHInfo::serialize;
%ignore aiengine::SSHInfo::setClientHandshake;
%ignore aiengine::SSHInfo::setServerHandshake;
%ignore aiengine::SSHInfo::addEncryptedBytes;

%ignore aiengine::DCERPCInfo::reset;
%ignore aiengine::DCERPCInfo::serialize;
%ignore aiengine::DCERPCInfo::uuid;

%ignore aiengine::LearnerEngine::agregatePacketFlow;
%ignore aiengine::LearnerEngine::setFrequencyGroup;
%ignore aiengine::LearnerEngine::agregateFlows;
%ignore aiengine::LearnerEngine::setMaxBufferSize;
%ignore aiengine::LearnerEngine::getQualityByte;
%ignore aiengine::LearnerEngine::getRawExpression;
%ignore aiengine::LearnerEngine::setMaxLenghtForRegularExpression;
%ignore aiengine::LearnerEngine::getAsciiExpression;

%ignore aiengine::FrequencyGroup::agregateFlows;
%ignore aiengine::FrequencyGroup::setLogLevel;
%ignore aiengine::FrequencyGroup::getReferenceFlowsByKey;
%ignore aiengine::FrequencyGroup::cbegin;
%ignore aiengine::FrequencyGroup::cend;
%ignore aiengine::FrequencyGroup::setName;
%ignore aiengine::FrequencyGroup::begin;
%ignore aiengine::FrequencyGroup::end;

%ignore aiengine::FlowManager::addFlow;
%ignore aiengine::FlowManager::removeFlow;
%ignore aiengine::FlowManager::findFlow;
%ignore aiengine::FlowManager::updateTimers;
%ignore aiengine::FlowManager::setFlowCache;
%ignore aiengine::FlowManager::setTCPInfoCache;
%ignore aiengine::FlowManager::getFlowTable;
%ignore aiengine::FlowManager::getLastProcessFlow;
%ignore aiengine::FlowManager::setProtocol;
%ignore aiengine::FlowManager::updateFlowTime;
%ignore aiengine::FlowManager::FlowTimeRefreshRate;
%ignore aiengine::FlowManager::setCacheManager;

%rename("regexmanager=")		aiengine::IPAbstractSet::setRegexManager;
%rename("timeout=")			aiengine::FlowManager::setTimeout;
%rename("timeout")			aiengine::FlowManager::getTimeout;
%rename("total_flows")			aiengine::FlowManager::getTotalFlows;
%rename("total_process_flows")		aiengine::FlowManager::getTotalProcessFlows;
%rename("total_timeout_flows")		aiengine::FlowManager::getTotalTimeoutFlows;
%rename("show_flows")			showFlows;
%rename("total_evaluates")		aiengine::Signature::getTotalEvaluates;
%rename("expression")			aiengine::Signature::getExpression;
%rename("next_regex=")			aiengine::Regex::setNextRegex;
%rename("total_transactions")		aiengien::BitcoinInfo::getTotalTransactions;
%rename("domain_name")			aiengine::DNSInfo::getDomainName;
%rename("matched_domain_name")          aiengine::DNSInfo::getMatchedDomainName;
%rename("user_name")			aiengine::POPInfo::getUserName;
%rename("user_name")			aiengine::IMAPInfo::getUserName;
%rename("mail_to")			aiengine::SMTPInfo::getTo;
%rename("mail_from")			aiengine::SMTPInfo::getFrom;
%rename("server_name")			aiengine::SSLInfo::getServerName;
%rename("matched_domain_name")          aiengine::SSLInfo::getMatchedDomainName;
%rename("evidence=")			aiengine::Flow::setEvidence;
%rename("evidence")			aiengine::Flow::getEvidence;
%rename("pop_info")			aiengine::Flow::getPOPInfoObject;
%rename("imap_info")			aiengine::Flow::getIMAPInfoObject;
%rename("smtp_info")			aiengine::Flow::getSMTPInfoObject;
%rename("ssl_info")			aiengine::Flow::getSSLInfoObject;
%rename("dns_info")			aiengine::Flow::getDNSInfoObject;
%rename("http_info")			aiengine::Flow::getHTTPInfoObject;
%rename("sip_info")			aiengine::Flow::getSIPInfoObject;
%rename("ssdp_info")			aiengine::Flow::getSSDPInfoObject;
%rename("coap_info")			aiengine::Flow::getCoAPInfoObject;
%rename("mqtt_info")			aiengine::Flow::getMQTTInfoObject;
%rename("netbios_info")			aiengine::Flow::getNetbiosInfoObject;
%rename("dhcp_info")			aiengine::Flow::getDHCPInfoObject;
%rename("bitcoin_info")			aiengine::Flow::getBitcoinInfoObject;
%rename("smb_info")			aiengine::Flow::getSMBInfoObject;
%rename("dhcp6_info")			aiengine::Flow::getDHCPIv6nfoObject;
%rename("ssh_info")			aiengine::Flow::getSSHInfoObject;
%rename("dcerpc_info")			aiengine::Flow::getDCERPCInfoObject;
%rename("regex")			aiengine::Flow::getRegex;
%rename("payload")			aiengine::Flow::getPayload;
%rename("uri")				aiengine::SIPInfo::getUri;
%rename("from")				aiengine::SIPInfo::getFrom;
%rename("to")				aiengine::SIPInfo::getTo;
%rename("via")				aiengine::SIPInfo::getVia;
%rename("user_agent")			aiengine::HTTPInfo::getUserAgent;
%rename("host_name")			aiengine::HTTPInfo::getHostName;
%rename("uri")				aiengine::HTTPInfo::getUri;
%rename("content_type")			aiengine::HTTPInfo::getContentType;
%rename("banned")			aiengine::HTTPInfo::isBanned;
%rename("matched_domain_name")          aiengine::HTTPInfo::getMatchedDomainName;
%rename("host_name")			aiengine::SSDPPInfo::getHostName;
%rename("uri")				aiengine::SSDPInfo::getUri;
%rename("host_name")			aiengine::DHCPInfo::getHostName;
%rename("host_name")			aiengine::DHCPv6Info::getHostName;
%rename("file_name")			aiengine::SMBInfo::getFilename;
%rename("http_uri_set=")		aiengine::DomainName::setHTTPUriSet;
%rename("tag")				aiengine::Flow::getTag;
%rename("l7_protocol_name")		aiengine::Flow::getL7ProtocolName;
%rename("protocol")			aiengine::Flow::getProtocol;
%rename("src_port")			aiengine::Flow::getSourcePort;
%rename("dst_port")			aiengine::Flow::getDestinationPort;
%rename("src_ip")			aiengine::Flow::getSrcAddrDotNotation;
%rename("dst_ip")			aiengine::Flow::getDstAddrDotNotation;
%rename("reject=")			aiengine::Flow::setRejectConnection;
%rename("stack_name")			aiengine::PacketDispatcher::getStackName;
%rename("pcap_filter=")			aiengine::PacketDispatcher::setPcapFilter;
%rename("pcap_filter")			aiengine::PacketDispatcher::getPcapFilter;
%rename("total_bytes")			aiengine::PacketDispatcher::getTotalBytes;
%rename("total_packets")		aiengine::PacketDispatcher::getTotalPackets;
%rename("stack=")			aiengine::PacketDispatcher::setStack;
%rename("shell")			aiengine::PacketDispatcher::getShell;
%rename("shell=")			aiengine::PacketDispatcher::setShell;
%rename("add_timer")		        aiengine::PacketDispatcher::addTimer;
%rename("callback=") 			setCallback(VALUE callback);
%rename("add_ip_set")			aiengine::IPSetManager::addIPSet;
%rename("remove_ip_set")		aiengine::IPSetManager::removeIPSet;
%rename("increase_allocated_memory")	increaseAllocatedMemory;
%rename("set_tcp_database_adaptor")	setTCPDatabaseAdaptor;
%rename("set_udp_database_adaptor")	setUDPDatabaseAdaptor;
%rename("tcpip_set_manager=")		setTCPIPSetManager;	
%rename("udpip_set_manager=")		setUDPIPSetManager;	
%rename("tcp_regex_manager=")		setTCPRegexManager;
%rename("udp_regex_manager=")		setUDPRegexManager;
%rename("total_tcp_flows=") 		setTotalTCPFlows;
%rename("total_tcp_flows") 		getTotalTCPFlows;
%rename("total_udp_flows=") 		setTotalUDPFlows;
%rename("total_udp_flows") 		getTotalUDPFlows;
%rename("tcp_flow_manager")		getTCPFlowManager;
%rename("udp_flow_manager")		getUDPFlowManager;
%rename("flows_timeout=")		setFlowsTimeout;
%rename("flows_timeout")		getFlowsTimeout;
%rename("enable_nids_engine=")		enableNIDSEngine;
%rename("enable_frequency_engine=")	enableFrequencyEngine;
%rename("link_layer_tag=")		enableLinkLayerTagging;
%rename("add_regex")			addRegex;
%rename("add_domain_name")		addDomainName;
%rename("matchs")			aiengine::Signature::getMatchs;
%rename("name")				getName;
%rename("name=")			setName;
%rename("add_ip_address")		addIPAddress;
%rename("stats_level=")			setStatisticsLevel;
%rename("stats_level")			getStatisticsLevel;
%rename("get_counters")			aiengine::NetworkStack::getCounters;
%rename("get_cache")			aiengine::NetworkStack::getCache;
%rename("release_caches")		aiengine::NetworkStack::releaseCaches;
%rename("release_cache")		aiengine::NetworkStack::releaseCache;
%rename("total_process_flows")		aiengine::FrequencyGroup<std::string>::getTotalProcessFlows;
%rename("total_computed_frequencies")	aiengine::FrequencyGroup<std::string>::getTotalComputedFrequencies;
%rename("reference_flows")		aiengine::FrequencyGroup<std::string>::getReferenceFlows;
%rename("add_flows_by_destination_port")	agregateFlowsByDestinationPort;
%rename("add_flows_by_source_port")		agregateFlowsBySourcePort;
%rename("add_flows_by_destination_address")	agregateFlowsByDestinationAddress;
%rename("add_flows_by_source_address")		agregateFlowsBySourceAddress;
%rename("add_flows_by_destination_address_and_port")	agregateFlowsByDestinationAddressAndPort;
%rename("add_flows_by_source_address_and_port")	agregateFlowsBySourceAddressAndPort;
%rename("regex")			aiengine::LearnerEngine::getRegularExpression;
%rename("agregate_flows")		aiengine::LearnerEngine::agregateFlows;
%rename("total_flows_process")		aiengine::LearnerEngine::getTotalFlowsProcess;
%rename("total_regex")			aiengine::RegexManager::getTotalRegexs;
%rename("total_matching_regex")		aiengine::RegexManager::getTotalMatchingRegexs;
%rename("add_uri")			aiengine::HTTPUriSet::addURI;
%rename("total_domains")		aiengine::DomainNameManager::getTotalDomains;
%rename("total_sets")			aiengine::IPSetManager::getTotalSets;
%rename setDomainNameManager		set_domain_name_manager;

%typemap(in) IPSetManager & "IPSetManager"
%typemap(in) IPSet & "IPSet"
%typemap(in) IPRadixTree & "IPRadixTree"
%typemap(in) RegexManager & "RegexManager"
%typemap(in) Regex & "Regex"
%typemap(in) DomainNameManager & "DomainNameManager"
%typemap(in) DomainName & "DomainName"

%apply long long { int64_t };
%apply int { int32_t };

%freefunc Regex "free_Regex";
%freefunc RegexManager "free_RegexManager";
%freefunc DomainNameManager "free_DomainNameManager";
%freefunc IPSetManager "free_IPSetManager";

%ignore operator<<;

%include "Callback.h"
%include "Signature.h"
%include "regex/Regex.h"
%include "regex/RegexManager.h"
%include "protocols/http/HTTPUriSet.h"
%include "names/DomainName.h"
%include "names/DomainNameManager.h"
%include "ipset/IPAbstractSet.h"
%include "ipset/IPSet.h"
%include "ipset/IPRadixTree.h"
%include "ipset/IPSetManager.h"
%include "DatabaseAdaptor.h"
%include "flow/FlowManager.h"
%include "NetworkStack.h"
%include "StackLan.h"
%include "StackMobile.h"
%include "StackLanIPv6.h"
%include "StackVirtual.h"
%include "StackOpenFlow.h"
%include "StackMobileIPv6.h"
%include "PacketDispatcher.h"
%include "protocols/http/HTTPInfo.h"
%include "protocols/sip/SIPInfo.h"
%include "protocols/frequency/Frequencies.h"
%include "protocols/frequency/PacketFrequencies.h"
%include "protocols/dns/DNSInfo.h"
%include "protocols/ssl/SSLInfo.h"
%include "protocols/smtp/SMTPInfo.h"
%include "protocols/imap/IMAPInfo.h"
%include "protocols/pop/POPInfo.h"
%include "protocols/ssdp/SSDPInfo.h"
%include "protocols/bitcoin/BitcoinInfo.h"
%include "protocols/coap/CoAPInfo.h"
%include "protocols/mqtt/MQTTInfo.h"
%include "protocols/netbios/NetbiosInfo.h"
%include "protocols/dhcp/DHCPInfo.h"
%include "protocols/smb/SMBInfo.h"
%include "protocols/dhcp6/DHCPv6Info.h"
%include "protocols/ssh/SSHInfo.h"
%include "protocols/dcerpc/DCERPCInfo.h"
%include "Flow.h"
%include "learner/LearnerEngine.h"
%include "protocols/frequency/FrequencyGroup.h"

%template(FrequencyGroupString) aiengine::FrequencyGroup<std::string>;

%header %{

    static void free_Regex(void *ptr) {
	aiengine::Regex *re  = (aiengine::Regex*) ptr;
    }

    static void mark_RegexManager(void *ptr) {
	aiengine::RegexManager *rmng  = (aiengine::RegexManager*) ptr;
    }

    static void free_IPSetManager(void *ptr) {
        aiengine::IPSetManager *imng = (aiengine::IPSetManager*) ptr;

        SWIG_RubyRemoveTracking(ptr);
    }

    static void free_DomainNameManager(void *ptr) {
	aiengine::DomainNameManager *dmng = (aiengine::DomainNameManager*) ptr;

        SWIG_RubyRemoveTracking(ptr);
    }

    static void free_RegexManager(void* ptr) {
        aiengine::RegexManager *rmng  = (aiengine::RegexManager*) ptr;

        SWIG_RubyRemoveTracking(ptr);
    }
%}