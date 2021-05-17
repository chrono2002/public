#!/bin/bash

echo "Please edit /iptables.sh"
exit

SERVERS=172.20.0.1

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.eth0.proxy_arp=1

iptables -A INPUT -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -i eth0 -p tcp --dport 2000:65000 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 53 -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 53 -j ACCEPT
iptables -A INPUT -i eth0 -p icmp --icmp-type 0 -j ACCEPT

# -- accept pings from monitoring

iptables -A INPUT -i eth0 -p icmp -j ACCEPT
iptables -A INPUT -i eth0 -p icmp -s $SERVERS -j ACCEPT
iptables -A OUTPUT -o eth0 -p icmp -d $SERVERS -j ACCEPT

# -- INPUT

iptables -A INPUT -i eth0 -p tcp --dport 2 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -j DROP

iptables -A OUTPUT -o eth0 -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -o eth0 -p icmp -j DROP

/sbin/iptables -t nat -A POSTROUTING -o eth0 -s 192.168.122.0/24 -j MASQUERADE

# -- nginx PUBLIC
#iptables -t nat -I PREROUTING -d $NGINX_IP -p tcp --dport 3 -j DNAT --to-destination 192.168.122.10:2
#iptables -t nat -I PREROUTING -d $NGINX_IP -p tcp --dport 80 -j DNAT --to-destination 192.168.122.10
#iptables -t nat -I PREROUTING -s $SERVERS -d $API_IP -p tcp --dport 15672 -j DNAT --to-destination 192.168.122.10

# -- db PUBLIC
#iptables -t nat -I PREROUTING -d $DB_IP -p tcp --dport 4 -j DNAT --to-destination 192.168.122.12:2
#iptables -t nat -I PREROUTING -s $SERVERS -d $DB_IP -p tcp --dport 5432 -j DNAT --to-destination 192.168.122.12

# -- arp proxy example
#/sbin/route add -host <real_ip_goes_here> dev virbr0
#/sbin/route add -host <real_ip_goes_here> dev virbr0
