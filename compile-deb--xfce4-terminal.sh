#!/bin/bash

if [ ! -f /.dockerenv ]; then
   echo "This script better to run in dockerized environment"
   # TODO: mount /etc/apt into the container
   ~/docker/u16.sh $0
   exit
fi

sudo apt-get update
sudo apt-get install   -y dpkg-dev devscripts xfce4-dev-tools
sudo apt-get build-dep -y xfce4-terminal

sudo sed -i -r 's/disable-maintainer-mode/enable-maintainer-mode/g' /usr/share/perl5/Debian/Debhelper/Buildsystem/autoconf.pm

pushd xfce4-terminal-*
debchange --nmu xxx
debuild clean
debuild -i -us -uc -b
popd

# here .deb can be installed and tested
#dpkg -i ...
#/bin/bash
