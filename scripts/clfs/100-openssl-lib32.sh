#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="openssl"
_version="1.1.0g"
_sourcedir="${_package}-${_version}"
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
build2 "./config \
    --prefix=/usr \
    --docdir=/usr/share/doc/${_package}-${_version} \
    zlib-dynamic \
    shared \
    --libdir=lib64 \
    --openssldir=/etc/ssl" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make test" $_log

# install
build2 "sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile" $_log
build2 "make MANSUFFIX=ssl install" $_log
build2 "mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.0g" $_log
build2 "cp -vfr doc/* /usr/share/doc/openssl-1.1.0g" $_log

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
