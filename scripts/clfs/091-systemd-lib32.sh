#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="systemd"
_version="233"
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
cat > config.cache << "EOF"
KILL="/bin/kill"
MOUNT_PATH="/bin/mount"
UMOUNT_PATH="/bin/umount"
SULOGIN="/sbin/sulogin"
XSLTPROC="/usr/bin/xsltproc"
cc_cv_LDFLAGS__Wl__fuse_ld_gold=no
EOF

build2 "CC=\"gcc ${BUILD32}\" PKG_CONFIG_PATH=\"${PKG_CONFIG_PATH32}\" \
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libexecdir=/usr/lib \
    --disable-tests       \
    --docdir=/usr/share/doc/systemd-233 \
    --with-rootprefix="" \
    --with-rootlibdir=/lib \
    --enable-split-usr \
    --disable-firstboot \
    --disable-ldconfig \
    --disable-lto \
    --disable-sysusers \
    --with-default-dnssec=no \
    --with-kbd-loadkeys=/bin/loadkeys \
    --with-kbd-setfont=/bin/setfont \
    --with-dbuspolicydir=/etc/dbus-1/system.d \
    --with-dbussessionservicedir=/usr/share/dbus-1/services \
    --with-dbussystemservicedir=/usr/share/dbus-1/system-services \
    --config-cache" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make check" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
