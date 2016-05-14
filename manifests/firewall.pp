class docommon::firewall (

  # class arguments
  # ---------------
  # setup defaults

  $ssh_port = 15022,
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  @docommon::fireport { "docommon-ssh-${ssh_port}":
    port => $ssh_port,
    protocol => 'tcp',
  }

  # OS-specific variants
  case $operatingsystem {
    fedora: {
      # tell Fedora to use static iptables instead of dynamic firewalld
      service { 'docommon-firewall-disable-firewalld':
        name    => 'firewalld',
        ensure  => 'stopped',
        enable  => false,
        require => Package['iptables-services'],
      }
#      service { 'docommon-firewall-enable-iptables':
#        name    => 'iptables',
#        ensure  => 'running',
#        enable  => true,
#      }->
#      service { 'docommon-firewall-enable-ip6tables':
#        name    => 'ip6tables',
#        ensure  => 'running',
#        enable  => true,
#      }
    }
  }
}
