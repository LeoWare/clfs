#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="perl"
_version="5.26.0"
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
build2 "export BUILD_ZLIB=False" $_log
build2 "export BUILD_BZIP2=0" $_log

[ -f /etc/hosts ] || build2 "echo \"127.0.0.1 localhost \$(hostname)\" > /etc/hosts" $_log

build2 "./configure.gnu \
    --prefix=/usr \
    -Dvendorprefix=/usr \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager=\"/bin/less -isR\" \
    -Dcc=\"gcc ${BUILD32}\" \
    -Dusethreads \
    -Duseshrplib" $_log

# build
build2 "make" $_log

#build2 "make test" $_log

# install
build2 "make install" $_log
build2 "unset BUILD_ZLIB BUILD_BZIP2" $_log

build2 "mv -v /usr/bin/perl{,-32}" $_log
build2 "mv -v /usr/bin/perl5.26.0{,-32}" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
