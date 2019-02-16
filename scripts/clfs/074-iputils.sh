#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="iputils"
_version="s20150815"
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
build2 "patch -Np1 -i $TOPDIR/$SOURCESDIR/iputils-s20150815-build-1.patch" $_log

# build
build2 "make CC=\"gcc ${BUILD64}\" \
    TARGETS=\"clockdiff ping rdisc tracepath tracepath6 traceroute6\"" $_log

# install
build2 "install -v -m755 ping /bin && \
install -v -m755 clockdiff /usr/bin && \
install -v -m755 rdisc /usr/bin && \
install -v -m755 tracepath /usr/bin && \
install -v -m755 trace{path,route}6 /usr/bin && \
install -v -m644 doc/*.8 /usr/share/man/man8 && \
ln -sv ping /bin/ping4 && \ 
ln -sv ping /bin/ping6" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
