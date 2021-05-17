#!/bin/sh

#echo "ACTION==\"add\", SUBSYSTEM==\"net\", ENV{ID_NET_NAME_ONBOARD}==\"eth0\", RUN+=\"/bin/sh -c 'echo 1 > /sys\$DEVPATH/device/remove'\"" > /etc/udev/rules.d/90-disable-eth0.rules

# rename eth0 to eth1

eth0_mac=$(/sbin/ifconfig eth0 | grep -E -o "ether [a-z0-9:]+" | cut -d " " -f2)
eth1_mac=$(/sbin/ifconfig eth1 | grep -E -o "ether [a-z0-9:]+" | cut -d " " -f2)

echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"${eth1_mac}\", NAME=\"eth0\"" > /etc/udev/rules.d/10-network.rules
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"${eth0_mac}\", NAME=\"eth1\"" >> /etc/udev/rules.d/10-network.rules

cat >/etc/netplan/50-init.yaml <<EOL
network:
    ethernets:
        eth0:
            dhcp4: no
            addresses: [$1/24]
            gateway4: 172.20.0.1
            nameservers:
                addresses: [172.20.0.12,8.8.8.8]
        eth1:
            dhcp4: yes
            routes:
              - to: 172.20.0.178
                via: 192.168.121.1
                on-link: true
EOL
#            addresses: [$3/24]

rm /etc/netplan/50-vagrant.yaml /etc/netplan/01-netcfg.yaml

/usr/bin/hostnamectl set-hostname $2

echo $1 $2 >> /etc/hosts

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsum1tUhc+LXigDfCczMJ/Aepif7jD7NHADMTOO8BE6sWiZSs5730sRY5Cnam04tuw8NTQLN98DUEmDH9lBm4pvcTX7K1TYahII3Mw6xhIpHq0zDT65vjaqfP473TkUMFhN6chgzb1r7fqyXEIZLFD6PjpOhrYKq/MTx5OWPnyrToI8i4XGQEFf7Qe6O4MQNohvaT4k8s3PwIby1hYRKbsM7wM0XJH4bMAWXYRB1ECYvzp2yaciLydW3GvoY+scEIrf7NCMh6O7i/XZGI7dFdOnKSL+VV1l+755fQ2qZHb+yY0fMVotv5AUxgwRTeqjhPiB706+/fUzgHCHgDJWMsN ps@maximum-security.ru" >> /home/vagrant/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/BJWjZloUglcOj2wgsr5i4cOBxoNIJDoeuR7eoTNfzPYoZI529OyAY8vz8ovJRPF4XtmfQhYC9FcjOwZbXLd71Ng2dbLaOYEd3cgTstqSHYfoLvw2wjsOQTvrBKGKHVNVB1PL/rz1DZ6tOLXlhFZ6Cr49aZRT1Pcm2kFwTn9QkdA//urR28U+0TzdGX0+ZEtq2ZV8BVeGWwl4/MRpYbZqlIJDrZ7ThP5Ubeo5L7YC3X+/XypqIw4sO1j/QYDfA/snmyfYggB2dHtiDPL6+g1g8HRbnDfkYOoNEUFNsWCezHxwFk9vQquTwMSyMbWcD7pJM//rVAqcgfxDqGRY5zf9 root@kube" >> /home/vagrant/.ssh/authorized_keys

route del default dev eth0

#route add -host 172.20.0.178 eth1

#udevadm control --reload-rules && udevadm trigger
#netplan apply
#route del default eth0

apt-get -y -q install mc python && reboot


