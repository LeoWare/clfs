#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="linux"
_version="4.15.3"
_sourcedir="$_package-$_version"
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

msg_line "Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  SKIPPING"
	exit 0
}

msg ""
	
# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
#build "+ xzcat $LFS$LFS_TOP/$SOURCESDIR/patch-3.14.21.xz | patch -Np1 -i -" "xzcat $LFS$LFS_TOP/$SOURCESDIR/patch-3.14.21.xz | patch -Np1 -i -" $_log
#build "  Configuring... " "./configure --prefix=/cross-tools --disable-static" $_log

# build
build2 "make mrproper" $_log
build2 "make ARCH=x86_64 headers_check" $_log

# install
build2 "make ARCH=x86_64 INSTALL_HDR_PATH=${TOOLS} headers_install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
