#!/bin/sh

if [ $1 ]; then
    if [ -S $1 ]; then
        echo 1
    else
        echo 0
    fi
fi
