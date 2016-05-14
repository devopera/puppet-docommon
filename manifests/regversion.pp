#
# register some version information retreived from running a command
# store as simple name:value pairs
#
define docommon::regversion (
  $command,
  $user = 'web',
  $name = $title,
  $order = 50,
) {
  # register in local file
  @concat::fragment { "docommon-regversion-local-${title}" :
    target  => "/home/${user}/${docommon::params::regfile}",
    # write out as json
    content => "\{ 'name': '${name}', 'value': '${command}'\},",
    order => $order,
  }
  # register in server file if setup
  # @@concat::fragment { "docommon-regversion-server-${title}" :
  #   target  => $resolved_motd,
  #   content => "${command}",
  #   order => $order,
  # }
}

