#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <device> <parameter>"
    exit
fi

#if ! service smartd status | grep running &>/dev/null; then
#    exit
#fi

/usr/bin/sudo /usr/sbin/smartctl -A /dev/$1 | grep $2 | tr -s ' ' | sed "s/^[[:space:]]*\(.*\)[[:space:]]*$/\1/" | cut -d " " -f 10
