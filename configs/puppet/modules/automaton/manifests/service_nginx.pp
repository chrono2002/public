class automaton::service_nginx {
    
    require os

    if $bootstrap {
	service { 'nginx': 
	    enable => true, 
	    ensure => running,
	    require => Package["nginx"],
	}

	file { "/etc/nginx/nginx.conf":
    	    content => template('automaton/nginx.conf.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => [ Package [ "nginx" ], Exec [ "nginx_post" ], File [ "/etc/nginx/nginx_fhs.conf" ] ],
	    notify => Service["nginx"],
	}

	# SSL

	file { "/etc/nginx/easy-rsa":
    	    source => "puppet:///modules/automaton/nginx/easy-rsa",
    	    ensure => directory,
    	    recurse => true,
    	    owner => root,
    	    group => root,
    	    require => Package [ "nginx" ]
	}
	->
	exec { "nginx_post":
    	    command => "/bin/mkdir /etc/nginx/keys && /bin/touch /etc/nginx/keys/index.txt && echo 00 > /etc/nginx/keys/serial; cd /etc/nginx/easy-rsa; . ./vars; ./build-dh; ./build-ca; ./build-key-server server",
    	    unless  => "/usr/bin/test -d /etc/nginx/keys",
	}
    } else {
	file { "/tmp/fhs/nginx.conf":
    	    content => template('automaton/nginx.conf.erb'),
    	    owner => root,
    	    group => root,
    	    mode => 644,
	}
    }

    case $operatingsystem {
        centos: {
	    $osver = split($::operatingsystemrelease, '[.]')

	    yumrepo { 'nginx':
		descr    => 'Nginx official release packages',
		baseurl  => "http://nginx.org/packages/mainline/centos/${osver[0]}/\$basearch/",
		enabled  => 1,
		gpgcheck => 0,
		priority => 1,
	    }
	}
	ubuntu: {
	    apt::source { 'nginx':
        	location   => 'http://nginx.org/packages/ubuntu/',
        	repos      => 'nginx',
        	key        => '7BD9BF62',
        	key_source => 'http://nginx.org/keys/nginx_signing.key',
            }
	}
    }
    ->
    package { 'nginx': 
    	ensure => latest,
    }

    file { "/etc/nginx/sql.rules":
        source => 'puppet:///modules/automaton/nginx/sql.rules',
        owner => root,
        group => root,
        mode => 644,
    }

    file { "/etc/nginx/nginx_fhs.conf":
        content => template('automaton/nginx_fhs.conf.erb'),
	owner => root,
	group => root,
	mode => 644,
	require => Package [ "nginx" ]
#    	require => File ["/etc/nginx/nginx.conf"],
#	notify => Service["nginx"],
#	tag => ['update']
    }
}
