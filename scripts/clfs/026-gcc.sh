#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="gcc"
_version="7.1.0"
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
[ -d gcc-build ] && rm -rf gcc-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "patch -Np1 -i ../../sources/isl-includes.patch" $_log

build2 "sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in" $_log

build2 "mkdir -v ../gcc-build" $_log
build2 "cd ../gcc-build" $_log

build2 "SED=sed CC=\"gcc -isystem /usr/include ${BUILD64}\" \
CXX=\"g++ -isystem /usr/include ${BUILD64}\" \
LDFLAGS=\"-Wl,-rpath-link,/usr/lib64:/lib64:/usr/lib:/lib\" \
../$_sourcedir/configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --libexecdir=/usr/lib64 \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --enable-install-libiberty \
    --disable-bootstrap" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "ulimit -s 32768" $_log
#build2 "make -k check" $_log

# install
build2 "make install" $_log

build2 "ln -sfv ../usr/bin/cpp /lib" $_log

build2 "mv -v /usr/lib/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib" $_log
build2 "mv -v /usr/lib64/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib64" $_log

# clean up
cd ..
rm -rf gcc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
