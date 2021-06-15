# Install Repos
class automaton::os_repos {

#    Package {
#	require => [ 
#            Yumrepo[CentOS-CR],
#            Yumrepo[centosplus],
#            Yumrepo[epel-stable],
#	    Exec[yum_update]
#        ]
#    }
    
    case $operatingsystem {
        centos: {
	    case $operatingsystemmajrelease {
		6: {
	            yumrepo { "CentALT":
    		        enabled => 0,
        	    }
		    ->
        	    yumrepo { "contrib":
            		enabled => 1,
        	    }
		    ->
		    yumrepo { CentOS-CR:
			descr      => 'CentOS-$releasever - CR',
			baseurl	   => 'http://mirror.centos.org/centos/$releasever/cr/$basearch/',
			enabled    => 1,
			gpgcheck   => 1,
			gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6'
		    }
		    ->
		    yumrepo { centosplus:
			descr      => 'CentOS-$releasever - Plus',
			mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus',
			enabled    => 1,
			gpgcheck   => 1,
			gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6'
		    }
		}
		7: {
    		    yumrepo { "cr":
            		enabled => 1,
    		    }
		    -> 
    		    yumrepo { "fasttrack":
            		enabled => 1,
    		    }
		    -> 
    		    yumrepo { "centosplus":
            		enabled => 1,
    		    }
		}
	    }
	    ->
	    yumrepo { "epel-stable":
	        descr      => "CentOS EPEL (stable)",
	        mirrorlist => 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-$releasever&arch=$basearch',
	        enabled    => 1,
	        gpgcheck   => 1,
	        gpgkey     => "http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$operatingsystemmajrelease"
	    }
	    ->
	    exec { yum_update: command => '/usr/bin/yum -y update' }
	}
	debian, ubuntu: {
            exec { 'apt_update_my': command => "/usr/bin/apt-get -y update" }
            ->
            exec { 'apt_upgrade_my': command => "/usr/bin/apt-get -y upgrade" }
	}
    }    
}