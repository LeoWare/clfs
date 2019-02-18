#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="mpc"
_version="1.1.0"
_sourcedir="$_package-$_version"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  ${_yellow}SKIPPING${_normal}"
	exit 0
}

msg ""
	
# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "CC=\"gcc -isystem /usr/include ${BUILD64}\" \
LDFLAGS=\"-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}\" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/$_package-$_version" $_log

# build
build2 "make $MKFLAGS" $_log
build2 "make html" $_log

#build2 "make check" $_log

# install
build2 "make install" $_log
build2 "make install-html" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
