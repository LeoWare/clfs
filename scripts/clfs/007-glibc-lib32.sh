#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="glibc"
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
[ -d glibc-build ] && rm -rf glibc-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "patch -Np1 -i ../../sources/glibc-2.25-locX-fixes-1.patch" $_log

build2 "LINKER=\$(readelf -l $TOOLS/bin/bash | sed -n 's@.*interpret.*$TOOLS\\(.*\\)]\$@\\1@p')" $_log
build2 "sed -i \"s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=\${LINKER} -o|\" \
    scripts/test-installation.pl" $_log
build2 "unset LINKER" $_log

build2 "mkdir -v ../glibc-build" $_log
build2 "cd ../glibc-build" $_log

build2 "CC=\"gcc ${BUILD32}\" CXX=\"g++ ${BUILD32}\" \
../$_sourcedir/configure \
    --prefix=/usr \
    --enable-kernel=3.12.0 \
    --libexecdir=/usr/lib/glibc \
    --host=${CLFS_TARGET32} \
    --build=${CLFS_TARGET} \
    --enable-stack-protector=strong \
    --enable-obsolete-rpc" $_log
# build
build2 "make $MKFLAGS" $_log

# install
build2 "touch /etc/ld.so.conf" $_log
build2 "make install" $_log
build2 "rm -v /usr/include/rpcsvc/*.x" $_log

# clean up
cd ..
rm -rf glibc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
