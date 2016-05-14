
# run a command in a bash shell once on a new system
define docommon::runonce (
  $command = $title,
  $cwd = '/tmp',
  $user = 'root',
  $notifier_dir = '/etc/puppet/tmp',
) {
  exec { "exec-${title}" :
    path => '/usr/bin:/bin', 
    command => "bash -c 'cd ${cwd}; ${command}; touch ${notifier_dir}/puppet-runonce-${title}'",
    cwd => $cwd,
    user => $user,
    creates => "${notifier_dir}/puppet-runonce-${title}",
  }
}

