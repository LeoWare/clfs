#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="binutils"
_version="2.31"
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
[ -d binutils-build ] && rm -rf binutils-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
#build2 "patch -Np1 -i ../../sources/binutils-ch6.patch" $_log
build2 "mkdir -v ../binutils-build" $_log
build2 "cd ../binutils-build" $_log

build2 "../$_sourcedir/configure \
    --prefix=$TOOLS --libdir=$TOOLS/lib64 --with-lib-path=$TOOLS/lib64:$TOOLS/lib \
    --build=${CLFS_HOST} --host=${CLFS_TARGET} --target=${CLFS_TARGET} \
    --disable-nls --enable-shared --enable-64-bit-bfd" $_log

# build
#build2 "export CFLAGS=\"-Wno-error=unused-value\"" $_log
#build2 "CFLAGS=\"-Wno-error=unused-value\" make $MKFLAGS" $_log
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf binutils-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
