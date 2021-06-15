#!/bin/sh

SERVER=$1

/usr/bin/curl -s http://stat.vkontakte.dj/stat.getlag/?format=ini | /bin/awk -F "=" -v q=$SERVER '{ if ($1 == q) print $2 }'
