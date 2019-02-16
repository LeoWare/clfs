#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="man-db"
_version="2.7.6.1"
_sourcedir="$_package-$_version"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

[ -e $_completed ] && {
    msg ":  ${_yellow}SKIPPING${_normal}"
    exit 0
}

msg ""

# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "PKG_CONFIG_PATH=\"${PKG_CONFIG_PATH64}\" \
    CC=\"gcc ${BUILD64}\" \
./configure \
    --prefix=/usr \
    --libexecdir=/usr/lib64 \
    --docdir=/usr/share/doc/man-db-2.7.6.1 \
    --sysconfdir=/etc \
    --libdir=/usr/lib64 \
    --disable-setuid \
    --enable-cache-owner=bin \
    --with-browser=/usr/bin/lynx \
    --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap" $_log

# build
build2 "make" $_log

build2 "make check" $_log

# install
build2 "make install" $_log

build2 "sed -i \"s:man man:root root:g\" /usr/lib/tmpfiles.d/man-db.conf" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
