#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="glibc"
_version="2.28"
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
[ -d glibc-build ] && rm -rf glibc-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "mkdir -v ../glibc-build" $_log
build2 "cd ../glibc-build" $_log

build2 "echo \"libc_cv_slibdir=$TOOLS/lib64\" >> config.cache" $_log

build2 "BUILD_CC=\"gcc\" \
    CC=\"${CLFS_TARGET}-gcc ${BUILD64}\" \
    AR=\"${CLFS_TARGET}-ar\" \
    RANLIB=\"${CLFS_TARGET}-ranlib\" \
    ../$_sourcedir/configure \
    --prefix=$TOOLS \
    --host=${CLFS_TARGET} \
    --build=${CLFS_HOST} \
    --libdir=$TOOLS/lib64 \
    --enable-kernel=3.12.0 \
    --with-binutils=$CROSS_TOOLS/bin \
    --with-headers=$TOOLS/include \
    --enable-obsolete-rpc \
    --cache-file=config.cache" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf glibc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
