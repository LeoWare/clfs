#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="cloog"
_version="0.18.2"
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
build "+ LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" ./configure --prefix=$CROSS_TOOLS --disable-static --with-gmp-prefix=$CROSS_TOOLS --with-isl-prefix=$CROSS_TOOLS" "LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" ./configure --prefix=$CROSS_TOOLS --disable-static --with-gmp-prefix=$CROSS_TOOLS  --with-isl-prefix=$CROSS_TOOLS" $_log
build "+ cp -v Makefile{,.orig}" "cp -v Makefile{,.orig}" $_log
build "+ sed '/cmake/d' Makefile.orig > Makefile" "sed '/cmake/d' Makefile.orig > Makefile" $_log

# build
build "+ make $MKFLAGS" "make $MKFLAGS" $_log

# install
build "+ make install" "make install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
