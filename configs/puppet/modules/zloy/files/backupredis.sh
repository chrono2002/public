#!/bin/sh

##export RSYNC_RSH="ssh -i /root/.ssh/"

HOST=$(hostname)

mkdir -p /var/backups/redis
/backupredis.rb
/usr/bin/rsync -a -z -v -P /var/backups/redis/* backup@1.1.1.1:/home/backup/${HOST}_redis/
