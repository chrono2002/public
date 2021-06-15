#!/bin/sh

cd /www; for SC_NAME in sc_*; do
    su - "${SC_NAME}" -c "./node_modules/forever/bin/forever stop app >>logrotate.log 2>&1"
    su - "${SC_NAME}" -c "./node_modules/forever/bin/forever -a -o /www/${SC_NAME}/logs/node-stdout.log -e /www/${SC_NAME}/logs/node-stderr.log start app >>logrotate.log 2>&1"
done
