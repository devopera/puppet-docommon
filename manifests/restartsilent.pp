
# restart a service silently
# e.g. used to address postfix failure
define docommon::restartsilent (
  $service = 'postfix',
  $notifier_dir = '/etc/puppet/tmp',
) {
  exec { "docommon-restartsilent-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "service ${service} restart > /dev/null 2>&1",
    tag => ['service-sensitive'],
  }
}

