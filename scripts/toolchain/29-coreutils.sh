#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="coreutils"
_version="8.30"
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
#cat > config.cache << EOF
#fu_cv_sys_stat_statfs2_bsize=yes
#gl_cv_func_working_mkstemp=yes
#EOF

build2 "./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --enable-install-program=hostname \
    --cache-file=config.cache" $_log

build2 "sed -i -e 's/^man1_MANS/#man1_MANS/' Makefile" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
