#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="vim"
_version="8.0"
_sourcedir="${_package}80"
_log="$LFS$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS$LFS_TOP/$LOGDIR/$_prgname.completed"

msg_line "Building $_package-$_version"

[ -e $_completed ] && {
	msg ":  SKIPPING"
	exit 0
}

msg ""
	
# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "patch -Np1 -i ../../sources/vim-8.0-branch_update-1.patch" $_log

cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_toupper_broken=no
vim_cv_tty_group=world
vim_cv_tgent=zero
EOF

build2 "echo '#define SYS_VIMRC_FILE \"/tools/etc/vimrc\"' >> src/feature.h" $_log

build2 "./configure \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --prefix=$TOOLS \
    --enable-gui=no \
    --disable-gtktest \
    --disable-xim \
    --disable-gpm \
    --without-x \
    --disable-netbeans \
    --with-tlib=ncurses" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make -j1 install" $_log

build2 "ln -sv vim $TOOLS/bin/vi" $_log

cat > $TOOLS/etc/vimrc << "EOF"
" Begin /tools/etc/vimrc

set nocompatible
set backspace=2
set ruler
syntax on

" End /tools/etc/vimrc
EOF

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
