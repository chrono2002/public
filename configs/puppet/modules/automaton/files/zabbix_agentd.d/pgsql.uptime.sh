#!/bin/sh
# Author: Alexey Lesovsky
# время работы БД с момента запуска

username=postgres
dbname=postgres

psql -qAtX -h 127.0.0.1 -U "$username" "$dbname" -c "select date_part('epoch', now() - pg_postmaster_start_time())::int;"
