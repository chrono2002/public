class automaton::service_zabbix {

    # -- quick fix for centos7

    case $operatingsystem {
        centos: {
#	    case $operatingsystemmajrelease {
#		6: {
		    $nameof_zabbix = 'zabbix22'
		    package { 'zabbix': ensure => absent }
		    package { 'zabbix-agent': ensure => absent }
#		}
#		7: {
#		    $nameof_zabbix = 'zabbix'
#		    package { 'zabbix22-agent': ensure => absent }
#		}
#	    }
	}
	debian, ubuntu: {
	    $nameof_zabbix = 'zabbix'
#	    package { 'zabbix': ensure => absent }
#	    package { 'zabbix-agent': ensure => absent }
	}
    }    

    if $only {
	require os_repos

	package { 'wget': ensure => latest }
	package { 'mdadm': ensure => latest }
        package { 'smartmontools': ensure => latest }
        package { 'gawk': ensure => latest }

	case $operatingsystem {
    	    centos: {
        	package { 'conntrack-tools': ensure => latest }
        	package { 'yum-utils': ensure => latest }
    	    }
#    	    debian, ubuntu: {
#        	package { 'conntrack': ensure => latest }
#    	    }
	}

	case $operatingsystem {
    	    centos: {
		case $operatingsystemmajrelease {
		    6: {
        		package { 'yum-plugin-security': ensure => latest }
		    }
		}
	    }
	}
    } else {
	require os
    }

    case $operatingsystem {
	ubuntu, debian: {
	    package { 'zabbix-agent': ensure => latest }

	    service { "zabbix-agent":
    		ensure  => "running",
    		enable  => "true",
		require => Package [ "zabbix-agent" ]
	    }
	}
    }

    case $operatingsystem {
        centos: {
	    package { 'zabbix20-agent': ensure => absent }
	    ->
	    package { 'zabbix20': ensure => absent }
	    ->
	    package { "${nameof_zabbix}-agent": ensure => latest }

	    service { "zabbix-agent":
#    		ensure  => "running",
    		enable  => "true",
#		require => Package [ "${nameof_zabbix}-agent" ]
	    }

	    exec { "grub_fix":
    		command => '/bin/chmod 644 /boot/grub/grub.conf'
	    }

	    exec { "sudo_fix":
		command => '/bin/sed -i~ "s/Defaults.*requiretty/#Defaults requiretty/" /etc/sudoers'
	    }
	}
	debian: {
	    exec { "add_zabbix_repo2":
        	command => "/usr/bin/wget http://repo.zabbix.com/zabbix/2.2/debian/pool/main/z/zabbix-release/zabbix-release_2.2-1+wheezy_all.deb -O /tmp/zabbix-release_2.2-1+wheezy_all.deb && cd /tmp && /usr/bin/dpkg -i zabbix-release_2.2-1+wheezy_all.deb && apt-get update",
        	unless => "/usr/bin/test -f /etc/apt/sources.list.d/zabbix.list",
		require => Package [ "wget" ]
            }
	}
	ubuntu: {
	    exec { "add_zabbix_repo":
        	command => "/usr/bin/wget http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+precise_all.deb -O /tmp/zabbix-release_2.2-1+precise_all.deb && cd /tmp && /usr/bin/dpkg -i zabbix-release_2.2-1+precise_all.deb && apt-get update",
        	unless => "/usr/bin/test -f /etc/apt/sources.list.d/zabbix.list",
		require => Package [ "wget" ]
            }
	}
    }


    file { "/etc/zabbix/zabbix_agentd.d":
        source => "puppet:///modules/automaton/zabbix_agentd.d",
        ensure => directory,     
        recurse => true,         
        owner => root,
        group => root,
#	require => Package [ "zabbix-agent" ]
    }
    ->
    exec { zabbix_post:
	command => '/bin/ln -s /etc/zabbix/zabbix_agentd.d/cron_updates.sh /etc/cron.daily; /etc/zabbix/zabbix_agentd.d/cron_updates.sh; /bin/ln -s /etc/zabbix/zabbix_agentd.d/cron_security_updates.sh /etc/cron.hourly; /etc/zabbix/zabbix_agentd.d/cron_security_updates.sh; usermod -G memcached zabbix; exit 0'
    }
    ->
    case $operatingsystem {
        centos: {
	    file { "/etc/zabbix/zabbix_agentd.conf":
    		content => template('automaton/zabbix_agentd.conf.erb'),
    		owner => root,
    		group => root,
    		mode => 644,
		notify => Service["zabbix-agent"],
	    }
	    file { "/etc/zabbix_agentd.conf":
    		content => template('automaton/zabbix_agentd.conf.erb'),
    		owner => root,
    		group => root,
    		mode => 644,
		notify => Service["zabbix-agent"],
	    }
	}
	ubuntu, debian: {
	    file { "/etc/zabbix/zabbix_agentd.conf":
    		content => template('automaton/zabbix_agentd.conf.erb'),
    		owner => root,
    		group => root,
    		mode => 644,
		notify => Service["zabbix-agent"],
	    }
	}
    }


    file { "/etc/sudoers.d/fhs":
        source => "puppet:///modules/automaton/sudoers.fhs",
        ensure => file,
        owner => root,
        group => root,
    }

    if $service_kvm {
        package { 'collectd': ensure => latest }
        ->
	package { 'collectd-virt': ensure => latest }
        ->
	package { 'perl-Collectd': ensure => latest }
	->
	file { '/etc/collectd.conf':
    	    source => 'puppet:///modules/automaton/collectd.conf',
    	    owner => root,
    	    group => root,
    	    mode => 644,
	}
	->
	service { "collectd":
    	    ensure  => "running",
    	    enable  => "true",
	    notify => Service["zabbix-agent"],
	}
    }        

    exec { "zabbix_postgresql":
        command => '/bin/cp /var/lib/pgsql/.pgpass /var/lib/zabbix; chmod 600 /var/lib/zabbix/.pgpass; chown zabbix:zabbix /var/lib/zabbix/.pgpass',
        onlyif => '/usr/bin/test -f /var/lib/pgsql/.pgpass'
    }

}
