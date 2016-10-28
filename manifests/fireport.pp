
# alias and combine the puppetlabs/example42 firewall {} resource types
define docommon::fireport (
  # fields from example42 firewall module's 'firewall' resource type
  $protocol = $proto,
  
  # fields shared [syntax match] between puppetlabs and example42, but different defaults
  $action = undef,
  $source = undef,
  $destination = undef,
  $port = $dport,
  
  # fields from puppetlabs firewall module's 'firewall' resource type
  $dport = undef,
  $proto = 'tcp',
  
  # fields that we've added
  # by default use example42's firewall module
  $firewall_module = 'example42',

)  {

  # setup defaults
  case $firewall_module {
    puppetlabs, docsf: {
      $default_action = 'accept'
      $default_source = '0.0.0.0/0'
      $default_destination = '0.0.0.0/0'
      $default_port = ''
    }
    example42: {
      $default_action = ''
      $default_source = ''
      $default_destination = ''
      $default_port = ''
    }
  }

  # decide which value to use
  $real_action = $action ? {
    undef   => $default_action,
    default => $action,
  }
  $real_source = $source ? {
    undef   => $default_source,
    default => $source,
  }
  $real_destination = $destination ? {
    undef   => $default_destination,
    default => $destination,
  }
  $real_port = $port ? {
    undef   => $default_port,
    default => $port,
  }

  notify { "docommon::fireport exposed port for ${protocol}:${port} ${firewall_module} module" : }

  # pass on to right type
  case $firewall_module {
    puppetlabs: {
      firewall { "00${port} state NEW ${protocol} dpt:${port} src:${real_source}" :
        dport    => $real_port, # inherited dport => $port or_if_unset $dport or_if_unset $default_port
        proto    => $protocol,  # inherited proto => $protocol or_if_unset $proto or_if_unset 'tcp'
        action   => $real_action,
        source   => $real_source,
        # these values are set explicitly here as it's difficult to set them using inherited defaults
        notify  => Exec['puppetlabs-persist-firewall'],
        before  => Class['docommon::puppetlabs-firewall::post'],
        require => Class['docommon::puppetlabs-firewall::pre'],
      }
    }
    docsf: {
      docsf::fireport { "docommon_fireport_docsf_alias_dpt_${port}_optsrcip_${source}" :
        source => $source,
        port => $port,
        proto => $proto,
      }
    }
    example42: {
      firewall { "${title}" :
        port     => $real_port, # inherited dport => $port or_if_unset $dport or_if_unset $default_port
        protocol => $protocol,  # inherited proto => $protocol or_if_unset $proto or_if_unset 'tcp'
        action   => $real_action,
        source   => $real_source,
      }
    }
  }
}

