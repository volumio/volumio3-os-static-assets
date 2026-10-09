#!/bin/bash
set -euo pipefail

JOBS=${1:-4}
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$HERE/out"
NAME=wpewebkit-armhf-build
mkdir -p "$OUT"

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --platform linux/arm64 -v "$OUT":/out -v "$HERE":/recipe:ro \
  debian:bookworm sleep infinity >/dev/null
trap 'docker rm -f "$NAME" >/dev/null 2>&1' EXIT

docker exec -e JOBS="$JOBS" "$NAME" bash -euo pipefail -c '
export DEBIAN_FRONTEND=noninteractive
export DEB_BUILD_OPTIONS="nocheck noddebs nodoc parallel=$JOBS"
export DEB_CFLAGS_APPEND=-g0 DEB_CXXFLAGS_APPEND=-g0
export DEBEMAIL=info@volumio.org DEBFULLNAME=Volumio

dpkg --add-architecture armhf
cat > /etc/apt/sources.list.d/trixie-src.sources <<EOF
Types: deb-src
URIs: http://deb.debian.org/debian
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
apt-get -qq update
apt-get -qq install -y --no-install-recommends crossbuild-essential-armhf dpkg-dev devscripts equivs fakeroot ca-certificates >/dev/null

cd /tmp && equivs-build -a armhf /recipe/gobject-introspection-placeholder >/dev/null
apt-get -qq install -y ./gobject-introspection_*_armhf.deb >/dev/null

mkdir -p /src && cd /src
apt-get source -qq libwpe/trixie wpebackend-fdo/trixie wpewebkit/trixie cog/trixie >/dev/null 2>&1

build() {
  cd /src/$1
  sed -i "s/dpkg-dev (>= 1.22.5)/dpkg-dev (>= 1.21)/; s/^\( *\)unifdef,/\1unifdef:native,/" debian/control
  dch -b -v "$(dpkg-parsechangelog -S Version)~bpo12+1" -D bookworm --force-distribution "Rebuild for bookworm armhf."
  apt-get -qq build-dep -y -a armhf --arch-only --no-install-recommends . >/dev/null
  dpkg-buildpackage -a armhf -B -us -uc
  cd /src && apt-get -qq install -y --no-install-recommends ./*~bpo12+1_armhf.deb >/dev/null
}

build libwpe-1.16.2
build wpebackend-fdo-1.16.0
build wpewebkit-2.48.3
build cog-0.18.4

cp /src/*~bpo12+1_armhf.deb /out/
'
ls -l "$OUT"
