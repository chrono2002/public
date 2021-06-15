#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о размере БД

username=postgres
dbname=postgres

psql -qAtX -F: -c "SELECT pg_database_size('$dbname')" -h 127.0.0.1 -U "$username" "$dbname"
