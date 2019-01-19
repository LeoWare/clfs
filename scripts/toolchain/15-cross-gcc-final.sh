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

build2 "mkdir -v ../gcc-build" $_log
build2 "cd ../gcc-build" $_log

ln -s /usr/bin/true makeinfo
_oldPath=$PATH
build2 "export PATH=\$(pwd):${PATH}" $_log

#build2 "export LD_LIBRARY_PATH=/tools/lib64:/tools/lib32"
build2 "AR=ar LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" \
    ../$_sourcedir/configure --prefix=$CROSS_TOOLS \
    --build=$CLFS_HOST --host=$CLFS_HOST --target=$CLFS_TARGET \
    --with-sysroot=$LFS --with-local-prefix=$TOOLS \
    --with-native-system-header-dir=$TOOLS/include \
    --disable-nls --disable-static --enable-languages=c,c++ \
    --enable-__cxa_atexit --enable-threads=posix \
    --with-system-zlib --enable-checking=release \
    --enable-libstdcxx-time --disable-libgomp" $_log

# build

build2 "make $MKFLAGS AS_FOR_TARGET=\"${CLFS_TARGET}-as\" LD_FOR_TARGET=\"${CLFS_TARGET}-ld\"" $_log

# install
build2 "make install" $_log

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
