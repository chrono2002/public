class automaton::os {

    $nameof_ssh = $operatingsystem ? {
	centos	=> 'sshd',
	default	=> 'ssh',
    }

    case $operatingsystem {
	centos: {
	    package { 'GeoIP': ensure => latest }
	}
        debian, ubuntu: {
	    class { 'apt':
		always_apt_update    => true,
	    }
	}
    }

    require os_repos

# Install Packages

    package { 'lynx': ensure => latest }
    package { 'telnet': ensure => latest }
    package { 'wget': ensure => latest }
    package { 'ntp': ensure => latest }
    package { 'ntpdate': ensure => latest }
    package { 'sudo': ensure => latest }
    package { 'acpid': ensure => latest }
    package { 'rsyslog': ensure => latest }
    package { 'mc': ensure => latest }
    package { 'screen': ensure => latest }
    package { 'pigz': ensure => latest }
    package { 'sysstat': ensure => latest }	# iostat
    package { 'iotop': ensure => latest }
    package { 'nethogs': ensure => latest }	# monitors active connections
    package { 'memcached': ensure => latest }
    package { 'lsof': ensure => latest }
    package { 'gawk': ensure => latest }
    package { 'zip': ensure => latest }

    if $vkdj {
        package { 'subversion': ensure => latest }
    }

    # OBSOLETE -- install httpd by default

#    package { 'httpd': ensure => latest }
#    package { 'mod_rpaf': ensure => latest }

    case $operatingsystem {
        centos: {
	    case $operatingsystemmajrelease {
		6: {
		    package { 'man': ensure => latest }
		    package { 'bwm-ng': ensure => latest }	# monitors bandwidth

	            # security updates
        	    package { 'centos-release-cr': ensure => latest }
    		    package { 'yum-plugin-security': ensure => latest }
		}
                7: {
		    package { 'man-pages': ensure => latest }
		    package { 'bmon': ensure => latest }	# monitors bandwidth
		}
	    }
            package { 'audit': ensure => absent }
            package { 'yum-cron': ensure => latest }
            package { 'cronie': ensure => latest }
            package { 'conntrack-tools': ensure => latest }
            package { 'yum-utils': ensure => latest }

        }
        debian, ubuntu: {
            package { 'cron': ensure => latest }
            package { 'conntrack': ensure => latest }
        }
    }

# Disable Services

    case $operatingsystem {
        centos: {
	    case $operatingsystemmajrelease {
		6: {
		    service { 'auditd': enable => false, ensure => stopped }
		}
                7: {
		    service { 'firewalld': enable => false, ensure => stopped }
    		    service { 'NetworkManager': enable => false, ensure => stopped }
    		    service { 'wpa_supplicant': enable => false, ensure => stopped }
		}
	    }
            service { 'xinetd': enable => false, ensure => stopped }
            service { 'avahi-daemon': enable => false, ensure => stopped }
            service { 'pcscd': enable => false, ensure => stopped }
            service { 'haldaemon': enable => false, ensure => stopped }
            service { 'hidd': enable => false, ensure => stopped }
            service { 'xfs': enable => false, ensure => stopped }
            service { 'rpcidmapd': enable => false, ensure => stopped }
            service { 'cups': enable => false, ensure => stopped }
            service { 'bluetooth': enable => false, ensure => stopped }
            service { 'gpm': enable => false, ensure => stopped }
            service { 'autofs': enable => false, ensure => stopped }
            service { 'iscsi': enable => false, ensure => stopped }
            service { 'iscsid': enable => false, ensure => stopped }
            service { 'rpcbind': enable => false, ensure => stopped }
            service { 'ip6tables': enable => false, ensure => stopped }

	    if $bootstrap {
        	service { 'iptables': enable => false, ensure => stopped }
        	service { 'portmap': enable => false, ensure => stopped }
    		service { 'nfslock': enable => false, ensure => stopped }
    		service { 'messagebus': enable => false, ensure => stopped }
        	service { 'sendmail': enable => false, ensure => stopped }
        	service { 'postfix': enable => false, ensure => stopped }
	    }
        }
        debian: {
##            service { 'avahi-daemon': enable => false, ensure => stopped }
##            service { 'gdm3': enable => false, ensure => stopped }
#            service { 'rpcbind': enable => false, ensure => stopped }
##            service { 'minissdpd': enable => false, ensure => stopped }
##            service { 'pulseaudio': enable => false, ensure => stopped }
##            service { 'saned': enable => false, ensure => stopped }
##            service { 'statd': enable => false, ensure => stopped }
##            service { 'rpcbind': enable => false, ensure => stopped }

	    if $bootstrap {
##    	        service { 'exim4': enable => false, ensure => stopped }
##        	service { 'nfs-common': enable => false, ensure => stopped }
	    }
        }
        ubuntu: {
#            service { 'statd': enable => false, ensure => stopped }
#            service { 'rpcbind-boot': enable => false, ensure => stopped }
#            service { 'idmapd': enable => false, ensure => stopped }

	    if $bootstrap {
		service { 'apparmor': enable => false, ensure => stopped }
	    }
        }
    }

# Ensure Services
            
    case $operatingsystem {
        centos: {
            service { 'crond': enable => true, ensure => running, require => Package['cronie'] }
        }
        debian, ubuntu: {
            service { 'cron': enable => true, ensure => running, require => Package['cron'] }
        }
    }
            
    service { 'acpid': enable => true, ensure => running, require => Package['acpid'] }
    service { 'rsyslog': enable => true, ensure => running, require => Package['rsyslog'] }

    unless $vps {
        package { 'lvm2': ensure => latest }
        package { 'mdadm': ensure => latest }
	package { 'smartmontools': ensure => latest }
        
##        service { 'smartd': enable => true, ensure => running, require => Package [ "smartmontools" ] }
        
##        case $operatingsystem {
##            centos: {
##                service { 'mdmonitor': enable => true }
#		service { 'lvm2-monitor': enable => true, ensure => running }
##            }
##            debian, ubuntu: {
##                service { 'mdadm': enable => true, ensure => running, require => Package['mdadm'] }
##                service { 'mdadm-raid': enable => true, ensure => running, require => Package['mdadm'] }
#		service { 'lvm2': enable => true, ensure => running, require => Package['lvm2'] }
##            }
##	}
    }

# Initial Setup

    if $bootstrap {
	
	# Timezone

	package { "tzdata": ensure => latest }

	file { "/etc/localtime":
    	    source => "file:///usr/share/zoneinfo/posix/W-SU",
    	    owner => root,
    	    group => root,
    	    mode => 644,
    	    require => Package["tzdata"]
        }

	# Set root password

	if $password_root {
	    case $operatingsystem {
		centos: {
		    exec { "passwd":
    			command => "/bin/echo '${password_root}' | /usr/bin/passwd root --stdin",
    		    }
    		}
        
    		debian, ubuntu: {
        	    exec { "passwd":
            		command => "/bin/echo 'root:${root_password}' | /usr/sbin/chpasswd",
        	    }
		}
    	    }
	}
    }

    case $operatingsystem {
	centos: {
	    
	    # Date and time

            exec { ntpdate: command => '/usr/sbin/ntpdate pool.ntp.org; exit 0', unless  => "/usr/bin/test -f /var/lock/subsys/ntpd", require => Package['ntpdate'] }
	    ->
            service { 'ntpd': enable => true, ensure => running, require => Package['ntp'] }

	    # Disable SELinux

            class { 'selinux': mode => 'disabled' }
        }

	debian, ubuntu: {

	    # Date and time

            exec { ntpdate: command => '/usr/sbin/ntpdate pool.ntp.org', unless  => "/usr/sbin/service ntp status" }
            ->
            service { 'ntp': enable => true, ensure => running, require => Package['ntp'] }
	}
    }

    # Kernel tune
            
    include os_sysctl

    # Filesystem tune

    include os_fs

    # Misc

    exec { 'mkdir_mc':
        command => "/bin/mkdir -p /root/.config/mc/"
    }
    ->
    file { '/root/.config/mc/ini':
        source => 'puppet:///modules/automaton/mc.ini',
        owner => root,
        group => root,
        mode => 600,
        require => Exec [ 'mkdir_mc' ]
    }

    exec { "mkdir_www":
        command => "/bin/mkdir -p /www/tmp /www/default /www/backup /www/${ipaddress}; /bin/touch /www/default/index.html; /bin/echo ${ipaddress} >> /www/${ipaddress}/index.html; /bin/echo '<?php phpinfo(); ?>' > /www/default/test${secure_prefix}.php; chgrp ${user_www} /www; /bin/chmod 750 /www",
        unless => "/usr/bin/test -d /www",
    }

    exec { 'mkdir_fhs':
        command => "/bin/mkdir -p /tmp/fhs",
        unless => "/usr/bin/test -d /tmp/fhs"
    }
            
    service { $nameof_ssh: enable => true, ensure => running }

    file { "/etc/ssh/sshd_config":
        content => template('automaton/sshd_config.erb'),
        owner => root,
        group => root,
        mode => 644,
	notify => Service [ $nameof_ssh ],
    }

    file { "/etc/ssh/authorized_keys":
        source => "puppet:///modules/automaton/ssh/authorized_keys",
        ensure => directory,
        recurse => true,
	replace => false,
        owner => root,
        group => root,
	notify => Service [ $nameof_ssh ],
    }

}