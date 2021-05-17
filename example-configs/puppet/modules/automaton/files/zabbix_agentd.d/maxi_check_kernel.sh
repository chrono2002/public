#!/bin/bash

current=$(/bin/uname -a | cut -d " " -f 3)

if [ -f /etc/redhat-release ]; then
    new=$(cat /boot/grub/grub.conf | grep CentOS | head -n 1 | egrep -o "\(.*" | tr -d "()")
elif [ -f /etc/debian_version ]; then
    new=$(cat /boot/grub/grub.cfg | grep menuentry | cut -d " " -f 5 | head -n 1 | tr -d "'")
fi

if [ "${current}" == "${new}" ]; then
    echo 0
else
    echo 1
fi