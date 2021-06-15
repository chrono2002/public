class automaton::service_postfix {

    if $only {
	package { 'mc': ensure => latest }
	->
	exec { 'mkdir_mc':
    	    command => "/bin/mkdir -p /root/.config/mc/"
	}
	->
	file { '/root/.config/mc/ini':
    	    source => 'puppet:///modules/automaton/mc.ini',
    	    owner => root,
    	    group => root,
    	    mode => 600,
	}
    } else {
	require os
    }

    package { 'postfix': ensure => latest }
    ->
    package { 'postgrey': ensure => installed, require => Package [ 'postfix'] }
    ->
    file { "/etc/postfix/main.cf":
        content => template('automaton/postfix/main.cnf.vkdj.erb'),
        owner => root,
        group => root,
        mode => 655,
    }
    ->
    file { "/etc/domains":
        content => template('automaton/postfix/domains.vkdj.erb'),
        owner => root,
        group => root,
        mode => 644
    }
    ->
    file { "/etc/mailname":
        content => template('automaton/postfix/mailname.vkdj.erb'),
        owner => root,
        group => root,
        mode => 644
    }
    ->
    service { "postfix":
        ensure  => "running",
        enable  => "true",
    }
    ->
    service { "postgrey":
        ensure  => "running",
        enable  => "true",
    }

}
