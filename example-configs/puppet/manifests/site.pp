## site.pp ##

# DEFAULT NODE

node default {
    if $::bootstrap 	{ $bootstrap = 1 }
    if $::only		{ $only = 1 }
    if $::vps 		{ $vps = 1 }
    if $::vkdj 		{ $vkdj = 1 }

    if $::kvm		{ $service_kvm = 1 }
    if $::named		{ $service_named = 1 }
    if $::nginx		{ $service_nginx = 1 }
    if $::mysql		{ $service_mysql = 1 }
    if $::php		{ $service_php = 1 }
    if $::postgres	{ $service_postgres = 1 }
    if $::postfix	{ $service_postfix = 1 }
    if $::zabbix	{ $service_zabbix = 1 }
    
    if $::named_default_host	{ $named_default_host = $::named_default_host }
    if $::pwd_root		{ $password_root = $::pwd_root }

    case $operatingsystem {
        centos: {
	    $nameof_php = 'php'
	}
	debian, ubuntu: {
	    $nameof_php = 'php5'
	}
    }

    $php_latest = 1

    include automaton
}

node 'nginx.example' {
    $service_mysql = true
    $service_nginx = true
    $service_zabbix = true

    $user_www = 'apache'

    $vps = true

    include automaton
}

node 'kvm.example' {
    $service_kvm = true
    $service_nginx = true
    $service_zabbix = true

    include automaton
}

node 'db.example' {
    $service_postgres = true
    $service_zabbix = true

    $vkdj = true
    $vps = true

    include automaton
}

node 'php-fpm.example' {
    $service_mysql = true
    $service_nginx = true
    $service_php = true
    $php_latest = true
    $service_zabbix = true

    $dir_www = '/srv/www'
    $user_www = 'www-data'

    include automaton
}

node 'latest-php-fpm.example' {
    $php_latest = true
    $service_nginx = true
    $service_php = true
    $service_zabbix = true

    $vkdj = true
    $nameof_php = 'php54w'

    include automaton
}
