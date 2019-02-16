#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="binutils"
_version="2.30"
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
[ -d binutils-build ] && rm -rf binutils-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
expect -c "spawn ls"
#[ ! "spawn ls" = "$spawn_ls" ] && die "PTY Error!"

build2 "mkdir -v ../binutils-build" $_log
build2 "cd ../binutils-build" $_log

build2 "CC=\"gcc -isystem /usr/include ${BUILD64}\" \
LDFLAGS=\"-Wl,-rpath-link,/usr/lib64:/lib64:/usr/lib:/lib ${BUILD64}\" \
../$_sourcedir/configure \
    --prefix=/usr \
    --enable-shared \
    --enable-64-bit-bfd \
    --libdir=/usr/lib64 \
    --enable-gold=yes \
    --enable-plugins \
    --with-system-zlib \
    --enable-threads" $_log

# build
build2 "make tooldir=/usr" $_log

#build2 "make -k check" $_log

# install
build2 "make tooldir=/usr install" $_log

# clean up
cd ..
rm -rf binutils-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
