
# expose a port under SELinux
define docommon::seport(
  $port,
  $seltype,
  $protocol = 'tcp',
) {
  if defined(selinux_port) {
    selinux_port { "${protocol}/${port}":
      seltype => $seltype,
    }
  }
}
