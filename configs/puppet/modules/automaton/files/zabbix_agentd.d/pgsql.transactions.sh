#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о транзакциях
# первый параметр - статус транзакции, второй - имя базы (опциональный)

username=postgres
dbname=postgres

PARAM="$1"

case "$PARAM" in
'idle' )
        query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE current_query='<IDLE> in transaction';"
;;
'running' )
	query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE current_query<>'<IDLE> in transaction' AND current_query<>'<IDLE>'"
;;
'waiting' )
	query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE waiting = 't'"
;;
'*' ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -F: -c "$query" -h 127.0.0.1 -U "$username" "$dbname"
