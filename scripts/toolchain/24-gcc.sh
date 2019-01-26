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

# prep
build2 "patch -Np1 -i ../../sources/${_package}-7.1.0-specs-1.patch" $_log
build2 "patch -Np1 -i ../../sources/isl-includes.patch" $_log

build2 "echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 \"/tools/lib/\"\n' >> gcc/config/linux.h" $_log
build2 "echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 \"\"\n' >> gcc/config/linux.h" $_log

build2 "cp -v gcc/Makefile.in{,.orig}" $_log
build2 "sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in" $_log

build2 "mkdir -v ../gcc-build" $_log
build2 "cd ../gcc-build" $_log

ln -s /usr/bin/true makeinfo
_oldPath=$PATH
build2 "export PATH=\$(pwd):${PATH}" $_log

build2 "../$_sourcedir/configure \
    --prefix=$TOOLS \
    --libdir=$TOOLS/lib64 \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --target=${CLFS_TARGET} \
    --with-local-prefix=/tools \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --with-native-system-header-dir=$TOOLS/include \
    --disable-libssp \
    --enable-install-libiberty" $_log

# build
build2 "make $MKFLAGS AS_FOR_TARGET=\"${AS}\" \
    LD_FOR_TARGET=\"${LD}\"" $_log

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
