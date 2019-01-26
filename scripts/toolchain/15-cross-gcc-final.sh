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
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

msg_line "Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  SKIPPING"
	exit 0
}

msg ""
	
# unpack sources
[ -d gcc-build ] && rm -rf gcc-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir
# unpack "${PWD}" "mpfr-4.0.1"
# unpack "${PWD}" "gmp-6.1.2"
# unpack "${PWD}" "mpc-1.1.0"
# unpack "${PWD}" "isl-0.20"
# mv -v mpfr-4.0.1 mpfr
# mv -v gmp-6.1.2 gmp
# mv -v mpc-1.1.0 mpc
# mv -v isl-0.20 mpc

# prep
build2 "patch -Np1 -i ../../sources/${_package}-7.1.0-specs-1.patch" $_log
build2 "patch -Np1 -i ../../sources/isl-includes.patch" $_log

build2 "echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 \"/tools/lib/\"\n' >> gcc/config/linux.h" $_log
build2 "echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 \"\"\n' >> gcc/config/linux.h" $_log

build2 "mkdir -v ../gcc-build" $_log
build2 "cd ../gcc-build" $_log

build2 "AR=ar \
    LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" \
    ../$_sourcedir/configure \
    --prefix=$CROSS_TOOLS \
    --build=${CLFS_HOST} \
    --target=${CLFS_TARGET} \
    --host=${CLFS_HOST} \
    --with-sysroot=${CLFS} \
    --with-local-prefix=$TOOLS \
    --with-native-system-header-dir=$TOOLS/include \
    --disable-static \
    --enable-languages=c,c++ \
    --with-mpc=$CROSS_TOOLS \
    --with-mpfr=$CROSS_TOOLS \
    --with-gmp=$CROSS_TOOLS \
    --with-isl=$CROSS_TOOLS" $_log

# build

build2 "make $MKFLAGS \
    AS_FOR_TARGET=\"${CLFS_TARGET}-as\" \
    LD_FOR_TARGET=\"${CLFS_TARGET}-ld\"" $_log

# install
build2 "make install" $_log

# clean up
cd ..
rm -rf gcc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
