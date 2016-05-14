[devopera](http://devopera.com)-[docommon](http://devopera.com/module/docommon)
===============

The Devopera suite of modules rely on a minimal common infrastructure, such as an SSH server, at least one non-service-specific user to administer files etc.

Changelog
---------

2015-04-30

  * Extended config for Ubuntu desktops and introduced support for multiple instances of vnc-based desktops

2015-01-21

  * Removed extraneous dos line endings

2014-12-16

  * Added resolution parameter to vnc desktop resolutions (docommon::desktop)

2014-11-25

  * More tolerant version of stickydir to cope with two resources attempting to set permissions on the same file/folder

2014-06-04

  * Added docommon::seport to expose ports for SELinux using blentz/selinux_types

2014-05-02

  * Added docommon::setperms to apply permissions to a directory structure

2014-03-14

  * Added screen package as a useful way of setting processes to run within a context

2014-02-15

  * Prepared module for release on Puppet Forge, setup containment relationships for subclasses

2013-09-20

  * Introduced findcrontab to allow dorepos::installapp to setup cron tasks

2013-09-14

  * Fixed bug in docommon::harden as cannot assign value to variable $name

2013-09-11

  * Added Compass for compiling .sass and vim/ack for general maintenance, only on dev profile (docommon::dev)

2013-08-28

  * Introduced docommon::fireport defined resource to allow firewall definitions in the puppetlabs/firewall or example42/firewall formats 

2013-04-30

  * Moved firewall port opening out to firewall.pp and virtualised; adopted example42 firewall standard

2013-04-10

  * By default, each host should know itself as 127.0.0.1, so added to /etc/hosts setup using hosts array

2013-04-09

  * Split list of hardened binaries; only su needs to run as root

2013-03-04

  * Tweaked custom fact to find puppetmaster ipaddress even if setup as alias (not first list entry) in /etc/hosts

2013-02-25

  * Modified runonce to write notifications to a parameterised ${notifier_dir}, modified findrunonce to dump output to /dev/null unless target specified

Usage
-----

Setup system common elements

    class { 'docommon' : }

Give the standard user a different username, set email and password (using hash), tell SSH to run on non-standard port

    class { 'docommon':
      user => 'fred',
      user_email => 'fred@example.com',
      # hash of fred's password "admLn**"
      user_pass_hash => '',
      ssh_port => 15222,
    }

Setup a couple of standard directories for storing apps (see dorepos::installapp) and GitHub as a known host

    class { 'docommon' :
      webfile =>
      {
        '/var/www/git' => { },
        '/var/www/git/github.com' => { },
      },
      known_hosts => {
        'github.com' => {
          host_aliases => ['207.97.227.239','204.232.175.90'],
          type => 'ssh-rsa',
          key => "AAAAB3Nz=an=example=key==",
        },
      },
    }

Tell docommon to use example42's firewall module instead of puppetlabs'

    class { 'docommon' :
      firewall_module => 'example42',
    }

Setup entries in /etc/ssh/config to make SSH access to other machines using non-standard SSH ports easy

    class { 'docommon' :
      ssh_servers => [
        {
          'host' => 'our-svn',
          'hostname' => 'svn.example.com',
          'user' => 'svnuser',
          'port' => 522,
        },
        {
          'host' => 'our-backup',
          'hostname' => 'backup.example.com',
          'user' => $user,
          'port' => 15022,
        },
      ],
    }


Create a directory or ensure that one exists, but don't overwrite symlinks

```
docommon::createdir { ['/tmp/one', '/tmp/one/two', '/tmp/one/two/three']:
  owner => 'web',
  group => 'www-data',
}
```

Operating System support
------------------------

Tested with CentOS 6, Ubuntu 12.04

Copyright and Licence
---------------------

Copyright 2012 Lightenna Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
