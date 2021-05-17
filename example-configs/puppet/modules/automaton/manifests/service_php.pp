class automaton::service_php {

### sendmail_path = /usr/sbin/sendmail -t -i -fno-reply@wartur.ru
### sendmail_from = www-data@skyteaser.com

    require os

    if $bootstrap {
        service { "${nameof_php}-fpm":
	    ensure  => "running",
	    enable  => "true",
	    require => Package[ "${nameof_php}-fpm" ]
        }

	file { "/etc/php.ini":
    	    content => template('automaton/php.ini.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package [ $nameof_php ],
	    notify  => Service[ "${nameof_php}-fpm" ],
	}

	file { "${automaton::fpm_dir}/www.conf":
	    content => template('automaton/www.conf.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package [ "${nameof_php}-fpm" ],
	    notify  => Service[ "${nameof_php}-fpm" ],
	}
    } else {
	file { "/tmp/fhs/www.conf":
	    content => template('automaton/www.conf.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package [ "${nameof_php}-fpm" ],
#	    notify  => Service[ "${nameof_php}-fpm" ],
	}

    	file { "/tmp/fhs/php.ini":
    	    content => template('automaton/php.ini.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package [ $nameof_php ],
#	    notify  => Service[ "${nameof_php}-fpm" ],
	}
    }

    case $operatingsystem {
        centos: {
	    package { "${nameof_php}": ensure => latest }
	    package { "${nameof_php}-common": ensure => latest }
	    package { "${nameof_php}-cli": ensure => latest }
	    package { "${nameof_php}-devel": ensure => latest }
	    package { "${nameof_php}-bcmath": ensure => latest }
	    package { "${nameof_php}-mbstring": ensure => latest }
	    package { "${nameof_php}-mcrypt": ensure => latest }
	    package { "${nameof_php}-gd": ensure => latest }
	    package { "${nameof_php}-pecl-imagick": ensure => latest }
	    package { "${nameof_php}-pdo": ensure => latest }
	    package { "${nameof_php}-imap": ensure => latest }
	    package { "${nameof_php}-pecl-memcache": ensure => latest }
	    package { "${nameof_php}-xml": ensure => latest }

#	    package { "${nameof_php}-xcache": ensure => absent }

	    package { "${nameof_php}-fpm": ensure => latest }

	    if $vkdj {
		package { "${nameof_php}-pgsql": ensure => latest }
		package { "${nameof_php}-pecl-amqp": ensure => latest }
		package { "${nameof_php}-pecl-geoip": ensure => latest }
	    }

	    file { "/etc/init.d/tmpshm":
	        content => template('automaton/init.d_centos/tmpshm'),
    		owner => root,
    		group => root,
    		mode => 755,
    		require => Exec [ "mkdir_www" ]
	    }
	    ->
	    exec { "tmpshm_post":
    		command => "/sbin/chkconfig tmpshm on; /etc/init.d/tmpshm start",
    		unless  => "/usr/bin/test -f /var/lock/subsys/tmpshm",
	    }
	}
	debian, ubuntu: {
	    package { 'php5': ensure => latest }
	    package { 'php5-common': ensure => latest }
	    package { 'php5-cli': ensure => latest }
	    package { 'php5-dev': ensure => latest }
	    package { 'php5-gd': ensure => latest }
	    package { 'php5-imagick': ensure => latest }
	    package { 'php5-mcrypt': ensure => latest }
	    package { 'php5-imap': ensure => latest }
	    package { 'php5-memcache': ensure => latest }

#	    package { 'php5-xcache': ensure => absent }

	    package { 'php5-fpm': ensure => latest }

	    file { "/etc/init.d/tmpshm":
	        content => template('automaton/init.d_debian/tmpshm'),
    		owner => root,
    		group => root,
    		mode => 755,
    		require => Exec [ "mkdir_www" ]
	    }
	    ->
	    exec { "tmpshm_post":
    		command => "/usr/sbin/update-rc.d tmpshm enable; /etc/init.d/tmpshm start",
    		unless  => "/bin/df | grep $dir_www/tmp",
	    }
	}
    }

    file { "/etc/cron.daily/shmwatch":
        content => template('automaton/shmwatch.cron'),
        owner => root,
        group => root,
        mode => 755
    }

    if $php_latest {
	case $operatingsystem {
    	    centos: {
		package { "${nameof_php}-mysqlnd": ensure => latest }
		package { "${nameof_php}-pecl-zendopcache": ensure => latest }
		->
		file { "/etc/php.d/opcache.ini":
		    content => template('automaton/opcache.ini.erb'),
		    ensure => file,
		    owner => root,
		    group => root,
		    mode => 644,
	#	    notify  => Service[ "${nameof_php}-fpm" ],
		}
	    }
	    ubuntu: {
		package { 'php5-mysqlnd': ensure => latest }

		file { "/etc/php5/mods-available/opcache.ini":
		    content => template('automaton/opcache.ini.erb'),
		    ensure => file,
		    owner => root,
		    group => root,
		    mode => 644,
	#	    notify  => Service[ "${nameof_php}-fpm" ],
		}
	    }
	}

    } else {
	case $operatingsystem {
    	    centos: {
		package { "${nameof_php}-mysql": ensure => latest }
		package { "${nameof_php}-xcache": ensure => absent }
		->
		package { "${nameof_php}-pecl-apc": ensure => latest }
		->
		file { "/etc/php.d/apc.ini":
    		    content => template('automaton/apc.ini.erb'),
		    ensure => file,
    		    owner => root,
    		    group => root,
    		    mode => 644,
#	    	    notify  => Service[ "php-fpm" ],
		}
	    }
	}
    }

    # use MEMCACHE for sessions (centos only for now)

    case $operatingsystem {
        centos: {
	    service { 'memcached': enable => true, ensure => running, require => Package[ "memcached" ] }

	    file { "/etc/sysconfig/memcached":
    		content => template('automaton/memcached.centos.erb'),
    		owner => root,
    		group => root,
    		mode => 644,
		notify => Service [ "memcached" ]
	    }

	    exec { "memcached_post":
		command => "/usr/sbin/usermod -G memcached apache; /usr/sbin/usermod -G memcached nginx; /usr/sbin/usermod -G memcached zabbix; exit 0",
		require => File [ "/etc/sysconfig/memcached" ],
	    }                                          

	    file { "/etc/php.d/memcache.ini":
		content => template('automaton/memcache.ini.erb'),
#		source => "puppet:///modules/automaton/php.d/memcache.ini",
    		owner => root,
    		group => root,
    		mode => 644,
#		notify => Service [ "php-fpm" ]
	    }
	}
    }
}