#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="pciutils"
_version="3.5.6"
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
# build2 "./configure \
#     --prefix=$TOOLS \
#     --build=${CLFS_HOST} \
#     --host=${CLFS_TARGET} \
#     --libdir=$TOOLS/lib64 \
#     --docdir=$TOOLS/usr/share/doc/$_package-$_version\
#     --disable-static \
#     --disable-rpath" $_log

# build
#build2 "make ARCH=x86_64 CROSS_COMPILE=${CLFS_TARGET}- menuconfig" $_log
build2 "make $MKFLAGS PREFIX=$TOOLS \
    CROSS_COMPILE=$CLFS_TARGET- \
    HOST=$CLFS_TARGET- \
    SHAREDIR=$TOOLS/usr/share/hwdata \
    SHARED=yes" $_log


# install
build2 "make PREFIX=$TOOLS \
    CROSS_COMPILE=$CLFS_TARGET- \
    HOST=$CLFS_TARGET- \
    SHAREDIR=$TOOLS/usr/share/hwdata \
    SHARED=yes                 \
    install install-lib" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
