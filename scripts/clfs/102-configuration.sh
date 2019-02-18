#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="configuration"
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

[ -e $_completed ] && {
    msg ":  ${_yellow}SKIPPING${_normal}"
    exit 0
}

msg ""

cat > /etc/vconsole.conf << "EOF"
KEYMAP=unicode
FONT=LatArCyrHeb-16
EOF

cat > /etc/profile << "EOF"
# Begin /etc/profile

source /etc/locale.conf

for f in /etc/bash_completion.d/*
do
  if [ -e ${f} ]; then source ${f}; fi
done
unset f

export INPUTRC=/etc/inputrc

# End /etc/profile
EOF

cat > /etc/locale.conf << "EOF"
# Begin /etc/locale.conf

LANG=en_US.UTF-8

# End /etc/locale.conf
EOF

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the
# value contained inside the 1st argument to the
# readline specific functions

"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type   options          dump  fsck
#                                                         order

${DEVICE}     /            ext4  defaults         1     1
${BOOT_DEVICE} /boot/efi   vfat  defaults,noexec,isocharset=iso8859-1   0   0

#/dev/[yyy]     swap         swap   pri=1            0     0

# End /etc/fstab
EOF

echo "clfs" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts
127.0.0.1 localhost                                                                                                               │
127.0.1.1 localhost localhost.localdomain                                                                                                       │
::1       localhost ip6-localhost ip6-loopback                                                                                    │
ff02::1   ip6-allnodes                                                                                                            │
ff02::2   ip6-allrouters   

# End /etc/hosts
EOF

# link to systemd's resolv.conf                                                                                           │
ln -sfv /run/systemd/network/resolv.conf /etc/resolv.conf

 
 # mask udev's 99-default.link                                                                                             │
ln -sfv /dev/null /etc/systemd/network/99-default.link

#groupadd -g 78 systemd-timesync
#useradd -g systemd-timesync -u 78 -d /dev/null -s /bin/false systemd-timesync

#systemctl enable systemd-timesyncd

# make .completed file
touch $_completed

# exit sucessfull
exit 0
