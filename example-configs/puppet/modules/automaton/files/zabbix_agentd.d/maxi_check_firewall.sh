#!/bin/bash

# log=/var/log/maxi_firewall.log
# touch $log
# /bin/chmod 644 $log

if [ -e /sbin/shorewall ]; then
    sudo /sbin/shorewall status &>/dev/null

    if [ "$?" = "0" ]; then
        echo 666
        # > $log
    else
        echo 0
        # > $log
    fi
else
    /usr/bin/sudo /sbin/iptables -L -n | awk 'BEGIN { count=0 } { if ($0 ~ "INPUT") input=1; if (input == 1) { if ($0 == "") { input=0 } else if ($0 !~ "Chain|target") { count=count+1 } } } END { print count }'
fi
