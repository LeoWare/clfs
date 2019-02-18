#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="vim"
_version="8.0"
_sourcedir="${_package}80"
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
build2 "patch -Np1 -i $TOPDIR/$SOURCESDIR/vim-8.0-branch_update-1.patch" $_log
build2 "echo '#define SYS_VIMRC_FILE \"/etc/vimrc\"' >> src/feature.h" $_log

build2 "CC=\"gcc ${BUILD64}\" CXX=\"g++ ${BUILD64}\" \
    ./configure \
    --prefix=/usr" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make test" $_log

# install
build2 "make -j1 install" $_log

build2 "ln -sv vim /usr/bin/vi" $_log

build2 "ln -sv ../vim/vim0597/doc /usr/share/doc/vim-8.0" $_log

# configuration
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
set ruler
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
