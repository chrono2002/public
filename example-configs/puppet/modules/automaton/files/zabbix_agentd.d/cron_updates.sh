#!/bin/bash
# cron.daily

# TODO: check new releases of centos & freebsd
# TODO: freebsd check kernel version

# extreme!!!
do_update=0

status=/var/log/maxi_update_status.log
log=/var/log/maxi_update.log

touch $status $log
/bin/chmod 644 $status $log

if [ -f /etc/redhat-release ]; then
    centos=1
elif [ -f /etc/debian_version ]; then
    ubuntu=1
elif [ -f /etc/freebsd-update.conf ]; then
    freebsd=1
fi

if [ $centos ]; then
    echo -e "n\n" | /usr/bin/yum -q update &>/dev/null
    centos_tmp=$?
elif [ $ubuntu ]; then
    ubuntu_tmp=$(/usr/bin/apt-get -qq update && /usr/bin/apt-get -qq --simulate dist-upgrade | wc -l)
elif [ $freebsd ]; then
    mkdir -p /var/db/freebsd-update/files
    freebsd_tmp=$(ls -1 /var/db/freebsd-update/files | wc -l | tr -d " ")
fi

if  ([ $centos_tmp ] && [ $centos_tmp == 0 ]) || \
    ([ $ubuntu_tmp ] && [ $ubuntu_tmp == 0 ]); then

    # no updates found
    echo -n 1 > $status

    if [ $ubuntu ]; then
	if /usr/bin/do-release-upgrade -c -q; then
	    echo -n 5 > $status
	fi
    fi

    exit 0
else
    if [ $do_update == 1 ]; then
        # in progress
        echo -n 4 > $status
#	exit 0

	date >> $log
        if  ([ $centos ] && /usr/bin/yum -y -q update &> $log ) || \
            ([ $ubuntu ] && /usr/bin/apt-get -qq dist-upgrade &> $log) || \
            ([ $freebsd ] && /usr/sbin/freebsd-update install &> $log); then

            # updates installed
            echo -n 3 > $status

#	    if [ $freebsd ]; then
#	        rm -rf /var/db/freebsd-update.bck
#	        mv /var/db/freebsd-update /var/db/freebsd-update.bck
#	    fi

    	    exit 0
        else
    	    if [ $freebsd ]; then
		if ! /usr/local/sbin/portaudit -Fda &>$log; then 
		    echo -n 6 > $status
		    exit 0
		fi
	        
	        # no updates found
		echo -n 1 > $status
	    else
                # update failed
	        echo -n 0 > $status		
    	    fi
    	    exit 0
        fi
    else
        # updates available
        echo -n 2 > $status
	exit 0
    fi
fi

chmod 644 /boot/grub/grub.conf &>/dev/null
echo -n 0 > $status
exit 1
