#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="Symlinks and Files"
_version="0.01"
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
ln -sfv /tools/bin/{bash,cat,echo,grep,login,pwd,stty} ${LFS}/bin
ln -sfv /tools/bin/file ${LFS}/usr/bin
ln -sfv /tools/lib/libgcc_s.so{,.1} ${LFS}/usr/lib
ln -sfv /tools/lib64/libgcc_s.so{,.1} ${LFS}/usr/lib64
ln -sfv /tools/lib/libstdc++.so{.6,} ${LFS}/usr/lib
ln -sfv /tools/lib64/libstdc++.so{.6,} ${LFS}/usr/lib64
sed -e 's/tools/usr/' /tools/lib/libstdc++.la > ${LFS}/usr/lib/libstdc++.la
ln -sfv bash ${LFS}/bin/sh
ln -sfv /tools/sbin/init ${LFS}/sbin
ln -sfv /tools/etc/{login.{access,defs},limits} ${LFS}/etc
ln -sfv /proc/self/mounts ${LFS}/etc/mtab


cat > ${LFS}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/bash
bin:x:1:1:/bin:/bin/false
daemon:x:2:6:/sbin:/bin/false
adm:x:3:16:adm:/var/adm:/bin/false
lp:x:10:9:lp:/var/spool/lp:/bin/false
messagebus:x:27:27:D-Bus Message Daemon User:/dev/null:/bin/false
mail:x:30:30:mail:/var/mail:/bin/false
systemd-bus-proxy:x:71:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
nobody:x:65534:65533:Unprivileged User:/dev/null:/bin/false
EOF

cat > ${LFS}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:5:
tape:x:4:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
console:x:17:
mail:x:30:
messagebus:x:27:
nogroup:x:65533:
systemd-bus-proxy:x:72:
systemd-journal:x:28:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
wheel:x:39:
EOF

cat > ${LFS}/etc/fstab << EOF
# Begin /etc/fstab

# file system  mount-point  type   options          dump  fsck
#                                                         order

/dev/loop2p3        /            ext4  defaults          1     1
/dev/loop2p2   /boot/efi        vfat  defaults          0     0
devpts         /dev/pts     devpts gid=5,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0
efivarfs       /sys/firmware/efi/efivars  efivarfs  defaults  0      0

# End /etc/fstab
EOF

cat > ${LFS}/root/.bash_profile << EOF
set +h
PS1='{CLFS BUILD} \u:\w\$ '
LC_ALL=POSIX
PATH=/bin:/usr/bin:/sbin:/usr/sbin:$TOOLS/bin:$TOOLS/sbin
export LC_ALL PATH PS1
export BUILD32="${BUILD32}"
export BUILD64="${BUILD64}"
export CLFS_TARGET32="${CLFS_TARGET32}"
EOF


# clean up
#cd ..
#rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
