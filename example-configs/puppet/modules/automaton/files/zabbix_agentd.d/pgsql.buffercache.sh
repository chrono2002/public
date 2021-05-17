#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о буфферах в shared_memory.
# требуется включение модуля pg_buffercache и при использовании дает оверхед производительности.
# http://www.postgresql.org/docs/9.1/static/pgbuffercache.html

username=postgres
dbname=postgres

PARAM="$1"

case "$PARAM" in
'clear' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE isdirty='f';"
;;
'dirty' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE isdirty='t';"
;;
'used' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE reldatabase IS NOT NULL;"
;;
'total' )
        query="SELECT count(*) FROM pg_buffercache;"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -F: -c "$query" -h 127.0.0.1 -U "$username" "$dbname"
