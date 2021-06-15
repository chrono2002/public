#!/bin/sh

QUEUE=$1

sudo /usr/sbin/rabbitmqctl -q list_queues -p vkdj | awk -v q=$QUEUE '{ if ($1 == q) print $2 }'
