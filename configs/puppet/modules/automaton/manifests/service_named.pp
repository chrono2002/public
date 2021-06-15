class automaton::service_named {

    if $named_default_host {
	$domain = $named_default_host
    } else {
	$domain = $fqdn
    }

    case $operatingsystem {
        centos: {
            $nameof_named = 'named'
	    $nameof_named_user = 'named'
	    $nameof_named_package = 'bind'

            package { 'bind': ensure => installed }
            package { 'bind-utils': ensure => installed }

	}
	debian, ubuntu: {
            $nameof_named = 'bind9'
	    $nameof_named_user = 'bind'
	    $nameof_named_package = 'bind9'
	    $nameof_named_configpath = '/etc/bind/named.conf'

            package { 'bind9': ensure => installed }
	}
    }
    ->
    service { $nameof_named:
	ensure  => "running",
	enable  => "true",
#	require => Package [ $nameof_named_package ]           
    }
#    ->
    file { $nameof_named_configpath:
        content => template('automaton/named.conf.erb'),
        owner => root,
        group => $nameof_named_user,
        mode => 640,
        require => Package [ $nameof_named_package ],
#	notify => Service [ $nameof_named ]
    }
    ->
    file { "/etc/bind/${domain}":
        content => template('automaton/named.zone.erb'),
        owner => root,
        group => root,
        mode => 644,
#        require => Package [ $nameof_named_package ],
	notify => Service [ $nameof_named ]
    }
}