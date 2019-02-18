#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="acl"
_version="2.2.52"
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
build2 "sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in" $_log
build2 "sed -i \"s:| sed.*::g\" test/{sbits-restore,cp,misc}.test" $_log

build2 "CC=\"gcc ${BUILD32}\" \
./configure \
    --prefix=/usr \
    --libdir=/lib \
    --libexecdir=/usr/lib" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make tests" $_log

# install
build2 "make install" $_log
build2 "make install-dev" $_log
build2 "make install-lib" $_log

build2 "ln -sfv ../../lib/\$(readlink /lib/libacl.so) /usr/lib/libacl.so" $_log
build2 "rm -v /lib/libacl.so" $_log

build2 "chmod 755 -v /lib/libacl.so.1.1.0" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
