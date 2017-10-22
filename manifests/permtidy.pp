
class docommon::permtidy (
  
  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # OS-specific variants
  case $operatingsystem {
    centos, redhat, fedora: {
      docommon::prelinkdeps { ['/usr/bin/wget','/usr/bin/lynx','/bin/cp','/bin/ls','/bin/mv','/bin/rpm']:
        require => [Exec['up-to-date'], Package['prelink']],
        before => [Anchor['docommon-permtidy-prelink-done']],
      }

      # avoid rkhunter false-positives using prelink
      anchor { 'docommon-permtidy-prelink-done': }

      if (str2bool($::selinux)) {
        # fix anacron access to prelink.cache if it exists
        exec { 'docommon-permtidy-prelinkrm' :
          path => '/bin:/usr/bin:/sbin:/usr/sbin',
          command => 'restorecon -R -v /etc/prelink.cache',
          onlyif => 'test -f /etc/prelink.cache',
          require => [Anchor['docommon-permtidy-prelink-done']],
        }
      }

    }
    ubuntu, debian: {
    }
  }

}
