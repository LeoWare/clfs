#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="ncurses"
_version="6.1"
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
build2 "PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC=\"gcc ${BUILD64}\" CXX=\"g++ ${BUILD64}\" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --with-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib64/pkgconfig" $_log

# build
build2 "make" $_log

#build2 "make -k check" $_log

# install
build2 "make install" $_log

build2 "mv -v /usr/bin/ncursesw6-config{,-64}" $_log
build2 "ln -svf multiarch_wrapper /usr/bin/ncursesw6-config" $_log

build2 "mv -v /usr/lib64/libncursesw.so.* /lib64" $_log
build2 "ln -svf ../../lib64/\$(readlink /usr/lib64/libncursesw.so) /usr/lib64/libncursesw.so" $_log

for lib in ncurses form panel menu ; do
        build2 "echo \"INPUT(-l${lib}w)\" > /usr/lib64/lib${lib}.so" $_log
        build2 "ln -sfv lib${lib}w.a /usr/lib64/lib${lib}.a" $_log
done

build2 "ln -sfv libncurses++w.a /usr/lib64/libncurses++.a" $_log
build2 "ln -sfv ncursesw6-config-64 /usr/bin/ncurses6-config-64" $_log
build2 "ln -sfv ncursesw6-config /usr/bin/ncurses6-config" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
