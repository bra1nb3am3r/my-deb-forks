#!/bin/bash

if [ ! -f /.dockerenv ]; then
  echo "This script better to run in dockerized environment"

  image=$(basename $0 .sh)
  user=${USER:-root}
  home=${HOME:-/home/$user}
  uid=${UID:-1000}
  gid=${uid:-1000}
  tmpdir=$(mktemp -d)

  escape_me() {
     perl -e 'print(join(" ", map { my $x=$_; s/\\/\\\\/g; s/\"/\\\"/g; s/`/\\`/g; s/\$/\\\$/g; s/!/\"\x27!\x27\"/g; ($x ne $_) || /\s/ ? "\"$_\"" : $_ } @ARGV))' "$@"
  }

  echo "FROM ubuntu:16.04

RUN mkdir -p ${home} \\
 && chown ${uid}:${gid} -R ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && [ -d /etc/sudoers.d ] || (apt-get update && apt-get -y install sudo) \\
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\
 && chmod 0440 /etc/sudoers.d/${user}
USER ${user}
ENV HOME ${home}

CMD cd $(escape_me "$(pwd)"); \\
    $(escape_me "$0")
" > $tmpdir/Dockerfile

  docker build -t $image $tmpdir
  rm -rf $tmpdir

  docker run -ti -e DISPLAY --net=host \
     -v /etc/apt:/etc/apt:ro \
     -v "$(pwd)":"$(pwd)" \
     --rm $image

  exit
fi

sudo apt-get update
sudo apt-get install   -y dpkg-dev devscripts fakeroot xfce4-dev-tools
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
