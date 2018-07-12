#!/bin/bash

#TODO use cloud-config or template-dir to split up into common and others
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

# Setting up deploy keys
echo ${ssh_keys} >> ~/.authorized_keys
