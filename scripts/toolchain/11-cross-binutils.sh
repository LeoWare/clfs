#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="binutils"
_version="2.24"
_sourcedir="$_package-$_version"
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

msg_line "Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  SKIPPING"
	exit 0
}

msg ""
	
# unpack sources
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build "+ mkdir -v ../binutils-build" "mkdir -v ../binutils-build" $_log
build "+ cd ../binutils-build" "cd ../binutils-build" $_log

build "+ AR=ar AS=as ../$_sourcedir/configure --prefix=$CROSS_TOOLS --host=$CLFS_HOST --target=$CLFS_TARGET --with-sysroot=$LFS --with-lib-path=/tools/lib:/tools/lib64 --disable-nls --disable-static --enable-64-bit-bfd --disable-werror" "AR=ar AS=as ../$_sourcedir/configure --prefix=$CROSS_TOOLS --host=$CLFS_HOST --target=$CLFS_TARGET --with-sysroot=$LFS --with-lib-path=/tools/lib:/tools/lib64 --disable-nls --disable-static --enable-64-bit-bfd --disable-werror" $_log

# build
build "+ make $MKFLAGS" "make $MKFLAGS" $_log

# install
build "+ make install" "make install" $_log

# clean up
cd ..
rm -rf binutils-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
