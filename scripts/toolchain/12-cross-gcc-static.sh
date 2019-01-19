#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="gcc"
_version="8.2.0"
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
unpack "${PWD}" "mpfr-4.0.1"
unpack "${PWD}" "gmp-6.1.2"
unpack "${PWD}" "mpc-1.1.0"
mv -v mpfr-4.0.1 mpfr
mv -v gmp-6.1.2 gmp
mv -v mpc-1.1.0 mpc

# prep
build2 "patch -Np1 -i ../../sources/${_package}-${_version}-tools-path.patch" $_log

build2 "touch /tools/include/limits.h" $_log

build2 "mkdir -v ../gcc-build" $_log
build2 "cd ../gcc-build" $_log

ln -s /usr/bin/true makeinfo
_oldPath=$PATH
export PATH=$(pwd):${PATH}

# build2 "AR=ar LDFLAGS=\"-Wl,-rpath,/cross-tools/lib\" \
#     ../$_sourcedir/configure --prefix=$CROSS_TOOLS \
#     --build=$CLFS_HOST --host=$CLFS_HOST --target=$CLFS_TARGET \
#     --with-sysroot=$LFS --with-local-prefix=$TOOLS \
#     --with-native-system-header-dir=$TOOLS/include --disable-nls \
#     --disable-shared --with-mpfr=$CROSS_TOOLS --with-gmp=$CROSS_TOOLS \
#     --with-mpc=$CROSS_TOOLS --without-headers \
#     --with-newlib --disable-decimal-float --disable-libgomp --disable-libmudflap \
#     --disable-libssp --disable-libatomic --disable-libitm \
#     --disable-libsanitizer --disable-libquadmath --disable-threads \
#     --disable-target-zlib --with-system-zlib \
#     --enable-languages=c --enable-checking=release" $_log

build2 "AR=ar LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" \
    ../$_sourcedir/configure --prefix=$CROSS_TOOLS \
    --build=$CLFS_HOST --host=$CLFS_HOST --target=$CLFS_TARGET \
    --with-sysroot=$LFS --with-local-prefix=$TOOLS \
    --with-native-system-header-dir=$TOOLS/include --disable-nls \
    --disable-shared --without-headers --with-glibc-version=2.11 \
    --with-newlib --disable-decimal-float --disable-libgomp --disable-libmudflap \
    --disable-libssp --disable-libatomic --disable-libmpx \
    --disable-libsanitizer --disable-libquadmath --disable-threads \
    --disable-target-zlib --with-system-zlib --disable-vtv \
    --enable-languages=c,c++ --enable-checking=release" $_log

# build

build2 "make $MKFLAGS all-gcc all-target-libgcc" $_log

# install
build2 "make install-gcc install-target-libgcc" $_log

# clean up
export PATH=$_oldPath
unset _oldPath
cd ..
rm -rf gcc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
