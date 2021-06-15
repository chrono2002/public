#!/bin/bash
# cron.hourly

status=/var/log/fhs_security_updates_status.log

touch $status
/bin/chmod 644 $status

if [ -f /etc/redhat-release ]; then
    centos=1
elif [ -f /etc/debian_version ]; then
    ubuntu=1
fi

if [ $centos ]; then
    /usr/bin/yum --security check-update &>/dev/null
    centos_tmp=$?
elif [ $ubuntu ]; then
    /usr/bin/apt-get -qq update 
    /usr/bin/apt-get -s dist-upgrade |grep "^Inst" |grep -i securi &>/dev/null
    ubuntu_tmp=$?
fi

if  ([ $centos_tmp ] && [ $centos_tmp == 0 ]) || \
    ([ $ubuntu_tmp ] && [ $ubuntu_tmp == 1 ]); then

    # no updates found
    echo -n 1 > $status

    exit 0
else
    # updates available
    echo -n 2 > $status
    exit 0
fi

echo -n 0 > $status
exit 1
