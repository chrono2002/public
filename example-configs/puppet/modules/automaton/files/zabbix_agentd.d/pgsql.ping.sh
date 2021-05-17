#!/bin/sh
# Author: Alexey Lesovsky
# время отклика БД

username=postgres
dbname=postgres

query="select 1;"
echo -e "\\\timing \n select 1" | psql -qAtX -h 127.0.0.1 -U "$username" "$dbname" |grep Time |cut -d' ' -f2
