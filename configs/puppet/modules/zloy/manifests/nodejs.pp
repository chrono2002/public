class zloy::nodejs {

    class services {

        package { 'bind9': ensure => installed }
	package { 'bind9utils': ensure => installed }
	package { 'postfix': ensure => installed }

    } # -- end of class

    class setup {

#    service { "php-fpm": enable  => "false" }
    service { "redis-server": enable  => "true" }
    package { 'php5-fpm': ensure => absent }

    # - NGINX

	file { "/etc/nginx/nginx.conf":
    	    content => template('zloy/nginx.conf.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package [ "nginx" ],
	}
        ->
	file { "/etc/nginx/easy-rsa":
	    source => "puppet:///modules/zloy/nginx/easy-rsa",
	    ensure => directory,
	    recurse => true,
	    owner => root,
	    group => root,
	    require => Package [ "nginx" ]
	}
	->
	exec { "nginx_post":
    	    command => "/bin/mkdir /etc/nginx/keys && /bin/touch /etc/nginx/keys/index.txt && echo 00 > /etc/nginx/keys/serial; cd /etc/nginx/easy-rsa; . ./vars; ./build-dh; ./build-ca; ./build-key-server server",
    	    require => File [ "/etc/nginx/nginx.conf" ],
	    unless  => "/usr/bin/test -d /etc/nginx/keys",
	}
	->
	service { "nginx":
#    	    ensure  => "running",
	    enable  => "true",
#	    require => [ Package[ "nginx" ] ]
	}

	# -- BACKUP
  
	file { '/etc/cron.daily/backup.rb':
    	    source => 'puppet:///modules/zloy/backup.rb',
	    owner => root,
	    group => root,
	    mode => 755,
	}

	# - NAMED

	file { '/etc/bind/named.conf':
	    content => template('zloy/named.conf.erb'),
	    owner => root,
	    group => bind,
	    mode => 644,
	    require => Package [ 'bind9' ]
	}
	->
	file { "/etc/bind/${host}":
	    content => template('zloy/named.zone.erb'),
	    owner => root,
	    group => root,
	    mode => 644,
	}
	->
	service { "bind9":
	    ensure  => "running",
	    enable  => "true",
	}

	# - POSTFIX

	file { "/etc/aliases":
	    content => template('zloy/postfix/aliases.erb'),
    	    owner => root,
    	    group => root,
	    mode => 644,
    	    backup => ".def"
	}

	file { "/etc/postfix/main.cf":
	    content => template('zloy/postfix/main.cf.erb'),
	    owner => root,
	    group => root,
	    mode => 644,
	}
	->
	file { "/etc/postfix/master.cf":
	    content => template('zloy/postfix/master.cf.erb'),
	    owner => root,
	    group => root,
	    mode => 644,
	}
	->
	exec { "postmap":
    	    command => "/usr/sbin/postmap /etc/aliases"
	}

	# Add SSH cert

        exec { "ssh_auth":
            command => "/bin/mkdir /etc/ssh/authorized_keys /etc/skel/logs /www /etc/nginx/sites; true"
        }
	->
        file { '/etc/ssh/authorized_keys/root':
            source => 'puppet:///modules/zloy/authorized_key',
            owner => root,
            group => root,
            mode => 644,
        }

        file { '/nodejs.sh':
            source => 'puppet:///modules/zloy/nodejs.sh',
            owner => root,
            group => root,
            mode => 755,
        }

        file { '/etc/init/nodejs.conf':
            source => 'puppet:///modules/zloy/nodejs.conf',
            owner => root,
            group => root,
            mode => 644,
        }

        file { '/etc/logrotate.d/nodejs':
            source => 'puppet:///modules/zloy/nodejs.logrotate',
            owner => root,
            group => root,
            mode => 644,
        }

        file { '/etc/redis/redis.conf':
            source => 'puppet:///modules/zloy/redis.conf',
            owner => root,
            group => root,
            mode => 644,
        }

        file { '/etc/redis/redis2.conf':
            source => 'puppet:///modules/zloy/redis2.conf',
            owner => root,
            group => root,
            mode => 644,
        }

	exec { "redis_startup":
    	    command => '/bin/echo -e "#!/bin/sh -e\n/usr/bin/redis-server /etc/redis/redis2.conf\nexit 0" > /etc/rc.local; /bin/mkdir /var/lib/redis/2; /bin/chown redis:redis /var/lib/redis/2',
	    unless  => "/bin/grep redis /etc/rc.local"
	}

        file { '/backupredis.sh':
            source => 'puppet:///modules/zloy/backupredis.sh',
            owner => root,
            group => root,
            mode => 755,
        }

        file { '/backupredis.rb':
            source => 'puppet:///modules/zloy/backupredis.rb',
            owner => root,
            group => root,
            mode => 755,
        }

	file { "/root/.ssh":
            source => "puppet:///modules/zloy/.ssh",
            ensure => directory,
            purge => true,
            recurse => true,
            owner => root,
            group => root,
#            mode => 644,
	}
	->
        exec { "ssh_perm":
            command => "/bin/chmod 600 /root/.ssh/id_rsa; true"
        }

	cron { backupredis:
	    command => "/backupredis.sh",
	    user    => root,
	    hour    => 6,
	    minute  => 0
	}	

	cron { backupredis2:
	    command => "/backupredis.sh",
	    user    => root,
	    hour    => 18,
	    minute  => 0
	}	

    } # -- end of class

    class install {

	class { zloy::os_1ite::install: } 
        -> 
	class { 'services': } 
	-> 
	class { 'setup': }

    } # -- end of class

    class { install: }

}
