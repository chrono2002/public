#!/bin/bash
RESULT=$(curl -s 127.0.0.1/nginx-status | awk "{ if (\$0 ~ /${1}:/) { split(substr(\$0, match(\$0,\"${1}\")), a, /: /); print a[2] } }")
if [ "$RESULT" ] && [[ "$RESULT" =~ ^-{0,1}[0-9]+ ]] && (( "${RESULT}" >= 0 )); then echo "$RESULT"; else echo -1; fi
