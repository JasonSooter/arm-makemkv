#!/bin/bash
# Build MakeMKV <version> from makemkv.com and stage it under <destdir>/usr/local.
#
# Adapted from ARM's scripts/install_makemkv.sh, which takes it from
# https://github.com/tianon/dockerfiles/blob/master/makemkv/Dockerfile
# (The Expat/MIT License). The tarballs are checked against a checksum list
# signed by MakeMKV's release key, so a tampered download fails the build.
#
# Usage: build-makemkv.sh <version> <destdir>
set -euxo pipefail

version=$1
dest=$2

work=$(mktemp -d)
cd "$work"

wget -q -O sha256sums.txt.sig "https://www.makemkv.com/download/makemkv-sha-${version}.txt"
GNUPGHOME=$(mktemp -d)
export GNUPGHOME
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 2ECF23305F1FC0B32001673394E3083A18042697
gpg --batch --decrypt --output sha256sums.txt sha256sums.txt.sig

for ball in makemkv-oss makemkv-bin; do
  wget -q -O "$ball.tgz" "https://www.makemkv.com/download/${ball}-${version}.tar.gz"
  sha256=$(grep "  ${ball}-${version}[.]tar[.]gz\$" sha256sums.txt | cut -d' ' -f1)
  [ -n "$sha256" ]
  echo "$sha256 *$ball.tgz" | sha256sum -c -
  mkdir "$ball"
  tar -xzf "$ball.tgz" -C "$ball" --strip-components=1
  (
    cd "$ball"
    if [ -f configure ]; then
      # ARM drives makemkvcon only; the Qt GUI is not needed.
      ./configure --prefix=/usr/local --disable-gui
    else
      # makemkv-bin asks to accept its EULA interactively otherwise.
      mkdir -p tmp
      touch tmp/eula_accepted
    fi
    make -j"$(nproc)" PREFIX=/usr/local
    make install PREFIX=/usr/local DESTDIR="$dest"
  )
done

test -x "$dest/usr/local/bin/makemkvcon"
