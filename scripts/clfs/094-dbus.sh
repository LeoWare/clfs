#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="dbus"
_version="1.10.18"
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
build2 "CC=\"gcc ${BUILD64}\" USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
    ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib64 \
    --libexecdir=/usr/lib64/dbus-1.0 \
    --localstatedir=/var \
    --with-systemdsystemunitdir=/lib/systemd/system \
    --docdir=/usr/share/doc/dbus-1.10.18 \
    SYSTEMD_LIBS=\"-L/lib64 -lsystemd\"" $_log

# build
build2 "make" $_log

# install
build2 "make install" $_log

build2 "mv -v /usr/lib64/libdbus-1.so.* /lib64" $_log

build2 "ln -sfv ../../lib64/\$(readlink /usr/lib64/libdbus-1.so) /usr/lib64/libdbus-1.so" $_log

build2 "ln -sv /etc/machine-id /var/lib/dbus" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
