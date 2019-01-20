#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="bzip2"
_version="1.0.6"
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
build2 "cp -v Makefile{,.orig}" $_log
build2 "sed -e 's@^\(all:.*\) test@\1@g' \
    -e 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile.orig > Makefile" $_log

# build
build2 "make $MKFLAGS CC=\"${CC}\" AR=\"${AR}\" RANLIB=\"${RANLIB}\"" $_log

# install
build2 "make PREFIX=$TOOLS install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
