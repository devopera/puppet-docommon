
# make sure user exists, nicely
define docommon::ensureuser (
  $user,
  $home,
  $uid = undef,
) {

  # can't use user resource type because Ubuntu chokes on overwriting
  # if ! defined(User['mysql']) {
  #   user { 'mysql-user': 
  #     name => 'mysql',
  #     shell => '/bin/bash',
  #     uid => 27,
  #     ensure => 'present',
  #     managehome => true,
  #     home => '/var/lib/mysql',
  #     comment => 'MySQL server user',
  #   }
  # }

  # only name the uid if it's set
  if ($uid == undef) {
    $real_uid = ""
  } else {
    $real_uid = "-u ${uid}"
  }

  exec { "docommon-ensureuser-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "id -u ${user} &>/dev/null || useradd ${real_uid} -d ${home} ${user}",
  }
}

