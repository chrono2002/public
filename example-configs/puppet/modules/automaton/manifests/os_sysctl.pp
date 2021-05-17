# -- Kernel tune

class automaton::os_sysctl {

    if $bootstrap {
	sysctl { "net.ipv4.ip_forward": ensure => present, value  => "0" }
    }

    sysctl { "net.ipv6.conf.all.disable_ipv6": ensure => present, value  => "1" }
    sysctl { "net.ipv6.conf.default.disable_ipv6": ensure => present, value  => "1" }
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

# 4databases
#    sysctl { "vm.dirty_ratio": ensure => present, value  => "2" }
#    sysctl { "vm.dirty_background_ratio": ensure => present, value  => "1" }

# 4non-critical
#    sysctl { "vm.dirty_background_ratio": ensure => present, value  => "50" }
#    sysctl { "vm.dirty_ratio": ensure => present, value  => "80" }

# tradeoff
    sysctl { "vm.dirty_ratio": ensure => present, value  => "5" }
    sysctl { "vm.dirty_background_ratio": ensure => present, value  => "5" }

    sysctl { "vm.swappiness": ensure => present, value  => "0" }

    sysctl { "kernel.msgmnb": ensure => present, value  => "65536" }
    sysctl { "kernel.msgmax": ensure => present, value  => "65536" }
    sysctl { "kernel.shmmax": ensure => present, value  => "68719476736" }
    sysctl { "kernel.shmall": ensure => present, value  => "4294967296" }
    sysctl { "net.ipv4.tcp_max_syn_backlog": ensure => present, value  => "262144" }
    sysctl { "net.ipv4.tcp_rmem": ensure => present, value  => "4096 87380 33554432" }
    sysctl { "net.ipv4.tcp_wmem": ensure => present, value  => "4096 87380 33554432" }
    sysctl { "fs.file-max": ensure => present, value  => "1024000" }
    sysctl { "net.ipv4.tcp_window_scaling": ensure => present, value  => "1" }
    sysctl { "kernel.pid_max": ensure => present, value  => "65535" }
    sysctl { "net.core.wmem_max": ensure => present, value  => "33554432" }
    sysctl { "net.core.netdev_max_backlog": ensure => present, value  => "30000" }
    sysctl { "net.core.somaxconn": ensure => present, value  => "65535" }
    sysctl { "net.core.rmem_max": ensure => present, value  => "33554432" }
    sysctl { "net.ipv4.ip_local_port_range": ensure => present, value  => "2000 65000" }

    sysctl { "net.ipv4.tcp_tw_reuse": ensure => present, value  => "1" }
    sysctl { "net.ipv4.tcp_tw_recycle": ensure => present, value  => "1" }
    sysctl { "net.ipv4.tcp_max_tw_buckets": ensure => present, value  => "2000000" }
    
    # set 10 for low latency
    sysctl { "net.ipv4.tcp_fin_timeout": ensure => present, value  => "30" }

    sysctl { "net.ipv4.tcp_slow_start_after_idle": ensure => present, value  => "0" }
#    sysctl { "net.ipv4.tcp_low_latency": ensure => present, value  => "1" }


# 4 database & kvm
#    sysctl { "vm.overcommit_memory": ensure => present, value => "2" }
#    sysctl { "vm.overcommit_ratio": ensure => present, value => "80" }

#    sysctl { "net.netfilter.nf_conntrack_generic_timeout": ensure => present, value => "60" }
#    sysctl { "net.netfilter.nf_conntrack_tcp_timeout_time_wait": ensure => present, value => "30" }
#    sysctl { "net.netfilter.nf_conntrack_tcp_timeout_established": ensure => present, value  => "600" }
#    sysctl { "net.netfilter.nf_conntrack_buckets": ensure => present, value  => "65536" }
#    sysctl { "net.nf_conntrack_max": ensure => present, value  => "262144" }

}
