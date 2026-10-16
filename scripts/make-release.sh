#!/bin/sh
# Build a GNU source distribution, including generated configure/Makefile.in files.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"
sh ./acprep
./configure
make distcheck
version=$(sed -n 's/^AC_INIT(\[scws\], \[\([^]]*\)\].*/\1/p' configure.ac)
test -n "$version"
mkdir -p dist
cp "scws-$version.tar.gz" dist/
(cd dist && sha256sum "scws-$version.tar.gz" > "scws-$version.tar.gz.sha256")
printf 'Release archive: %s/dist/scws-%s.tar.gz\n' "$root" "$version"
