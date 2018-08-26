define docommon::desktopvnc (
  
  # type arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $password = 'admLn**',
  $resolution = '1024x768',
  $packagekit_enable = '0',
  $firewall = false,
  $port = 5901,
  $display = 1,
  $service_name = 'vncserver',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # expose firewall ports if requested and not done already
  if ! defined(Domotd::Register["VNC[${port}]"]) {
    if ($firewall) {
      # can expose port (insecure), or can tunnel over SSH ($firewall = false)
      @docommon::fireport { "0${port} state NEW tcp dpt:${port}":
        dport   => $port,
        proto   => 'tcp',
      }
      @domotd::register { "VNC(${port})" : }
    } else {
      # port in use but not exposed, note [] brackets
      @domotd::register { "VNC[${port}]" : }
    }
  }

  $config_file_alias = "docommon-desktop-vnc-service-setup-${service_name}"
  # OS-specific variants
  case $operatingsystem {
    centos, redhat, fedora: {
      # install desktop using groups (takes a long time)
      exec { "install-desktop-${title}" :
        command => '/usr/bin/yum install -y @basic-desktop @fonts @x11',
        timeout => 60*60,
        before => File[$config_file_alias],
        require => Exec['up-to-date'],
      }

      # install VNC
      if ! defined(Package['tigervnc-server']) {
        package { 'tigervnc-server' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['tigervnc']) {
        package { 'tigervnc' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['xorg-x11-fonts-Type1']) {
        package { 'xorg-x11-fonts-Type1' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
    
      # install a remote desktop client, just because it's useful
      # if ! defined(Package['tsclient']) {
      #   package { 'tsclient' : ensure => present }
      # }

      # create service initialisation file
      if ! defined(File[$config_file_alias]) {
        # setup service executable
        file { $config_file_alias :
          path => "/etc/init.d/${service_name}",
          content => template('docommon/vncserver.centos.erb'),
          mode => 0755,
          notify => Service[$service_name],
        }
      }

      if ! defined(File['docommon-desktopvnc-centos-vncservers']) {
        file { 'docommon-desktopvnc-centos-vncservers' :
          path => '/etc/sysconfig/vncservers',
          content => template('docommon/vncservers-config.centos.erb'),
          mode => 0644,
          notify => Service[$service_name],
          before => Anchor["docommon-desktop-config-${title}"],
        }
      }

      # disable annoying package kit prompt
      if ! defined(File['docommon-desktop-vnc-packagekit-setup']) {
        file { 'docommon-desktop-vnc-packagekit-setup' :
          path => '/etc/yum/pluginconf.d/refresh-packagekit.conf',
          content => template('docommon/refresh-packagekit.conf.erb'),
          mode => 0644,
          notify => Service[$service_name],
        }
      }
    }
    ubuntu, debian: {
      # install desktop using tasksel groups
      if ! defined(Package['ubuntu-desktop^']) {
        package { ['ubuntu-desktop^']:
          require => Exec['up-to-date'],
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['vnc4server']) {
        package { 'vnc4server' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['xfce4']) {
        package { 'xfce4' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['xfce4-goodies']) {
        package { 'xfce4-goodies' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      if ! defined(Package['xfce4-indicator-plugin']) {
        package { 'xfce4-indicator-plugin' :
          ensure => present,
          before => File[$config_file_alias],
        }
      }
      # take out xscreensaver because it consumes processor power redundantly
      if ! defined(Package['xscreensaver']) {
        package { 'xscreensaver' :
          ensure => absent,
          before => File[$config_file_alias],
        }
      }


      # explicitly manually remove deja-dup, which crashes multiple desktops
      exec { "docommon-desktopvnc-remove-deja-dup-${title}" :
        path => '/bin:/sbin:/usr/bin:/usr/sbin',
        command => 'apt-get -y -q --purge remove deja-dup*',
        require => File[$config_file_alias],
      }

      # setup user-specific config
      file { "docommon-desktop-home-vnc-xstartup-${title}" :
        path => "/home/${user}/.vnc/xstartup",
        content => template('docommon/xstartup.erb'),
        # needs to be +x, 0644 yields grey screen with black x crosshair
        mode => 0755,
        notify => Service[$service_name],
        require => [File["/home/${user}/.vnc"]],
        before => Anchor["docommon-desktop-config-${title}"],
      }
      if ! defined(File[$config_file_alias]) {
        # setup service executable
        file { $config_file_alias :
          path => "/etc/init.d/${service_name}",
          content => template('docommon/vncserver.ubuntu.erb'),
          mode => 0755,
          notify => Service[$service_name],
        }
      }
    }
  }
  # install packages common to both operating systems
  if ! defined(Package['freerdp']) {
    package { 'freerdp' : ensure => present }
  }

  anchor { "docommon-desktop-config-${title}" :
    require => File[$config_file_alias],
  }

  file { "docommon-desktop-vnc-makedir-${title}" :
    path => "/home/${user}/.vnc",
    ensure => 'directory',
    owner => $user,
    group => $user,
    mode => 0750,
  }->

  # set vncpasswd for main user
  exec { "docommon-desktop-vnc-setpass-${title}" :
    path => '/usr/bin:/bin:/usr/sbin:/sbin',
    command => "echo ${password} > /home/${user}/.vnc/plaintext && echo ${password} >> /home/${user}/.vnc/plaintext &&  vncpasswd </home/${user}/.vnc/plaintext  /home/${user}/.vnc/passwd && chmod 600 /home/${user}/.vnc/passwd && rm -f /home/${user}/.vnc/plaintext",
    user => $user,
    group => $user,
    notify => Service[$service_name],
    tag => ['service-sensitive'],
    creates => "/home/${user}/.vnc/passwd",
  }

  # start service (now and on restart)
  if ! defined(Service[$service_name]) {
    service { $service_name :
      ensure => 'running',
      enable => 'true',
      tag => ['service-sensitive'],
    }
  }

}
