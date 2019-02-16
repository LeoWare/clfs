#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="readline"
_version="7.0"
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
build2 "patch -Np1 -i $TOPDIR/$SOURCESDIR/readline-7.0-branch_update-1.patch" $_log

build2 "sed -i '/MV.*old/d' Makefile.in" $_log
build2 "sed -i '/{OLDSUFF}/c:' support/shlib-install" $_log

build2 "CC=\"gcc ${BUILD64}\" CXX=\"g++ ${BUILD64}\" \
    ./configure \
    --prefix=/usr \
    --libdir=/lib64 \
    --docdir=/usr/share/doc/readline-7.0" $_log

# build
build2 "make SHLIB_LIBS=-lncurses" $_log

# install
build2 "make SHLIB_LIBS=-lncurses htmldir=/usr/share/doc/readline-7.0 install" $_log

build2 "mv -v /lib64/lib{readline,history}.a /usr/lib64" $_log

build2 "ln -svf ../../lib64/\$(readlink /lib64/libreadline.so) /usr/lib64/libreadline.so" $_log
build2 "ln -svf ../../lib64/\$(readlink /lib64/libhistory.so) /usr/lib64/libhistory.so" $_log
build2 "rm -v /lib64/lib{readline,history}.so" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
