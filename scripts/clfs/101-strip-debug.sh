#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="strip-debug"
_version="20170803"
_sourcedir="${_package}-${_version}"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

# TODO: This file should be in a different directory

#####
# make .completed file
# comment this out to run the script
touch $_completed
#####

[ -e $_completed ] && {
    msg ":  ${_yellow}SKIPPING${_normal}"
    exit 0
}

msg ""

# This should be run after having logged out of the chroot and logging back in

/tools/bin/find /{,usr/}{bin,lib,lib64,sbin} -type f \
   -exec /tools/bin/strip --strip-debug '{}' ';'

# make .completed file
touch $_completed

# exit sucessfull
exit 0
