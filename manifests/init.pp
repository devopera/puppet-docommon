class docommon (

  # class arguments
  # ---------------
  # setup defaults

  # location of the puppet master must be set, or inherited from custom fact
  $puppetmaster_ip = $puppetmaster_ipaddress,

  # SSH server config
  $ssh_port = $docommon::params::ssh_port,
  $ssh_password_authentication = $docommon::params::ssh_password_authentication,
  $ssh_force_pam = $docommon::params::ssh_force_pam,
  $ssh_x11_forwarding = $docommon::params::ssh_x11_forwarding,
  
  # main user's name, email and password
  $user = $docommon::params::user,
  $user_uid = $docommon::params::user_uid,
  $user_email = $docommon::params::user_email,
  $user_pass_hash = $docommon::params::user_pass_hash,
  
  # super-user group name
  $wheel = $docommon::params::wheel,

  # directory structure for web accessible directories /var/www
  $webfile = $docommon::params::webfile,
  $known_hosts = $docommon::params::known_hosts,
  $hosts = $docommon::params::hosts,
  $notifier_dir = '/etc/puppet/tmp',

  # open non-standard ssh port and realize all the others
  $firewall = $docommon::params::firewall,
  $firewall_module = $docommon::params::firewall_module,
  $monitor = $docommon::params::monitor,
  $register = $docommon::params::register,

  # empty sets (server/repos) by default
  $ssh_servers = [],
  $repos = {},
  $repos_default = {},

  # end of class arguments
  # ----------------------
  # begin class

) inherits docommon::params {

  notify { "Installing from $environment environment":}

  class { 'docommon::settingless':}

  # setup motd variable for different platforms
  case $operatingsystem {
    centos, redhat, fedora: {
      # show motd on ssh login
      $resolved_print_motd = 'yes'
      # puppet /etc/pam.d/sshd config file
      file { '/etc/pam.d/sshd' :
        content => template('docommon/pam.d-sshd.centos.erb'),
        mode => 0644,
      }
    }
    ubuntu, debian: {
      # but handled automatically for ubuntu
      $resolved_print_motd = 'no'
    }
  }
  
  # setup forwarding hosts
  class { 'ssh::client': 
    servers => $ssh_servers
  }->
  
  # setup sshd on a non-standard port
  class { 'ssh::server':
    port => $ssh_port,
    password_authentication => $ssh_password_authentication,
    x11forwarding => $ssh_x11_forwarding,
    print_motd => $resolved_print_motd,
  }
  contain 'ssh::client'
  contain 'ssh::server'

  # usePAM takes same value as ssh_password_authentication, unless it's forced
  $resolved_ssh_pam = $ssh_force_pam ? {
    undef => $ssh_password_authentication ? {
      'no' => $docommon::params::ssh_default_pam,
      'yes' => 'yes',
    },
    default => $ssh_force_pam,
  }
  # tell SSH module to use our sshd_config.erb template
  File <| title == '/etc/ssh/sshd_config' |> {
    # notice that all the variable substitution happens here
    content => template('docommon/sshd_config.erb'),
  }

  if (str2bool($::selinux)) {
    case $operatingsystem {
      centos, redhat: {
        case $operatingsystemmajrelease {
          '6' : {
          }
          '7', default: {
            if ($ssh_port != 22) {
              selinux_port { "tcp/${ssh_port}":
                seltype => 'ssh_port_t',
              }
            }
            # make prelink cache writeable by the /etc/cron.daily task
            $prelink_target = '/etc/prelink.cache'
            exec { "puppet-docommon-selinux-prelink-cache-perms" :
              path => '/usr/bin:/bin:/sbin:/usr/sbin',
              command => "semanage fcontext -a -t prelink_cron_system_exec_t ${prelink_target} && restorecon -v ${prelink_target}",
              onlyif => "test -f ${target}",
            }
          }
        }
      }
      fedora: {
        if ($ssh_port != 22) {
          selinux_port { "tcp/${ssh_port}":
            seltype => 'ssh_port_t',
          }
        }
      }
    }
  }

  # if we're using monitoring, setup the checks
  if ($monitor) {
    class { 'docommon::monitor' :
      ssh_port => $ssh_port,
    }
    contain 'docommon::monitor'
  }

  if ($firewall) {
    # depending on the firewall module we're using, initialise
    case $firewall_module {
      puppetlabs: {
        # pull in the setup manifest
        include docommon::puppetlabs-firewall::setup
        
        # These defaults CANNOT be set here, because they are not inherited by firewall resources, even in docommon::fir
        # Firewall {
        # notify  => Exec['puppetlabs-persist-firewall'],
        # before  => Class['docommon::puppetlabs-firewall::post'],
        # require => Class['docommon::puppetlabs-firewall::pre'],
        # }
        # Firewallchain {
        #   notify  => Exec['puppetlabs-persist-firewall'],
        # }
        # purge unmanaged (non-puppet) firewall resources
        # resources { "firewall":
        #   purge => true
        # }
      }

      example42: {
        class { 'iptables':
          safe_ssh         => false,
          broadcast_policy => 'accept',
          multicast_policy => 'accept',
          icmp_policy      => 'accept',
          output_policy    => 'accept',
        }
      }
    }
    
    # tell all fireports (set resource defaults) to use the right firewall module
    Docommon::Fireport {
      firewall_module => $firewall_module,
    }

    # open non-standard port in firewall
    class { 'docommon::firewall' : }
    contain 'docommon::firewall'
  
    # realize all the firewall (fireport) definitions, from this and other modules
    Docommon::Fireport <| |>
  }

  if ($register) {
    # create concat file for regversion/regpassword
    concat { "/home/${user}/${docommon::params::regfile}" :
      owner => $user,
      group => $user,
      mode => 644,
      ensure => present,
      require => User['main-user'],
    }
    # write out header
    concat::fragment { "docommon-regversion-local-setup-header" :
      target  => "/home/${user}/${docommon::params::regfile}",
      content => "// ${docommon::params::regfile} settings and versions JSON file\r\n[\r\n",
      order => 5,
    }
    # write out footer
    concat::fragment { "docommon-regversion-local-setup-footer" :
      target  => "/home/${user}/${docommon::params::regfile}",
      content => "1 ]\r\n",
      order => 95,
    }
  }

  # if we've got a message of the day, include SSH
  @domotd::register { "SSH(${ssh_port})" : }
  
  # restrict access to basic utilities
  class { 'docommon::harden':
    group => $wheel,
    before => [User['main-user']],
  }
  contain 'docommon::harden'

  # create standard user, add to wheel group
  user { 'main-user':
    name => $user,
    shell => '/bin/bash',
    uid => $user_uid,
    ensure => 'present',
    managehome => true,
    home => "/home/${user}",
    comment => "${user} user",
    groups => $wheel,
    password => $user_pass_hash,
  }

  # allow main user to use sudo
  class { 'sudo': }
  sudo::conf { "${user}":
    priority => 10,
    content  => "${user} ALL=(ALL) PASSWD: ALL\n",
  }

  # add known hosts for github (their public key), and fix permission bug
  create_resources(sshkey, $known_hosts)  
  file { "/etc/ssh/ssh_known_hosts":
    mode    => 0644,
  }
 
  # clear /etc/hosts, then set up managed hosts
  # but be careful not to wreck the hosts file mid-run
  resources { 'host': 
    purge => true, 
  }
  # manually create original puppetmaster entry
  host { 'host-puppetmaster-original' :
    comment => 'original puppetmaster IP (though may now puppet from itself, see puppet.conf)',
    name => 'puppet',
    ip => $::puppetmaster_ip,
    require => Resources['host'],
  }
  # then add all the other named hosts
  create_resources(host, $hosts,{
    require => [Host['host-puppetmaster-original'], Resources['host']],
  })

  # create /var/www hosting directories (SVN, GIT, Samba, Local)
  file { 'common-webroot' :
    name => '/var/www',
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => 0755,
  }
  # group will need to be chowned once we create the web server group
  $webfile_default = {
    user => $user,
    group => $user,
    require => File['common-webroot'],
  }
  create_resources(docommon::stickydir, $webfile, $webfile_default)

  # create notifier directory for storing 'memory' that we've run a task
  file { "${notifier_dir}" :
    ensure => 'directory',
    owner => $user,
    group => 'puppet',
    mode => 0664,
  }

  # include nondep to avoid dep cycle, but do not 'contain'
  class { 'docommon::nondep': 
    user => $user,
  }

  # include basic template for both users
  concat::fragment { 'docommon-bashrc-basic-template-web':
    target  => "/home/${user}/.bashrc",
    content => template('docommon/bashrc.erb'),
    order   => '02',
  }
  concat::fragment { 'docommon-bashrc-basic-template-root':
    target  => '/root/.bashrc',
    content => template('docommon/bashrc.erb'),
    order   => '02',
  }
  
  # add secure aliae for root
  concat::fragment { 'docommon-bashrc-root-aliae':
    target  => '/root/.bashrc',
    content => template('docommon/bashrc-root.erb'),
    order   => '10',
  }

  # create colouring script in /etc/bash_colouring
  file { '/etc/bash_colouring' :
    ensure => present,
    owner => $user,
    group => 'root',
    content => template('docommon/bash_colouring.erb'),
    mode => 0640,
  }

  # include in both
  $command_bash_include_colouring = "\n# add command-line colouring if present\nif [ -f /etc/bash_colouring ]; then\n        source /etc/bash_colouring\nfi\n"
  concat::fragment { 'docommon-bashrc-colouring-web':
    target  => "/home/${user}/.bashrc",
    content => $command_bash_include_colouring,
    order   => '20',
  }
  concat::fragment { 'docommon-bashrc-colouring-root':
    target  => '/root/.bashrc',
    content => $command_bash_include_colouring,
    order   => '20',
  }

}

