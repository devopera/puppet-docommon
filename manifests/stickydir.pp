
# apply permission to a file/directory sensitively
define docommon::setperms(
  $filename = $title,
  $user = 'root',
  $group = 5000,
  $mode = 0640,
  $dirmode = 2750,
  $recurse = false,
) {
  $real_recurse = $recurse ? {
    true  => '-R',
    false => '',
  }
  if ($mode != false) {
    exec { "docommon-setperm-${title}" :
      path => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "chown ${real_recurse} ${user}:${group} ${filename}; chmod ${real_recurse} ${mode} ${filename}",
      before => Anchor["docommon-setperm-interim-${title}"],
    }
  }
  # use an anchor because dep is unpredictable (if & if)
  anchor { "docommon-setperm-interim-${title}": }
  if ($recurse) {
    exec { "docommon-setperm-recurse-${title}" :
      path => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "find ${filename} -type d -exec chmod ${dirmode} {} \;",
      require => Anchor["docommon-setperm-interim-${title}"],
    }
  }
}

define docommon::setfacl(
  $filename = $title,
  $acl,
) {
  exec { "${acl}-${title}" :
    command => "/usr/bin/setfacl ${acl} ${filename}",
    logoutput => true,
  }
}

define docommon::setcontext(
  # filename must not be slash terminated, otherwise context not set
  $filename = $title,
  $context,
) {
  exec { "${context}-${title}" :
    path => '/sbin:/usr/sbin',
    command => "semanage fcontext -a -t ${context} \"${filename}(/.*)?\" && restorecon -R -v \"${filename}\"",
    logoutput => true,
  }
}

# create a directory and force it to user:group
define docommon::stickydir (
  $filename = $title,
  $user = 'root',
  $group = 5000,
  $mode = 0640,
  $dirmode = 2750,
  $userfacl = 'rwx',
  $groupfacl = 'r-x',
  $allfacl = '---',
  $recurse = false,
  $context = undef,
) {
  if ! defined(File[$title]) {
    # create directory as resource
    file { $title :
      path => $filename,
      ensure => directory,
      owner => $user,
      group => $group,
      mode => $dirmode,
      # recurse => true produces endless output (4 lines / file), so use exec
      # recurse => true,
    }
  } else {
    # if the resource exists already, tweak it
    File <| title == $title |> {
      path => $filename,
      ensure => directory,
      owner => $user,
      group => $group,
      mode => $dirmode,      
    }
  }
  # exec produces only a few lines of output
  if ($recurse) {
    docommon::setperms { "${title}" :
      filename => $filename,
      user => $user,
      group => $group,
      mode => $mode,
      dirmode => $dirmode,
      recurse => $recurse,
      require => File["${title}"],
    }
  }

  # set access control for auto-user/perm inheritance
  docommon::setfacl { $title :
    filename => $filename,
    acl => "-dm u::${userfacl} -m g::${groupfacl} -m o::${allfacl}",
    require => File[$title],
  }
  # running setfacl recursively is super-slow and [almost] redundant
  # acl => '-Rdm u::rwx -m g::r-x -m o::---',

  # set security context if we're using SELinux
  if ($context != undef) {
    if (str2bool($::selinux)) {
      docommon::setcontext { $title :
        filename => $filename,
        context => $context,
        require => File[$title],
      }
    }
  }
}

