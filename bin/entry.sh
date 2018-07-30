#!/bin/sh -ex

#Load main settings
cat /config/settings.sh
. /config/settings.sh

#derived settings
OPENVPN_ROUTER_IP="$(dig +short $OPENVPN_ROUTER_NAME)"
GW_ORG=$(route |awk '$1=="default"{print $2}')
NAT_ENTRY="$(grep $(hostname) /config/nat.conf||true)"

#Create tunnel NIC
ip link add vxlan0 type vxlan id $VXLAN_ID dev eth0 dstport 0 || true
bridge fdb append to 00:00:00:00:00:00 dst $OPENVPN_ROUTER_IP dev vxlan0
ip link set up dev vxlan0

#Configure IP and default GW
route del default gw $GW_ORG
if [ -z "$NAT_ENTRY" ]; then
  echo "Get dynamic IP"
  dhclient -cf /config/dhclient.conf vxlan0
else
  IP=$(echo $NAT_ENTRY|cut -d' ' -f2)
  VXLAN_IP="${VXLAN_IP_NETWORK}.${IP}"
  echo "Use fixed IP $VXLAN_IP"
  ip addr add $VXLAN_IP/24 dev vxlan0
  route add default gw $VXLAN_ROUTER_IP
  echo "nameserver $VXLAN_ROUTER_IP">/etc/resolv.conf.dhclient
fi
ping -c1 $VXLAN_ROUTER_IP

#Set DNS
#route add $DNS_ORG gw $GW_ORG
cp -av /etc/resolv.conf.dhclient* /etc_shared/resolv.conf
