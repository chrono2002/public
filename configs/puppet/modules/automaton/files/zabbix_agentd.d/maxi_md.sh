#!/bin/sh

[ -b "/dev/$1" ] || { echo -1; exit 1; }

/usr/bin/sudo /sbin/mdadm -D /dev/$1 | /bin/grep '^[\t ]*State' | /bin/sed 's/^[\t ]*State :[\t ]*//g' | /usr/bin/awk 'BEGIN{a=0};/clean/{a+=1};/degraded/{a+=2};/resyncing/{a+=4};/recovering/{a+=8};/Not Started/{a+=16};END{if (NR==1) print a; else print -1 }'
