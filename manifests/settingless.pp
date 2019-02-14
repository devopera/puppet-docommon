class docommon::settingless {

  # before we really get going, make sure the base packages are up-to-date
  case $operatingsystem {
    centos, redhat, fedora: {
      exec { 'up-to-date' :
        command => '/usr/bin/yum -y update --skip-broken',
        timeout => (20*60),
      }
    }
    ubuntu, debian: {
      exec { 'up-to-date' :
        command => '/usr/bin/apt-get -y update && /usr/bin/apt-get -y upgrade && /usr/bin/apt-get -y dist-upgrade',
        timeout => (20*60),
      }
    }
  }

  # update rkhunter after updating rpms
  if defined(Class['dorkhunter']) {
    Exec <| title == 'up-to-date' |> ~> Exec <| title == 'init_rkunter_db' |>
    Exec <| title == 'docommon-settingless-prelink-exceptions' |> ~> Exec <| title == 'init_rkunter_db' |>
  }

  # delay all package installs until we've updated the package manager(s)
  Package <||> {
    require => [Exec['up-to-date']],
  }

  # install basic management packages
  if ! defined(Package['prelink']) {
    package { 'prelink' : ensure => present }
  }
  if ! defined(Package['policycoreutils']) {
    package { 'policycoreutils' : ensure => present }
  }  
  if ! defined(Package['mlocate']) {
    package { 'mlocate' : ensure => present }
  }  
  if ! defined(Package['htop']) {
    package { 'htop' : ensure => present }
  }
  if ! defined(Package['iftop']) {
    package { 'iftop' : ensure => present }
  }  
  if ! defined(Package['iotop']) {
    package { 'iotop' : ensure => present }
  }
  if ! defined(Package['expect']) {
    package { 'expect' : ensure => present }
  }
  if ! defined(Package['dos2unix']) {
    package { 'dos2unix' : ensure => present }
  }  
  if ! defined(Package['wget']) {
    package { 'wget' : ensure => present }
  }  
  if ! defined(Package['lynx']) {
    package { 'lynx' : ensure => present }
  }  
  if ! defined(Package['net-tools']) {
    package { 'net-tools' : ensure => present }
  }  
  if ! defined(Package['gawk']) {
    package { 'gawk' : ensure => present }
  }
  if ! defined(Package['zip']) {
    package { 'zip' : ensure => present }
  }
  if ! defined(Package['screen']) {
    package { 'screen' : ensure => present }
  }

  notify { "incaseyouwere in doubt the os = $operatingsystem" : }

  # OS-specific variants
  case $operatingsystem {
    centos, redhat, fedora: {
      if ($::architecture == 'x86_64') {
        # epel module only copes with x86
        include 'epel'
        # no kernel-devel on arm
        if ! defined(Package['kernel-devel']) {
          package { 'kernel-devel' : ensure => present }
        }
      }
      if ! defined(Package['system-config-firewall-tui']) {
        package { 'system-config-firewall-tui' : ensure => present }
      }
      if ! defined(Package['policycoreutils-gui']) {
        package { 'policycoreutils-gui' : ensure => present }
      }
      if ! defined(Package['openssh-clients']) {
        package { 'openssh-clients' : ensure => present }
      }
      if ! defined(Package['yum-utils']) {
        package { 'yum-utils' : ensure => present }
      }
      if ! defined(Package['vim-enhanced']) {
        package { 'vim-enhanced' : ensure => present }
      }
      if ! defined(Package['ack']) {
        package { 'ack' : ensure => present }
      }
      if ! defined(Package['crontabs']) {
        package { 'crontabs' : ensure => present }
      }
      # clean up old kernels
      exec { 'old-kernel-clean-up' :
        path => '/bin:/usr/bin/',
        command => 'package-cleanup -y --oldkernels --count=2',
        timeout => 1800,
        require => [Exec['up-to-date'], Package['yum-utils']],
      }
      # install kernel bits
      if ! defined(Package['kernel-headers']) {
        package { 'kernel-headers' : ensure => present }
      }      
      # tell chkconfig to disable firstboot as we don't need it
      service { 'firstboot' :
        enable => false,
        ensure => false,
      }
      # version-specific variants
      case $operatingsystemmajrelease {
        '7': {
          if ! defined(Package['nmap-ncat']) {
            package { 'nmap-ncat' : ensure => present }
          }
          # NetworkManager has now replaced system-config-network as of CO7 (both in CO6)
          if ! defined(Package['NetworkManager']) {
            package { 'NetworkManager' : ensure => present }
          }
        }
        '6', default: {
          if ! defined(Package['nc']) {
            package { 'nc' : ensure => present }
          }
          if ! defined(Package['system-config-network-tui']) {
            package { 'system-config-network-tui' : ensure => present }
          }
        }
      }
    }
    ubuntu, debian: {
      if ! defined(Package['linux-kernel-headers']) {
        package { 'linux-kernel-headers' : ensure => present }
      }      
      if ! defined(Package['gawk']) {
        package { 'gawk' : ensure => present }
      }
      if ! defined(Package['ack-grep']) {
        package { 'ack-grep' : ensure => present }
      }
      if ! defined(Package['acl']) {
        package { 'acl' : ensure => present }
      }      
      if ! defined(Package['vim']) {
        package { 'vim' : ensure => present }
      }
      if ! defined(Package['netcat']) {
        package { 'netcat' : ensure => present }
      }
      if ! defined(Package['prelink']) {
        package { 'prelink' : 
          ensure => present,
          before => [Anchor['docommon-settingless-prelink-ready']],
        }
      }      
      case $operatingsystemmajrelease {
        '14.04', default: {
          if ! defined(Package['ruby']) {
            package { 'ruby' : ensure => present }
          }
        }
        '12.04': {
          if ! defined(Package['rubygems']) {
            package { 'rubygems' : ensure => present }
          }
        }
      }
      # SELinux not supported on Ubuntu
      # package { ['selinux','selinux-utils'] :
      #   ensure => 'present',
      #   require => Exec['up-to-date'],
      # }
    }
  }
  
  # cases where Fedora and Redhat derivatives differ
  case $operatingsystem {
    centos, redhat: {
      # version-specific variants
      case $operatingsystemmajrelease {
        '7': {
          if ! defined(Package['man-db']) {
            package { 'man-db' : ensure => present }
          }
        }
        '6', default: {
          if ! defined(Package['man']) {
            package { 'man' : ensure => present }
          }
        }
      }
    }
    ubuntu, debian: {
      if ! defined(Package['man']) {
        package { 'man' : ensure => present }
      }
    }
    fedora: {
      if ! defined(Package['acl']) {
        package { 'acl' : ensure => present }
      }
      if ! defined(Package['iptables-services']) {
        package { 'iptables-services' : ensure => present }
      }
      if ! defined(Package['policycoreutils-python']) {
        package { 'policycoreutils-python' : ensure => present }
      }
      if ! defined(Package['man-db']) {
        package { 'man-db' : ensure => present }
      }
    }
  }

  # install git, svn
  if ! defined(Package['git']) {
    package { 'git' : ensure => present }
  }
  # @todo remove, deprecated
  #if ! defined(Package['subversion']) {
  #  package { 'subversion' : ensure => present }
  #}
  if ! defined(Package['mercurial']) {
    package { 'mercurial' : ensure => present }
  }

}
