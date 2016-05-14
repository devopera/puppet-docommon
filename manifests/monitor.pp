class docommon::monitor (

  # class arguments
  # ---------------
  # setup defaults

  $ssh_port = 22,

  # end of class arguments
  # ----------------------
  # begin class

) {

  @nagios::service { "ssh:${ssh_port}-docommon-${::fqdn}":
    check_command => "check_ssh_port!${ssh_port}",
  }

}
