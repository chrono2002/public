class automaton::service_kvm {

    require os

    if $bootstrap {
	exec { "kvm_post":
    	    command => "/bin/chown root:kvm /dev/kvm; /bin/chmod 0660 /dev/kvm; chkconfig messagebus on; service messagebus start",
	    require => [ Package [ "libvirt" ], Package [ "qemu-kvm" ] ]
	}
	->
	exec { "kvm_module":
    	    command => "/sbin/modprobe kvm-intel",
	}
	->
	service { 'libvirtd': enable => true, ensure => running }
	->
	service { 'ksm': enable => false, ensure => stopped }
	->
	service { 'ksmtuned': enable => false, ensure => stopped }
    }

    yumrepo { 'xen-c6-RC1':
        descr    => 'CentOS-$releasever - Xen',
        baseurl  => "http://dev.centos.org/centos/6/xen-c6-RC1/\$basearch/",
        enabled  => 1,
        gpgcheck => 0
    }
    ->
    exec { yum_update_kvm: command => '/usr/bin/yum -y update' }

    package { 'qemu-kvm': ensure => latest, require => Yumrepo["xen-c6-RC1"] }
    package { 'qemu-kvm-tools': ensure => latest, require => Yumrepo["xen-c6-RC1"] }
    package { 'xorg-x11-xauth': ensure => latest }
    package { 'virt-manager': ensure => latest }
    package { 'dejavu-lgc-sans-fonts': ensure => latest }
    package { 'libvirt': ensure => latest, require => Yumrepo["xen-c6-RC1"] }
    package { 'libguestfs-tools': ensure => latest, require => Yumrepo["xen-c6-RC1"] }
    package { 'virt-top': ensure => latest, require => Yumrepo["xen-c6-RC1"] }
}