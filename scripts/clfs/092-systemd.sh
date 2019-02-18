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
build2 "sed -i '/virt-install-hook /d' Makefile.in" $_log

build2 "sed -i '/timesyncd.conf/d' src/timesync/timesyncd.conf.in" $_log

cat > config.cache << "EOF"
KILL="/bin/kill"
MOUNT_PATH="/bin/mount"
UMOUNT_PATH="/bin/umount"
SULOGIN="/sbin/sulogin"
XSLTPROC="/usr/bin/xsltproc"
cc_cv_LDFLAGS__Wl__fuse_ld_gold=no
EOF

build2 "CC=\"gcc ${BUILD64}\" PKG_CONFIG_PATH=\"${PKG_CONFIG_PATH64}\" \
    ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libexecdir=/usr/lib64 \
    --disable-tests        \
    --docdir=/usr/share/doc/systemd-233 \
    --with-rootprefix="" \
    --with-rootlibdir=/lib64 \
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

build2 "sed -e 's@test/udev-test.pl @@'  \
        -e 's@test-copy\$(EXEEXT) @@' \
        -i Makefile.in" $_log

#build2 "sed -i \"s:minix:ext4:g\" src/test/test-path-util.c" $_log
#build2 "make check" $_log

# install
build2 "make install" $_log

build2 "install -v -m644 man/*.html /usr/share/doc/systemd-233" $_log

#build2 "rm -rfv /usr/lib/rpm" $_log

for tool in runlevel reboot shutdown poweroff halt telinit; do
    build2 "ln -sfv ../bin/systemctl /sbin/$tool" $_log
done
build2 "ln -sfv ../lib/systemd/systemd /sbin/init" $_log

# TODO: Might not want to do this here
systemd-machine-id-setup

cat > /etc/os-release << "EOF"
# Begin /etc/os-release

NAME=Cross-LFS
ID=clfs

PRETTY_NAME=Cross Linux From Scratch
ANSI_COLOR=0;33

VERSION=GIT-20170803
VERSION_ID=20170803

# End /etc/os-release
EOF

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
