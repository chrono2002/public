#!/bin/sh
# Author: Alexey Lesovsky
# размер отдельного индекса или таблицы без индексов - pg_relation_size

username=postgres
dbname=postgres

if [ -z "$*" ]; then echo "ZBX_NOTSUPPORTED"; exit 1; fi

psql -qAtX -F: -c "SELECT pg_relation_size('$1');" -h 127.0.0.1 -U "$username" "$dbname" |cut -d' ' -f1
