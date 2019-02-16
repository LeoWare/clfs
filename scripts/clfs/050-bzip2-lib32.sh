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
build2 "sed -i -e 's:ln -s -f \$(PREFIX)/bin/:ln -s :' Makefile" $_log
build2 "sed -i 's@X)/man@X)/share/man@g' Makefile" $_log

# build
build2 "make -f Makefile-libbz2_so CC=\"gcc ${BUILD32}\" CXX=\"g++ ${BUILD32}\"" $_log
build2 "make clean" $_log

build2 "make CC=\"gcc ${BUILD32}\" CXX=\"g++ ${BUILD32}\" libbz2.a" $_log

# install
build2 "cp -v libbz2.a /usr/lib" $_log
build2 "cp -av libbz2.so* /lib" $_log
build2 "ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
