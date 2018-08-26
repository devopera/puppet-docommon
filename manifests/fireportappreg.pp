define docommon::fireportappreg (
  $app,
  $protocol = 'tcp',
  $port = $title,
  $firewall_module = 'example42',
) {

    # set up firewall ports for Plex
    @docommon::fireport { "00${port} ${app} service":
      protocol => $protocol,
      port     => $port,
      firewall_module => $firewall_module,
    }
    @domotd::register { "${app}(${port})" : }

}

