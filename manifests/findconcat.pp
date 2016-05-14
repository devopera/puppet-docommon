
# find all files matching criterion and concatenate
define docommon::findconcat (
  $directory = '/',
  $wild = '*',
  $target = $title,
  $cwd = '/tmp',
  $user = 'root',
  $group = 'www-data',
  $purge = true,
) {
  if ($purge) {
    # erase the file if it exists already
    file { "${title}" :
      path => $target,
      ensure => absent,
    }
  }
  exec { "findconcat-${title}" :
    path => '/usr/bin:/bin', 
    # only find files (and concat into target) if the directory exists
    # else don't create target output file
    command => "bash -c \"cd ${cwd}; if test -d ${directory}; then find ${directory} -iname '${wild}' -exec cat {} >> ${target} \; ; fi \"",
    cwd => $cwd,
    user => $user,
    group => $group,
    require => File[$title],
  }
}

