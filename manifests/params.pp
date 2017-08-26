class docommon::params {

  # port to run SSH server on
  $ssh_port = 15022
  $ssh_password_authentication = 'no'
  $ssh_x11_forwarding = 'no'
  $ssh_force_pam = undef

  case $operatingsystem {
    centos, redhat, fedora: {
      # CentOS 7 doesn't like PAM, 6 doesn't need it
      $ssh_default_pam = 'no'
    }
    ubuntu, debian: {
      # Ubuntu needs PAM for motd
      $ssh_default_pam = 'yes'
    }
  }

  # main user's name, email and password
  $user = 'web'
  $user_uid = 500
  $user_email = 'admin@example.com'

  # password hash generated from password 'admLn**'
  $user_pass_hash = '$6$KDMXrEhz$ttVyjHgWaVpO2KdibW.TNv8w.uOjbD3KSGFqL.q8CsW81JPh.usRUAvgrEJ4JEh77YCPnWldEkttb8cpJXgyk.'

  # directory structure for web accessible directories /var/www
  $webfile =
  {
    '/var/www/svn' => {
    },
    '/var/www/git' => {
    },
    '/var/www/git/github.com' => {
    },
    '/var/www/smb' => {
    },
  }
  $webfile_group = 'www-data'

  $known_hosts = {
    'github.com' => {
    host_aliases => ['207.97.227.239'],
    type => 'ssh-rsa',
    key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==",
    },
  }

  $hosts = {
    'localhost' => {
      ip => '127.0.0.1',
      host_aliases => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4'],
    },
    # can't introduce until Bug #10704 fixed (http://projects.puppetlabs.com/issues/10704)
    # 'localhost::1' => {
    #   ip => '::1',
    #   name => 'localhost',
    #   host_aliases => ['localhost.localdomain', 'localhost6', 'localhost6.localdomain6',],
    # },
    'broadcasthost' => {
      ip => '255.255.255.255',
    },
    "${fqdn}" => {
      ip => '127.0.0.1',
      host_aliases => ["${hostname}"],
    },
  }

  $notifier_dir = '/etc/puppet/tmp'

  # open non-standard ssh port and realize all the others
  $firewall = true
  $firewall_module = 'example42'
  $monitor = true
  $register = true
  $regfile = '.doregister.json'

  case $operatingsystem {
    centos, redhat, fedora: {
      $wheel = 'wheel'
    }
    ubuntu, debian: {
      $wheel = 'sudo'
    }
  }

}

