
# find all files matching criterion and install contents in user's crontab
define docommon::findcrontab (
  # no crontabs to be found if no directory
  $directory = '/etc/puppet/does-not-exist',
  $wild = '*.crontab',
  $cwd = '/tmp',
  $user = 'root',
  $group = 'root',
  $notifier_dir = '/etc/puppet/tmp',
  $purge = false,
) {
  # build target within notifier directory
  $target = "${notifier_dir}/puppet-docommon-findcrontab-${title}"

  # find all the crontab lines and aggregate into a single file (target)
  docommon::findconcat { "puppet-docommon-findcrontab-${title}" :
    directory => $directory,
    wild => $wild,
    cwd => $cwd,
    user => $user,
    group => $group,
    # always purge incase the target already exists
    purge => true,
    target => $target,
  }

  if ($purge) {
    # wipe the user's current concat (as root)
    exec { "puppet-docommon-findcrontab-purge-${title}" :
      path => '/usr/bin:/bin',
      command => "echo '' | crontab -u ${user} -",
      before => Exec["puppet-docommon-findcrontab-install-${title}"],
    }
  }

  # install crontab lines (from target) into user's crontab
  exec { "puppet-docommon-findcrontab-install-${title}" :
    path => '/usr/bin:/bin',
    command => "crontab -u ${user} -l | cat ${target} - | crontab -u ${user} -",
    # only if the target file exists (there were crontab lines)
    onlyif => "test -f ${target}",
    require => Docommon::Findconcat["puppet-docommon-findcrontab-${title}"],
  }
}
