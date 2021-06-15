#!/bin/sh
# Author: Alexey Lesovsky
# Details http://www.postgresql.org/docs/9.0/interactive/routine-vacuuming.html
# 23.1.4. Preventing Transaction ID Wraparound Failures

username=postgres
dbname=postgres

query="SELECT freez,txns,ROUND(100*(txns/freez::float)) AS perc,datname \
	FROM \
	( SELECT foo.freez::int,age(datfrozenxid) AS txns,datname \
		FROM pg_database d JOIN \
		( SELECT setting AS freez FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') AS foo ON (true) \
		WHERE d.datallowconn \
	) AS foo2 WHERE datname = '$dbname' \
ORDER BY 3 DESC, 4 ASC"

psql -qAtX -F: -c "$query" -h 127.0.0.1 -U "$username" "$dbname" |cut -d: -f3
