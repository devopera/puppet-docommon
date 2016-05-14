class docommon::puppetlabs-firewall::setup(

) {

  # setup firewall rules
  exec { 'puppetlabs-persist-firewall':
    command     => $operatingsystem ? {
      /(Debian|Ubuntu)/ => '/sbin/iptables-save > /etc/iptables/rules.v4',
      /(RedHat|CentOS|Fedora)/ => '/sbin/iptables-save > /etc/sysconfig/iptables',
    },
    refreshonly => true,
    require     => [File['etc_iptables'], Class['docommon::puppetlabs-firewall::post']],
  }
  file {'etc_iptables':
    path   => '/etc/iptables',
    ensure => directory,
  }

  # post is the safe start point, pre follows
  include docommon::puppetlabs-firewall::post
  class { 'docommon::puppetlabs-firewall::pre': }

  # These defaults CANNOT be set here, because they are not inherited by firewall resources, even in docommon::fir
  # Firewall {
  # notify  => Exec['puppetlabs-persist-firewall'],
  # before  => Class['docommon::puppetlabs-firewall::post'],
  # require => Class['docommon::puppetlabs-firewall::pre'],
  # }
  # Firewallchain {
  #   notify  => Exec['puppetlabs-persist-firewall'],
  # }
  # purge unmanaged (non-puppet) firewall resources
  # resources { "firewall":
  #   purge => true
  # }

  case $operatingsystem {
    centos, redhat, fedora: {
      # turn off ip6tables as we're not currently using IPv6
      service { 'ip6tables' :
        ensure => stopped
      }
    }
  }
}

