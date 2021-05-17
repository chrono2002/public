class automaton::service_postgres {

    require os

    yumrepo { 'pgdg95':
        baseurl  => 'http://yum.postgresql.org/9.5/redhat/rhel-$releasever-$basearch',
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => 'https://apt.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-95'
    }

    package { 'postgresql95-server': ensure => latest, require => Yumrepo["pgdg95"] }
    package { 'postgresql95-devel': ensure => latest, require => Yumrepo["pgdg95"] }
    package { 'postgresql95-contrib': ensure => latest, require => Yumrepo["pgdg95"] }

#    package { 'phpPgAdmin': ensure => latest }

    exec { postgres_initdb:
	command => '/usr/bin/su postgres -c "/usr/pgsql-9.5/bin/initdb -D /var/lib/pgsql/9.5/data"',
	unless  => "/usr/bin/test -f /var/lib/pgsql/9.5/data/postgresql.conf",
	require => Package [ "postgresql95-server" ]
    }
    ->
    file { "/var/lib/pgsql/9.5/data/postgresql.conf":
        source => "puppet:///modules/automaton/postgresql/postgresql.conf",
        owner => postgres,
        group => postgres,
        mode => 600,
    }
    ->
    service { "postgresql-9.5":
	ensure  => "running",
	enable  => "true",
    }
    -> 
    file { "/tmp/fhs/postgresql.sql":
        content => template('automaton/postgresql/postgresql.sql.erb'),
        owner => root,
        group => postgres,
        mode => 640,
    }
    ->
    exec { postgresql_setpw:
	command => '/bin/su postgres -c "psql -U postgres template1 < /tmp/fhs/postgresql.sql" && /bin/su postgres -c "psql -U postgres postgres < /tmp/fhs/postgresql.sql" && /bin/touch /tmp/fhs_postgresql',
	unless  => "/usr/bin/test -f /tmp/zloy_postgresql"
    }
    ->
    file { "/var/lib/pgsql/.pgpass":
	content => template('automaton/postgresql/.pgpass.erb'),
	owner => postgres,
	group => postgres,
	mode => 600
    }
    ->
    file { "/root/.pgpass":
	content => template('automaton/postgresql/.pgpass.erb'),
	owner => root,
	group => root,
	mode => 600
    }
    ->
    file { "/var/lib/pgsql/9.5/data/pg_hba.conf":
        source => "puppet:///modules/automaton/postgresql/pg_hba.conf",
        owner => postgres,
        group => postgres,
        mode => 600,
    }
    ->
    exec { "postgresql_restart":
        command => "/sbin/service postgresql-9.5 restart",
    }

#    ->
#    file { "/usr/share/phpPgAdmin/conf/config.inc.php":
#        source => "puppet:///modules/zloy/phpPgAdmin/config.inc.php",
#        owner => root,
#        group => root,
#        mode => 644,
#    }
#    ->
#    case $is_web {
#        1: {
#	    package { 'php-pgsql': ensure => latest }
#	    ->
#	    exec { "phpfpm_restart":
#	        command => "/sbin/service php-fpm restart",
#	    }
#        }
#    }

}
