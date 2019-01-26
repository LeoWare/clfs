#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="kmod"
_version="24"
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
build2 "cp -v libkmod/libkmod.c{,.orig}" $_log
build2 "sed '/dirname_default_prefix /s@/lib/modules@/tools&@' \
    libkmod/libkmod.c.orig > libkmod/libkmod.c" $_log

build2 "./configure \
    --prefix=$TOOLS \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=$TOOLS/lib64 \
    --with-xz \
    --with-zlib" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log
build2 "ln -sfv kmod $TOOLS/bin/lsmod" $_log
build2 "ln -sfv ../bin/kmod $TOOLS/sbin/depmod" $_log
build2 "ln -sfv ../bin/kmod $TOOLS/sbin/insmod" $_log
build2 "ln -sfv ../bin/kmod $TOOLS/sbin/modprobe" $_log
build2 "ln -sfv ../bin/kmod $TOOLS/sbin/modinfo" $_log
build2 "ln -sfv ../bin/kmod $TOOLS/sbin/rmmod" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
