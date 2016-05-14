class docommon::puppetlabs-firewall::pre (

) {

  # turn off require defaults set higher up the stack, just for these resources
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '00000 accept all icmp':
    chain   => 'INPUT',
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '00001 accept all to lo interface':
    chain   => 'INPUT',
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '00002 accept related established rules':
    chain   => 'INPUT',
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->
  firewall { '00005 allow puppetmaster to connect':
    action => 'accept',
    proto  => 'tcp',
    dport  => '8139',
  }

}
