# -- Filesystem tune

class automaton::os_fs {


# Tune ext3/4 enable writeback + reserved space 1%

    exec { "tune2fs":
        command => "/bin/grep -v '^#' /etc/fstab | grep ext | gawk '{ print \$1 }' | while read fs; do tune2fs -o journal_data_writeback \$fs; tune2fs -m 1 \$fs; done"
    }

#    exec { "fstab_disable_swap":
#        command => "/bin/sed -i~ '/swap/s/^/#/' /etc/fstab && /sbin/swapoff -a",
#        unless => "/bin/egrep '#.*swap' /etc/fstab"
#    }

# Add custom rc.local script

    case $operatingsystem {
	centos: {
	    exec { "edit_rc_local":
    		command => "/usr/bin/chmod +x /etc/rc.d/rc.local; /bin/sed -i~ 's/touch \\/var\\/lock\\/subsys\\/local/\\/etc\\/rc.fhs\\ntouch \\/var\\/lock\\/subsys\\/local/' /etc/rc.d/rc.local",
    		unless => "/bin/grep rc.fhs /etc/rc.local"
	    }

# Tune ext3/4 fstab

	    exec { "fstab_tune_ext34":
		command => "/bin/cp -f /etc/fstab /etc/fstab.def; /bin/sed -i~ 's/ext4.*defaults/ext4 defaults,noatime,nodiratime,nobarrier,journal_async_commit,delalloc,nobh,commit=600,nouser_xattr,noacl/' /etc/fstab; /bin/sed -i~ 's/ext3.*defaults/ext3 defaults,noatime,nodiratime,nobarrier,commit=600,nouser_xattr,noacl/' /etc/fstab && /bin/mount -a",
    		unless => "/bin/grep nodiratime /etc/fstab"
	    }
	}
	debian, ubuntu: {
	    exec { "edit_rc_local":
    		command => "/bin/sed -i~ 's/exit 0/\\/etc\\/rc.fhs\\nexit 0/' /etc/rc.local",
    		unless => "/usr/bin/test -f /etc/rc.fhs"
	    }
	}
    }
    ->
    file { '/etc/rc.fhs':
	content => template('automaton/rc.fhs.erb'),
#        source => 'puppet:///modules/automaton/rc.fhs',
        owner => root,
        group => root,
        mode => 755,
    }

    # Disable cron slowdowns

    exec { "disable_sysstat":
        command => "/bin/sed -i 's/^\\([^#]\\)/#\\1/g' /etc/cron.d/sysstat",
	unless => "/usr/bin/test ! -f /etc/cron.d/sysstat"
    }

    case $operatingsystem {
	centos: {
	    exec { "disable_makewhatis":
    		command => "/bin/sed -i 's/^\\([^#]\\)/#\\1/g' /etc/cron.daily/makewhatis.cron",
    		unless => "/usr/bin/test ! -f /etc/cron.daily/makewhatis.cron"
	    }

	    exec { "raid_check_monthly":
    		command => "/bin/sed -i 's/0 1 \* \* Sun root/0 0 1 * * root/g' /etc/cron.d/raid-check",
    		unless => '/usr/bin/test ! -f /etc/cron.d/raid-check'
	    }

	    exec { "rsyslog_async":
    		command => "/bin/sed -i~ 's/ \/var\/log/ -\/var\/log/g' /etc/rsyslog.conf",
		notify  => Service[ "rsyslog" ]
	    }
	}
	debian, ubuntu: {
	    exec { "disable_sysstat_daily":
    		command => "/bin/sed -i 's/^\\([^#]\\)/#\\1/g' /etc/cron.daily/sysstat",
		unless => "/usr/bin/test ! -f /etc/cron.daily/sysstat"
	    }
	}
    }
}
