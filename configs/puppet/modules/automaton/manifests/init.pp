class automaton {
    Exec {
	timeout => 1800
    }

    File { backup => ".pre_fhs" }

    if versioncmp($::puppetversion,'3.6.1') >= 0 {
        $allow_virtual_packages = hiera('allow_virtual_packages',false)

        Package {
            allow_virtual => $allow_virtual_packages,
        }
    }

    $secure_prefix = 711

    unless $dir_www { $dir_www = "/www" }
    unless $user_www { $user_www = "nginx" }

    $password_mysql             = 'password'
    $password_postgres          = 'password'

    if ($operatingsystemmajrelease == 7) {
	$php_fpm_socket = '/run/php-fpm/php-fpm.sock'
    } else {
        $php_fpm_socket = '/tmp/php-fpm.sock'
    }

    case $operatingsystem {
        centos: {
	    $fpm_dir = '/etc/php-fpm.d'
        }
        ubuntu: {
	    $fpm_dir = '/etc/php-fpm.d'
        }
        debian: {
	    $fpm_dir = '/etc/php5/fpm/pool.d'
        }
    }

    # doesn't work
#    if ($php_latest) {
#        $nameof_php = 'php54w'
#    } else {
#        $nameof_php = $operatingsystem ? {
#    	    centos  => 'php',
#            default => 'php5'
#        }
#    }

    unless $only { include os }

#    if ($iptables) { include os_iptables }
    if ($service_kvm) { include service_kvm }
    if ($service_named) { include service_named }
    if ($service_nginx) { include service_nginx }
    if ($service_mysql) { include service_mysql }
    if ($service_php) { include service_php }
    if ($service_postgres) { include service_postgres }
    if ($service_postfix) { include service_postfix }
    if ($service_zabbix) or ($zabbix_only) { include service_zabbix }
}
