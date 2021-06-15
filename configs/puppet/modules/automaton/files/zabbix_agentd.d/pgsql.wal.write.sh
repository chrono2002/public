#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации об интенсивности записи WAL-журналов

username=postgres
dbname=postgres

POS=$(psql -qAtX -c "select pg_xlogfile_name(pg_current_xlog_location())" -h 127.0.0.1 -U "$username" "$dbname" | cut -b 9-16,23-24)

echo $((0x$POS))
