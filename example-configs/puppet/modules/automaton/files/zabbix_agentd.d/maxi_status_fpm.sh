#!/bin/bash
RESULT=$(curl -s 127.0.0.1/fpm-status | awk "{ if (\$0 ~ /^${1}:/) print \$3 }")
if [ "$RESULT" ] && [[ "$RESULT" =~ ^-{0,1}[0-9]+$ ]] && (( "${RESULT}" >= 0 )); then echo "$RESULT"; else echo -1; fi
