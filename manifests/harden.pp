class docommon::harden (

  $group = 'wheel',

) {

  # if there's no wheel group present, create one (sorry Richard Stallman)
  exec { 'docommon-harden-wheel-group-add' :
    path => '/usr/bin:/usr/sbin',
    command => "groupadd -f ${group}",
  }

  # restrict access to certain binaries
  create_resources(docommon::harden::restrictbin, {
    '/usr/bin/wget' => {},
    '/usr/bin/scp' => {},
    '/usr/bin/lynx' => {},
  }, {
    group => $group,
    require => [Exec['docommon-harden-wheel-group-add']],
  })

  # restrict access to su to wheel users
  exec { "harden-restrictbin-su" :
    path => '/bin:/usr/bin',
    command => "chown root:${group} /bin/su; chmod 4750 /bin/su",
    user => 'root',
  }  
}

define docommon::harden::restrictbin (
  $group = 'wheel',
  $hardname = $title,
) {
  exec { "harden-restrictbin-$title" :
    path => '/bin:/usr/bin',
    command => "chown root:${group} ${hardname}; chmod 0750 $hardname",
    user => 'root',
  }
}
