
# append one or more files' content to a target file, with basic template substitution
define docommon::filesadd (
  $target,
  $source,
  $purge = false,
  $cwd = '/tmp',
  $user = 'root',
  $group = 'root',
  # @todo set permissions on output file using mode
  $mode = undef,
  $precommand = undef,
  $postcommand = undef,
  # optionally include key:value pairs for substitution
  $kvsubs = {},
) {

  # where ipaddress_eth1 is not defined (i.e. the host only has a single network adaptor), use eth0 instead
  if $ipaddress_eth1 == undef {
    $local_ipaddress_eth1 = $ipaddress_eth0
  } else {
    $local_ipaddress_eth1 = $ipaddress_eth1
  }
  # turn key:value pairs into string
  if ($kvsubs == {}) {
    $real_kvsubs = ''
  } else {
    $unwrapped_kvsubs = join(join_keys_to_values($kvsubs, "/"), "/g' -e 's/")
    $real_kvsubs = "-e 's/${unwrapped_kvsubs}/g' "
  }
  # substitute in hostname, ipaddress, ipaddress_eth0 and (iff it exists) ipaddress_eth1
  # also substitute in key:value pairs if defined
  $command = "cat ${source} | sed \
  -e 's/<%=ipaddress%>/${ipaddress}/g' \
  -e 's/<%=ipaddress_eth0%>/${ipaddress_eth0}/g' \
  -e 's/<%=ipaddress_eth1%>/${local_ipaddress_eth1}/g' \
  -e 's/<%=hostname%>/${hostname}/g' \
  -e 's/<%=fqdn%>/${fqdn}/g' \
  -e 's/<%=processorcount%>/${processorcount}/g' \
  -e 's/<%=apacheuser%>/${apache::params::user}/g' \
  -e 's/<%=apachegroup%>/www-data/g' \
  ${real_kvsubs} \
  >> ${target}"

  # purge output file if set
  if ($purge) {
    exec { "purge-before-filesadd-${title}" :
      path => '/usr/bin:/bin',
      command => "bash -c 'rm -rf ${target}'",
      cwd => $cwd,
      user => $user,
      before => Exec["filesadd-${title}"],
    }
  }
  # pull content from source, replace certain variables, append to target
  exec { "filesadd-${title}" :
    path => '/usr/bin:/bin', 
    command => "bash -c \"cd ${cwd}; ${command}\"",
    cwd => $cwd,
    user => $user,
    group => $group,
  }

  if $mode != undef {
    exec { "filesadd-outputperm-${title}" :
      path => '/usr/bin:/bin',
      command => "bash -c \"chown ${user}:${group} ${target}; chmod ${mode} ${target}\"",
      cwd => $cwd,
      user => 'root',
    }
  }

  # optionally run a command on the created file
  if ($postcommand) {
    exec { "filesadd-postcommand-${title}" :
      path => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "${postcommand}",
      require => [Exec["filesadd-${title}"]],
    }
  }
}

