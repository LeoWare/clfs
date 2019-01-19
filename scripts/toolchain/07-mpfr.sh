#!/bin/bash
exit 0
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="mpfr"
_version="4.0.1"
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
#build "+ patch -Np1 -i ../../sources/mpfr-3.1.2-fixes-4.patch" "patch -Np1 -i ../../sources/mpfr-3.1.2-fixes-4.patch" $_log
build2 "LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" ./configure --prefix=$CROSS_TOOLS --disable-static --with-gmp=$CROSS_TOOLS" $_log

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
