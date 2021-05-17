class zloy::os_1ite {

  File { backup => ".def" }

  # -- Services management

  class services {

    # - Install common packages

    package { 'man': ensure => installed }
    package { 'lynx': ensure => installed }
    package { 'telnet': ensure => installed }
    package { 'wget': ensure => installed }
    package { 'ntp': ensure => installed }
    package { 'ntpdate': ensure => installed }
    package { 'sudo': ensure => installed }
    package { 'acpid': ensure => installed }
    package { 'rsyslog': ensure => installed }
    package { 'mc': ensure => installed }
    package { 'bwm-ng': ensure => installed }
    package { 'screen': ensure => installed }
    package { 'cron': ensure => installed }

    package { 'git': ensure => installed }
    package { 'redis-server': ensure => installed }

    package { 'python-software-properties': ensure => installed }
    ->
    package { 'python': ensure => installed }
    ->
    package { 'g++': ensure => installed }
    ->
    package { 'make': ensure => installed }
    ->
    exec { "nodejs_repo":
        command => "/usr/bin/add-apt-repository -y ppa:chris-lea/node.js"
    }
    ->
    exec { "redis_repo":
        command => "/usr/bin/add-apt-repository -y ppa:rwky/redis"
    }
    ->
    exec { "php54_repo":
        command => "/usr/bin/add-apt-repository -y ppa:ondrej/php5"
    }
    ->
    apt::source { 'nginx':
	location   => 'http://nginx.org/packages/ubuntu/',
	repos      => 'nginx',
	key	   => '7BD9BF62',
	key_source => 'http://nginx.org/keys/nginx_signing.key',
	before     => Exec [ 'apt_upgrade_my' ]
    }
    ->
    package { 'nginx': ensure => installed }
    ->
    exec { 'apt_update_my': command => "/usr/bin/apt-get -y update", timeout => 1800 }
    ->
    exec { 'apt_upgrade_my': command => "/usr/bin/apt-get -y upgrade", timeout => 1800 }
    ->    
    package { 'nodejs': ensure => installed }
    ->
    package { 'php5-common': ensure => installed }
    ->
    package { 'php5-cli': ensure => installed }
    ->
    package { 'php5': ensure => installed }
    ->
    package { 'php5-dev': ensure => installed }
    ->
    package { 'php5-gd': ensure => installed }
    ->
    package { 'php5-intl': ensure => installed }
    ->
    package { 'php5-curl': ensure => installed }
    ->
    package { 'php5-pgsql': ensure => installed }
    ->
    package { 'php5-mysql': ensure => installed }

    # - Disable services

    service { 'apparmor': enable => false, ensure => stopped }
#    service { 'statd': enable => false, ensure => stopped }
#    service { 'rpcbind-boot': enable => false, ensure => stopped }
#    service { 'idmapd': enable => false, ensure => stopped }
    service { 'dbus': enable => false, ensure => stopped }

    # - Ensure services

    service { 'cron': enable => true, ensure => running, require => Package['cron'] }
    service { 'acpid': enable => true, ensure => running, require => Package['acpid'] }
    service { 'rsyslog': enable => true, ensure => running, require => Package['rsyslog'] }

    case $vps {
	0: {
	    package { 'lvm2': ensure => installed }
	    package { 'smartmontools': ensure => installed }
	    package { 'mdadm': ensure => installed }

	    service { 'smartd': enable => true, ensure => running, require => Package['smartmontools'] }
    	    service { 'mdadm': enable => true, ensure => running, require => Package['mdadm'] }
    	    service { 'mdadm-raid': enable => true, ensure => running, require => Package['mdadm'] }
	    service { 'lvm2': enable => true, ensure => running, require => Package['lvm2'] }
	}

	1: {
	    package { 'smartmontools': ensure => absent }
	}
    }
  } 

  # -- System setup

  class setup {

    # - System tuning

    sysctl { "net.ipv6.conf.all.disable_ipv6": ensure => present, value  => "1" }
    sysctl { "net.ipv6.conf.default.disable_ipv6": ensure => present, value  => "1" }
    sysctl { "net.ipv4.ip_forward": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.default.rp_filter": ensure => present, value  => "1" }
    sysctl { "net.ipv4.conf.all.rp_filter": ensure => present, value  => "1" }
    sysctl { "net.ipv4.conf.all.accept_source_route": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.default.accept_source_route": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.all.accept_redirects": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.default.accept_redirects": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.all.send_redirects": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.default.send_redirects": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.all.secure_redirects": ensure => present, value  => "0" }
    sysctl { "net.ipv4.conf.default.secure_redirects": ensure => present, value  => "0" }
    sysctl { "kernel.sysrq": ensure => present, value  => "0" }
    sysctl { "net.ipv4.tcp_syncookies": ensure => present, value  => "1" }
    sysctl { "net.ipv4.conf.default.log_martians": ensure => present, value  => "0" }
    sysctl { "net.ipv4.icmp_echo_ignore_all": ensure => present, value  => "0" }
    sysctl { "net.ipv4.icmp_ignore_bogus_error_responses": ensure => present, value  => "1" }
    sysctl { "net.ipv4.icmp_echo_ignore_broadcasts": ensure => present, value  => "1" }

    sysctl { "vm.swappiness": ensure => present, value  => "0" }
    sysctl { "vm.dirty_ratio": ensure => present, value  => "2" }
    sysctl { "vm.dirty_background_ratio": ensure => present, value  => "1" }
    sysctl { "kernel.msgmnb": ensure => present, value  => "65536" }
    sysctl { "kernel.msgmax": ensure => present, value  => "65536" }
    sysctl { "kernel.shmmax": ensure => present, value  => "68719476736" }
    sysctl { "kernel.shmall": ensure => present, value  => "4294967296" }
    sysctl { "net.ipv4.tcp_max_syn_backlog": ensure => present, value  => "262144" }
    sysctl { "net.ipv4.tcp_rmem": ensure => present, value  => "4096 87380 33554432" }
    sysctl { "net.ipv4.tcp_wmem": ensure => present, value  => "4096 87380 33554432" }
    sysctl { "fs.file-max": ensure => present, value  => "65535" }
    sysctl { "net.ipv4.tcp_window_scaling": ensure => present, value  => "1" }
    sysctl { "kernel.pid_max": ensure => present, value  => "65535" }
    sysctl { "net.core.wmem_max": ensure => present, value  => "33554432" }
    sysctl { "net.core.netdev_max_backlog": ensure => present, value  => "5000" }
    sysctl { "net.core.somaxconn": ensure => present, value  => "65535" }
    sysctl { "net.core.rmem_max": ensure => present, value  => "33554432" }
    sysctl { "net.ipv4.ip_local_port_range": ensure => present, value  => "2000 65000" }
    sysctl { "net.nf_conntrack_max": ensure => present, value  => "262140" }

    # - Set timezone

    package { "tzdata": ensure => installed }

    file { "/etc/localtime":
	source => "file:///usr/share/zoneinfo/Europe/Moscow",
	owner => root,
	group => root,
	mode => 644,
    	require => Package["tzdata"]
    }

    # - Set date and time
        
    exec { ntpdate: command => '/usr/sbin/ntpdate pool.ntp.org', unless  => "/usr/sbin/service ntp status" }
    ->
    service { 'ntp': enable => true, ensure => running, require => Package['ntp'] }
	    
    # - Set hostname

    host { "${host}":
	ip => "${ip}"
    }

    exec { "hostname_save":
        command => "/bin/echo ${host} > /etc/hostname",
        unless  => "/bin/grep ${host} /etc/hostname",
    }

    # - Set root password

#    exec { "passwd":
#        command => "/bin/echo 'root:${root_password}' | /usr/sbin/chpasswd"
#    }

    exec { "hostname_set":
        command => "/bin/hostname ${host}",
        unless  => "/usr/bin/test `/bin/hostname` = '${host}'",
    }

    # - Misc

    exec { 'mkdir_mc':
        command => "/bin/mkdir -p /root/.config/mc/"
    }
    ->
    file { '/root/.config/mc/ini':
        source => 'puppet:///modules/zloy/mc.ini',
	owner => root,
	group => root,
	mode => 600,
	require => Exec [ 'mkdir_mc' ]
    }

    exec { "fstab_tune_ext34":
        command => "/bin/sed -i~ 's/ext4.*defaults/ext4 defaults,noatime,nodiratime,nobarrier,journal_async_commit,delalloc,nobh,commit=600,nouser_xattr,noacl/' /etc/fstab; /bin/sed -i~ 's/ext3.*defaults/ext3 defaults,noatime,nodiratime,nobarrier,commit=600,nouser_xattr,noacl/' /etc/fstab && /bin/mount -o remount /",
        unless => "/bin/grep nodiratime /etc/fstab"
    }

    exec { "fstab_disable_swap":
        command => "/bin/sed -i~ '/swap/s/^/#/' /etc/fstab && /sbin/swapoff -a",
        unless => "/bin/egrep '#.*swap' /etc/fstab"
    }

    # - strict SSH

    file { "/etc/ssh/sshd_config":
        content => template('zloy/sshd_config.erb'),
        owner => root,
        group => root,
        mode => 644,
    }

    file { "/etc/ssh/ssh_config":
	source => "puppet:///modules/zloy/ssh_config",
        owner => root,
        group => root,
        mode => 644,
    }
	
    exec { "sudoers_fix":
        command => "/bin/sed -i~ 's/#.*%wheel.*NOPASSWD.*/%wheel	ALL=(ALL)	NOPASSWD: ALL/' /etc/sudoers"
    }
  }

  class install {
    class { 'services': } -> class { 'setup': }
  }

  class { install: }
}
