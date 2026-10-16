#!/bin/sh
# Verify the actual archive in a fresh directory without changing the host PHP setup.
set -eu
if [ "$#" -ne 1 ]; then
    echo "Usage: sh scripts/check-release.sh /path/to/scws-VERSION.tar.gz" >&2
    exit 2
fi
archive=$(realpath "$1")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
tar -xzf "$archive" -C "$work"
set -- "$work"/scws-*
test "$#" -eq 1
source=$1
test -x "$source/configure"
test -f "$source/README.md"
test -f "$source/phpext/scws_arginfo.h"
mkdir "$work/build"
cd "$work/build"
# A release user needs a compiler and make, but no core Autotools regeneration.
"$source/configure" --prefix="$work/install" \
    AUTOCONF=false AUTOHEADER=false AUTOMAKE=false ACLOCAL=false
make -j2
make install
"$work/install/bin/scws" -v
printf 'Linux installation smoke test\n' > "$work/input.txt"
"$work/install/bin/scws" -c utf8 -N -i "$work/input.txt" > "$work/result.txt"
grep -q Linux "$work/result.txt"
# Exercise the installed dictionary converter too, using an offline fixture.
"$work/install/bin/scws-gen-dict" -c utf8 \
    -i "$source/tests/dict.utf8.txt" -o "$work/test.xdb"
cd "$source/phpext"
"${PHPIZE:-phpize}"
./configure --with-scws="$work/install" --with-php-config="${PHP_CONFIG:-php-config}"
make -j2
make install INSTALL_ROOT="$work/php-install"
module=$(find "$work/php-install" -name scws.so -type f)
test -n "$module"
"${PHP:-php}" -n -d "extension=$module" -d error_reporting=-1 \
    "$source/tests/install-smoke.php" "$source/tests/dict.utf8.txt" \
    "$work/install/etc/rules.utf8.ini" "$work/test.xdb"
printf 'PASS: clean Linux library, CLI, dictionary converter and PHP extension installation\n'
