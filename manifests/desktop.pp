#
# DEPRECATED - use desktopvnc.pp
# This class has been deprecated in favour of a defined type
# docommon::desktopvnc()
# Please factor this out of your code.  It will not exist in future versions.
#
class docommon::desktop (
  
  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $password = 'admLn**',
  $resolution = '1024x768',
  $packagekit_enable = '0',
  $firewall = false,
  $port = 5901,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # expose firewall ports if requested
  if ($firewall) {
    # can expose port (insecure), or can tunnel over SSH ($firewall = false)
    @docommon::fireport { "0${port} state NEW tcp dpt:${port}":
      dport   => $port,
      proto   => 'tcp',
    }
    @domotd::register { "VNC(${port})" : }
  } else {
    # port in use but not exposed
    @domotd::register { "VNC[${port}]" : }
  }

  # OS-specific variants
  case $operatingsystem {
    centos, redhat, fedora: {
      # install desktop using groups (takes a long time)
      exec { 'install-desktop':
        command => '/usr/bin/yum install -y @basic-desktop @fonts @x11',
        timeout => 60*60,
        before => File['docommon-desktop-vnc-config'],
        require => Exec['up-to-date'],
      }

      # install VNC
      if ! defined(Package['tigervnc-server']) {
        package { 'tigervnc-server' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }
      if ! defined(Package['tigervnc']) {
        package { 'tigervnc' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }
      if ! defined(Package['xorg-x11-fonts-Type1']) {
        package { 'xorg-x11-fonts-Type1' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }
    
      # install a remote desktop client, just because it's useful
      if ! defined(Package['rdesktop']) {
        package { 'rdesktop' : ensure => present }
      }
      if ! defined(Package['tsclient']) {
        package { 'tsclient' : ensure => present }
      }

      # setup config file
      file { 'docommon-desktop-vnc-config' :
        path => '/etc/sysconfig/vncservers',
        content => template('docommon/vncservers-config.centos.erb'),
        mode => 0644,
        notify => Service['vncserver'],
        before => [Anchor['docommon-desktop-config']],
      }

      # disable annoying package kit prompt
      file { 'docommon-desktop-vnc-packagekit-setup' :
        path => '/etc/yum/pluginconf.d/refresh-packagekit.conf',
        content => template('docommon/refresh-packagekit.conf.erb'),
        mode => 0644,
        notify => Service['vncserver'],
      }
    }
    ubuntu, debian: {
      # install desktop using tasksel groups
      package { ['ubuntu-desktop^']:
        require => Exec['up-to-date'],
        before => File['docommon-desktop-vnc-config'],
      }
      
      if ! defined(Package['vnc4server']) {
        package { 'vnc4server' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }
      if ! defined(Package['xfce4']) {
        package { 'xfce4' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }
      if ! defined(Package['xfce4-goodies']) {
        package { 'xfce4-goodies' :
          ensure => present,
          before => File['docommon-desktop-vnc-config'],
        }
      }

      # setup user-specific config
      file { 'docommon-desktop-home-vnc-xstartup' :
        path => "/home/${user}/.vnc/xstartup",
        content => template('docommon/xstartup.erb'),
        # needs to be +x, 0644 yields grey screen with black x crosshair
        mode => 0755,
        notify => Service['vncserver'],
        require => [File["/home/${user}/.vnc"]],
        before => [Anchor['docommon-desktop-config']],
      }
      # setup service executable
      file { 'docommon-desktop-vnc-config' :
        path => '/etc/init.d/vncserver',
        content => template('docommon/vncserver.ubuntu.erb'),
        mode => 0755,
        notify => Service['vncserver'],
        before => [Anchor['docommon-desktop-config']],
      }
      
    }
  }

  anchor { 'docommon-desktop-config' : }

  file { 'docommon-desktop-vnc-makedir' :
    path => "/home/${user}/.vnc",
    ensure => 'directory',
    owner => $user,
    group => $user,
    mode => 0750,
  }->

  # set vncpasswd for main user
  exec { 'docommon-desktop-vnc-setpass' :
    path => '/usr/bin:/bin:/usr/sbin:/sbin',
    command => "echo ${password} > /home/${user}/.vnc/plaintext && echo ${password} >> /home/${user}/.vnc/plaintext &&  vncpasswd </home/${user}/.vnc/plaintext  /home/${user}/.vnc/passwd && chmod 600 /home/${user}/.vnc/passwd && rm -f /home/${user}/.vnc/plaintext",
    user => $user,
    group => $user,
    notify => Service['vncserver'],
    tag => ['service-sensitive'],
    creates => "/home/${user}/.vnc/passwd",
  }

  # start service (now and on restart)
  service { 'vncserver' :
    ensure => 'running',
    enable => 'true',
    tag => ['service-sensitive'],
  }

}
