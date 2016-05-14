class docommon::dev {

  # install handy dev tools
  if ! defined(Package['ftp']) {
    package { 'ftp' : ensure => present }
  }  
  if ! defined(Package['telnet']) {
    package { 'telnet' : ensure => present }
  }  
  if ! defined(Package['traceroute']) {
    package { 'traceroute' : ensure => present }
  }  
  if ! defined(Package['bc']) {
    package { 'bc' : ensure => present }
  }  
  if ! defined(Package['unzip']) {
    package { 'unzip' : ensure => present }
  }  
  if ! defined(Package['gcc']) and ! defined(Class['gcc']) {
    package { 'gcc' : ensure => present }
  }  
  if ! defined(Package['ruby']) {
    package { 'ruby' : ensure => present }
  }  
  
  # install bundler for bundle-installing other deps
  if ! defined(Package['bundler']) {
    package { 'bundler' :
      ensure => 'installed',
      provider => 'gem',
    }
  }
  # install compass for compiling sass
  package { 'compass':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['ruby'],
  }

  # install rspec-puppet for unit testing puppet modules
  package { 'rspec-puppet':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['ruby'],
  }

  # install OS-specific packages
  case $operatingsystem {
    centos, redhat, fedora: {
      if ! defined(Package['mailx']) {
        package { 'mailx' : ensure => present }
      }  
      if ! defined(Package['bind-utils']) {
        package { 'bind-utils' : ensure => present }
      }  
      if ! defined(Package['ruby-devel']) {
        package { 'ruby-devel' :
          ensure => present,
          # compass requires ruby-devel 
          before => Package['compass'],
        }
      }
    }
    ubuntu, debian: {
      if ! defined(Package['bsd-mailx']) {
        package { 'bsd-mailx' : ensure => present }
      }  
      if ! defined(Package['bind9']) {
        package { 'bind9' : ensure => present }
      }
      if ! defined(Package['ruby-dev']) {
        package { 'ruby-dev' : ensure => present }
      }
    }
  }

}
