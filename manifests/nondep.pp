#
# Non-dependencies that cannot live in [required] docommon class
#
class docommon::nondep (

  # class arguments
  # ---------------
  # setup defaults

  $user = $docommon::params::user,

  # end of class arguments
  # ----------------------
  # begin class

) inherits docommon::params {
  # setup concat on this user and root's .bashrc
  concat { '/root/.bashrc' :
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
  }
  concat { "/home/${user}/.bashrc" :
    owner => $user,
    group => $user,
    mode => 644,
    ensure => present,
  }

}