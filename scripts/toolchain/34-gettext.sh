#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="gettext"
_version="0.19.1"
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
build2 "cd gettext-tools" $_log
build2 "echo \"gl_cv_func_wcwidth_works=yes\" > config.cache" $_log


build2 "./configure --prefix=$TOOLS \
    --build=${CLFS_HOST} --host=${CLFS_TARGET} \
    --disable-shared --cache-file=config.cache" $_log

# build
build2 "make $MKFLAGS -C gnulib-lib" $_log
build2 "make $MKFLAGS -C src msgfmt msgmerge xgettext" $_log

# install
build2 "cp -v src/{msgfmt,msgmerge,xgettext} $TOOLS/bin" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
