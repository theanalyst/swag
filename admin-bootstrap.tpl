#!/bin/bash
cat > /etc/sysconfig/network/ifcfg-eth1 << EOF
BOOTPROTO='dhcp'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR=''
MTU=''
NAME='Ethernet Card 2'
NETMASK=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

sudo wicked ifup eth1
