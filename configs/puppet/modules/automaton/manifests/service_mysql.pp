class automaton::service_mysql {

    require os 

#    if $bootstrap { 
#	exec { "mysql_secure":
#    	    command => "/usr/bin/mysql -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')\" && mysql -e \"DELETE FROM mysql.user WHERE User=''\" && mysql -e \"DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'\" && mysql -e \"FLUSH PRIVILEGES\" && /usr/bin/mysqladmin password ${password_mysql} && /bin/echo -e \"[client]\\nuser='root'\\npass='${password_mysql}'\" > /root/.my.cnf",
#    	    unless  => "/usr/bin/test -f /root/.my.cnf",
#    	    require => Service [ "mysql" ],
#	}
#    }

    case $operatingsystem {
        centos: {
#	    $nameof_mysql = 'MariaDB'
	    $pathto_mysql_confd = '/etc/my.cnf.d'

           case $operatingsystemmajrelease {
               6: {
		    $nameof_mysql = 'MariaDB'
		    $nameof_mysql_service = 'mysql'

		    yumrepo { 'MariaDB':
    			baseurl  => 'http://yum.mariadb.org/5.5/centos6-amd64/',
    			enabled  => 1,
	    		gpgcheck => 1,
			gpgkey   => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
		    }

		    package { 'MariaDB-server': ensure => latest, require => Yumrepo["MariaDB"] }
		    package { 'MariaDB-client': ensure => latest, require => Yumrepo["MariaDB"] }

#		    service { 'mysql': enable => true, ensure => running, require => Package [ "MariaDB-server" ] }
		}
                7: {
		    $nameof_mysql = 'mariadb'
		    $nameof_mysql_service = 'mariadb'

		    package { 'mariadb-server': ensure => latest }
		    package { 'mariadb': ensure => latest }

#		    service { 'mariadb': enable => true, ensure => running, require => Package [ "mariadb-server" ] }
                }
            }
	    service { "$nameof_mysql_service": enable => true, ensure => running, require => Package [ "mariadb-server" ] }
	}
	debian, ubuntu: {
	    $nameof_mysql = 'mariadb'
	    $nameof_mysql_service = 'mysql'
	    $pathto_mysql_confd = '/etc/mysql/conf.d'

	    package { 'python-software-properties': ensure => latest }
	    ->
	    package { 'software-properties-common': ensure => latest }
	    ->
	    exec { "add_mariadb_repo":
		command => "/usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && add-apt-repository 'deb http://mirror.timeweb.ru/mariadb/repo/5.5/ubuntu precise main' && apt-get update",
		unless => "/bin/grep mariadb /etc/apt/sources.list"
	    } 
	    ->
	    package { 'mariadb-server': ensure => latest }

	    service { "$nameof_mysql_service": enable => true, ensure => running, require => Package [ "mariadb-server" ] }
#	    service { 'mysql': enable => true, ensure => running, require => Package [ "mariadb-server" ] }
	}
    }
    
    package { 'mysqltuner': ensure => latest }

    file { "$pathto_mysql_confd/fhs.cnf":
	content => template('automaton/my.cnf.erb'),
        owner => root,
        group => root,           
        mode => 644,
	require => Package [ "${nameof_mysql}-server" ]
    }
    ->
    exec { "mysql_post":
        command => "/etc/init.d ${nameof_mysql_service} stop && /bin/rm -f /var/lib/mysql/ib_logfile* && /etc/init.d/${nameof_mysql_service} start",
        unless  => "/usr/bin/test -f $pathto_mysql_confd/fhs.cnf",
	notify  => Service[ "$nameof_mysql_service" ]
    }

    file { "/etc/cron.weekly/mysql_optimize":
	source => 'puppet:///modules/automaton/mysql_optimize.cron',
        owner => root,
        group => root,
        mode => 755,
	require => Service [ "${nameof_mysql_service}" ]
    }

    file { "/tmp/fhs/mysql_myisam2innodb.sh":
        source => "puppet:///modules/automaton/mysql_myisam2innodb.sh",
        owner => root,
        group => root,
    }

}