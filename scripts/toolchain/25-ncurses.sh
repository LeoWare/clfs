#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="ncurses"
_version="5.9"
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
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "sh ../../sources/ncurses-5.9-20141206-patch.sh" $_log
build2 "patch -Np1 -i ../../sources/ncurses-5.9-bash_fix-1.patch" $_log
build2 "./configure --prefix=$TOOLS --with-shared \
   --build=${CLFS_HOST} --host=${CLFS_TARGET} \
   --without-debug --without-ada \
   --enable-overwrite --with-build-cc=gcc \
   --libdir=$TOOLS/lib64" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
