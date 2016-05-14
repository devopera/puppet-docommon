#
# create a directory but don't overwrite symlinks if they exist
# bash -c is necessary to use if/test constructs
#
define docommon::createdir (
  $ensure = 'present',
  $owner = 'root',
  $group = 'root',
  $cwd = '/tmp',
  $purge = true,
) {
  # if the filename already exists as a file, delete it as root
  if ($purge) {
    exec { "createdir-purge-${title}" :
      path => '/usr/bin:/bin', 
      command => "bash -c \"cd ${cwd}; if ( test -f ${title} ); then rm ${title}; fi \"",    
      before => Exec["createdir-${title}"],
    }
  }
  # create directory only if a dir/symlink does not already exist, as root, then set ownership
  exec { "createdir-${title}" :
    path => '/usr/bin:/bin', 
    command => "bash -c \"cd ${cwd}; if (! test -d ${title} ); then mkdir ${title}; chown ${owner}:${group} ${title} ; fi \"",
  }
}

