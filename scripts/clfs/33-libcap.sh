#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="libcap"
_version="2.25"
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

# build
build2 "make CC=\"gcc ${BUILD64}\"" $_log

#build2 "make tests" $_log

# install
build2 "make lib=lib64 install" $_log

build2 "chmod -v 755 /lib64/libcap.so.2.25" $_log
build2 "ln -sfv ../../lib64/\$(readlink /lib64/libcap.so) /usr/lib64/libcap.so" $_log
build2 "rm -v /lib64/libcap.so" $_log
build2 "mv -v /lib64/libcap.a /usr/lib64" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
