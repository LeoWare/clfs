#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="linux"
_version="4.15.3"
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
build2 "make mrproper" $_log
build2 "cp -v $TOPDIR/config-$_version-clfs .config" $_log

# build
#build2 "make ARCH=x86_64 CROSS_COMPILE=${CLFS_TARGET}- menuconfig" $_log
build2 "make ARCH=x86_64 CROSS_COMPILE=${CLFS_TARGET}-" $_log


# install
build2 "make ARCH=x86_64 CROSS_COMPILE=${CLFS_TARGET}- INSTALL_MOD_PATH=$TOOLS modules_install" $_log

build2 "mkdir -pv $TOOLS/boot" $_log
build2 "cp -v arch/x86_64/boot/bzImage $TOOLS/boot/vmlinuz-clfs-$_version" $_log

build2 "cp -v System.map $TOOLS/boot/System.map-$_version" $_log

build2 "cp -v .config $TOOLS/boot/config-$_version" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
