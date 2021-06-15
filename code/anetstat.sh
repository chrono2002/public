#!/bin/bash
#
# automatic blackhole script based on netstat
#

whitelist="/var/www/html/whitelist"

while :; do
sleep 1
netstat -na | grep ":80" | awk '{print $5}' | grep -oE '[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}' | sort | uniq -c | sort -rn | head -300 | while read line; do
    ip=${line/*\ }
    nr=${line/\ *}

    if (( $nr > 40 )); then
	if ! grep -q $ip $whitelist &>/dev/null; then

        echo -n "$nr $ip"
        ip route add blackhole "${ip}/32" &>/dev/null
        if [ $? != 0 ]; then
            echo " - blackholed! (exists)"
        else
            echo $ip >> /anetstat.log
            echo " - blackholed!"
        fi

	fi
    fi
done
done
