#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="shadow"
_version="4.5"
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
build2 "sed -i src/Makefile.in -e 's/groups$(EXEEXT) //'" $_log
build2 "find man -name Makefile.in -exec sed -i \
  -e 's/man1\/groups\.1 //' \
  -e 's/man3\/getspnam\.3 //' \
  -e 's/man5\/passwd\.5 //' '{}' \;" $_log

build2 "CC=\"gcc ${BUILD64}\" ./configure \
    --sysconfdir=/etc \
    --with-group-name-max-length=32" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make -k check" $_log

# install
build2 "make install" $_log

build2 "sed -i /etc/login.defs \
    -e 's@#\(ENCRYPT_METHOD \).*@\1SHA512@' \
    -e 's@/var/spool/mail@/var/mail@'" $_log

build2 "mv -v /usr/bin/passwd /bin" $_log

build2 "touch /var/log/{fail,last}log" $_log
build2 "chgrp -v utmp /var/log/{fail,last}log" $_log
build2 "chmod -v 664 /var/log/{fail,last}log" $_log

build2 "pwconv" $_log
build2 "grpconv" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
