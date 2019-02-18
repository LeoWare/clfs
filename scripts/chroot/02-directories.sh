#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="Creating Directories..."
_version=""
_sourcedir="$_package-$_version"
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

[ -e $_completed ] && {
    msg ":  SKIPPING"
    exit 0
}

msg ""
    
# unpack sources
#[ -d $_sourcedir ] && rm -rf $_sourcedir
#unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
#cd $_sourcedir

# prep

# build

# install
mkdir -pv ${LFS}/{bin,boot,dev,{etc/,}opt,home,lib{,64},mnt}
mkdir -pv ${LFS}/{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
mkdir -pv ${LFS}/var/{lock,log,mail,spool}
mkdir -pv ${LFS}/var/{opt,cache,lib{,64}/{misc,locate},local}
install -dv ${LFS}/root -m 0750
install -dv ${LFS}{/var,}/tmp -m 1777
ln -sv ../run ${LFS}/var/run
mkdir -pv ${LFS}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv ${LFS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${LFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${LFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
install -dv ${LFS}/usr/lib/locale
ln -sv ../lib/locale ${LFS}/usr/lib64
mkdir -pv ${LFS}/usr/local/games
mkdir -pv ${LFS}/usr/share/games

# clean up
#cd ..
#rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
