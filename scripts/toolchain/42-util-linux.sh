#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="util-linux"
_version="2.33.1"
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
build2 "PKG_CONFIG_PATH=\"\" \
    ./configure \
    --prefix=$TOOLS \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir='\${prefix}'/lib64 \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \
    --disable-nologin \
    --without-python" $_log

build2 "sed -i 's/-lncursesw -ltinfo/-lncurses/' Makefile" $_log
build2 "sed -i 's/LIBNCURSESW/LIBNCURSES/' config.h" $_log

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
