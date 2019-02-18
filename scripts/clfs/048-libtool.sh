#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="libtool"
_version="2.4.6"
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
	msg ":  \\${_yellow}SKIPPING\\${_normal}"
	exit 0
}

msg ""
	
# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "echo \"lt_cv_sys_dlsearch_path='/lib64 /usr/lib64 /usr/local/lib64 /opt/lib64'\" > config.cache" $_log
build2 "CC=\"gcc ${BUILD64}\" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --cache-file=config.cache" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make LDEMULATION=elf_i386 check" $_log

# install
build2 "make install" $_log
build2 "mv -v /usr/bin/libtool{,-64}" $_log
build2 "ln -sv multiarch_wrapper /usr/bin/libtool" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
