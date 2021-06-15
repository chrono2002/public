#!/bin/sh
# Author: Alexey Lesovsky
# лаг потоковой репликации БД

username=postgres
dbname=postgres

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    echo "ZBX_NOTSUPPORTED. uninitialized variable master" ; exit 1;
  else
    master="$1"
fi

dbname=$(grep $master ~zabbix/.pgpass |cut -d: -f3)

echo $(( \
	$(printf "%d\n" "0x"$(psql -qAtX -h $master -U $username $dbname -c "SELECT pg_current_xlog_location()" |cut -d\/ -f2)) \
	- \
	$(printf "%d\n" "0x"$(psql -qAtX -h 127.0.0.1 -U $username $dbname -c "SELECT pg_last_xlog_replay_location()" |cut -d\/ -f2)) \
      ))
