#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о текущих подключениях к БД
# первым параметром указывается статус процесса, вторым - база (опционально)

username=postgres
dbname=postgres

PARAM="$1"

case "$PARAM" in
'idle_in_transaction' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE current_query = '<IDLE> in transaction';"
;;
'idle' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE current_query = '<IDLE>';"
;;
'total' )
        query="SELECT COUNT(*) FROM pg_stat_activity;"
;;
'running' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE current_query != '<IDLE>';"
;;
'waiting' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE waiting <> 'f';"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -F: -c "$query" -h 127.0.0.1 -U "$username" "$dbname"
