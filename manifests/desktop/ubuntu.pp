define docommon::desktop::ubuntu (
  
  # type arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $display = 1,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # sort out tab key
  file { "docommon-desktop-ubuntu-tab-${title}" :
    path => "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml",
    content => template('docommon/xfce4-keyboard-shortcuts.xml.erb'),
  }

  # setup iconset
  $xfce_iconset_name = 'Tango'
  $xfce_theme_name = 'Ambiance' 
  exec { "docommon-desktop-ubuntu-iconset-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "bash -c \"eval `export DISPLAY=:${display} && dbus-launch --auto-syntax && xfconf-query -c xsettings -p /Net/IconThemeName -s ${xfce_iconset_name} && xfconf-query -c xsettings -p /Net/ThemeName -s ${xfce_theme_name}`\"",
    # need to run this as the user/owner of the X session (otherwise xauth gets upset)
    user => $user,
    group => $user,
  }

}
