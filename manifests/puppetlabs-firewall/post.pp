class docommon::puppetlabs-firewall::post {
  firewall { '65535 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}

