#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="sysvinit"
_version="2.93"
_sourcedir="$_package-$_version"
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  SKIPPING"
	exit 0
}

msg ""
	
# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "patch -Np1 -i ../../sources/${_package}-${_version}-tools_updates-1.patch" $_log

# build
build2 "make $MKFLAGS -C src clobber" $_log
build2 "make $MKFLAGS -C src CC=\"\${CC}\"" $_log

# install
build2 "make -C src ROOT=$TOOLS install" $_log

cat > /tools/etc/inittab << "EOF"
# Begin /tools/etc/inittab

id:3:initdefault:

si::sysinit:/tools/etc/rc.d/init.d/rc sysinit

l0:0:wait:/tools/etc/rc.d/init.d/rc 0
l1:S1:wait:/tools/etc/rc.d/init.d/rc 1
l2:2:wait:/tools/etc/rc.d/init.d/rc 2
l3:3:wait:/tools/etc/rc.d/init.d/rc 3
l4:4:wait:/tools/etc/rc.d/init.d/rc 4
l5:5:wait:/tools/etc/rc.d/init.d/rc 5
l6:6:wait:/tools/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/tools/sbin/shutdown -t1 -a -r now

su:S016:once:/tools/sbin/sulogin

EOF

cat >> /tools/etc/inittab << "EOF"
1:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty1 9600
2:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty2 9600
3:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty3 9600
4:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty4 9600
5:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty5 9600
6:2345:respawn:/tools/sbin/agetty --noclear -I '\033(K' tty6 9600
c0:12345:respawn:/tools/sbin/agetty --noclear 115200 ttyS0 vt100

# End /tools/etc/inittab
EOF

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
