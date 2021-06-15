#!/bin/bash

#export K6_DURATION=30s
export RANDOM_NAME=$(curl -s www.pseudorandom.name | cut -d " " -f 2 | tr '[:upper:]' '[:lower:]')

ulimit -n 65535

./k6 run test.js
