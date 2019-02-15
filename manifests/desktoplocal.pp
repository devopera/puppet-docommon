class docommon::desktoplocal (
  
  # type arguments
  # ---------------
  # setup defaults

  $user = 'web',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # OS-specific variants
  case $operatingsystem {
    centos, redhat, fedora: {
      # install desktop using groups (takes a long time)
      exec { "install-desktoplocal-${title}" :
        command => '/usr/bin/yum -y groupinstall "GNOME Desktop" "Graphical Administration Tools"',
        timeout => 60*60,
        require => Exec['up-to-date'],
      }

      # start desktop on system startup
      exec { "docommon-desktoplocal-service-symlink" :
        path => '/bin:/sbin:/usr/bin:/usr/sbin',
        command => 'ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target',
      }

      if ! defined(Package['freerdp']) {
        package { 'freerdp' : ensure => present }
      }

    }
    ubuntu, debian: {

    }
  }


}
