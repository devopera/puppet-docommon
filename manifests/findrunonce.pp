
# find all files matching criterion and execute, but only once
define docommon::findrunonce (
  $directory = '/',
  $wild = '*',
  # by default command execution writes to /dev/null (destroyed)
  $target = '/dev/null',
  $cwd = '/tmp',
  $user = 'root',
  $group = 'root',
  # optionally run a command to setup the exec environment  
  $precommand = undef,
  $notifier_dir = '/etc/puppet/tmp',
) {
  # identify where the output should go
  $resolved_target = $target ? {
    '/dev/null' => '/dev/null',
    default     => "${notifier_dir}/${target}",
  }
  # append ; to precommand if set
  $resolved_precommand = $precommand ? {
    undef => '',
    default => "${precommand};",
  }
  # find only if base directory exists, otherwise fail silently
  exec { "find-${title}" :
    path => '/usr/bin:/bin',
    # && being ignored 
    # command => "bash -c \"${resolved_precommand} cd ${cwd}; [ -d ${directory} ] && find ${directory} -iname '${wild}' -exec {} >> ${resolved_target} \; \"",
    # re-written using if-then-fi 
    command => "bash -c \"${resolved_precommand} cd ${cwd}; if [ -d ${directory} ]; then find ${directory} -iname '${wild}' -exec {} >> ${resolved_target} \; ; fi\"",
    cwd => $cwd,
    user => $user,
    group => $group,
    # assume that databases can be sourced/applied by (typically by installapp_apply.sh) within 30 minutes
    timeout => 1800,
    # only use creates shortcut if target is defined
    creates => $target ? {
      '/dev/null' => undef,
      default     => $resolved_target,
    },
  }
}
