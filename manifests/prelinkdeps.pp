
define docommon::prelinkdeps (
  $filename = title,
) {
  # prelink file if it exists
  exec { "docommon-prelinkdeps-${title}" :
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "prelink ${title}",
    onlyif => "test -f ${title}",
  }
}

