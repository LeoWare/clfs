#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}	# script name minus the path

_package="glibc"
_version="2.25"
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
[ -d glibc-build ] && rm -rf glibc-build
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
build2 "patch -Np1 -i ../../sources/glibc-2.25-locX-fixes-1.patch" $_log

build2 "LINKER=\$(readelf -l $TOOLS/bin/bash | sed -n 's@.*interpret.*$TOOLS\\(.*\\)]\$@\\1@p')" $_log
build2 "sed -i \"s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=\${LINKER} -o|\" \
    scripts/test-installation.pl" $_log
build2 "unset LINKER" $_log

build2 "mkdir -v ../glibc-build" $_log
build2 "cd ../glibc-build" $_log

build2 "echo \"libc_cv_slibdir=/lib64\" >> config.cache" $_log

build2 "CC=\"gcc ${BUILD64}\" CXX=\"g++ ${BUILD64}\" \
    ../$_sourcedir/configure \
    --prefix=/usr \
    --enable-kernel=3.12.0 \
    --libexecdir=/usr/lib64/glibc \
    --libdir=/usr/lib64 \
    --enable-stack-protector=strong \
    --enable-obsolete-rpc \
    --cache-file=config.cache" $_log

# build
build2 "make $MKFLAGS" $_log

# check
#build2 "make check" $_log

# install
build2 "touch /etc/ld.so.conf" $_log
build2 "make install" $_log

build2 "rm -v /usr/include/rpcsvc/*.x" $_log

build2 "cp -v ../glibc-2.25/nscd/nscd.conf /etc/nscd.conf" $_log
build2 'mkdir -pv /var/cache/nscd' $_log

build2 "install -v -Dm644 ../glibc-2.25/nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf" $_log
build2 "install -v -Dm644 ../glibc-2.25/nscd/nscd.service /lib/systemd/system/nscd.service" $_log

#build2 "make localedata/install-locales" $_log

build2 "mkdir -pv /usr/lib/locale" $_log
build2 "localedef -i de_DE -f ISO-8859-1 de_DE" $_log
build2 "localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro" $_log
build2 "localedef -i en_HK -f ISO-8859-1 en_HK" $_log
build2 "localedef -i en_PH -f ISO-8859-1 en_PH" $_log
build2 "localedef -i en_US -f ISO-8859-1 en_US" $_log
build2 "localedef -i es_MX -f ISO-8859-1 es_MX" $_log
build2 "localedef -i fa_IR -f UTF-8 fa_IR" $_log
build2 "localedef -i fr_FR -f ISO-8859-1 fr_FR" $_log
build2 "localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro" $_log
build2 "localedef -i it_IT -f ISO-8859-1 it_IT" $_log
build2 "localedef -i ja_JP -f EUC-JP ja_JP" $_log

printf "${_green}==>${_normal} Creating /etc/nsswitch.conf\n"
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

printf "${_green}==>${_normal} Installing timezone data\n"
build2 "tar -xf ../../sources/tzdata2017b.tar.gz" $_log

build2 "ZONEINFO=/usr/share/zoneinfo" $_log
build2 "mkdir -pv $ZONEINFO/{posix,right}" $_log

for tz in etcetera southamerica northamerica europe africa antarctica \
          asia australasia backward pacificnew systemv; do
    build2 "zic -L /dev/null   -d $ZONEINFO       -y \"sh yearistype.sh\" ${tz}" $_log
    build2 "zic -L /dev/null   -d $ZONEINFO/posix -y \"sh yearistype.sh\" ${tz}" $_log
    build2 "zic -L leapseconds -d $ZONEINFO/right -y \"sh yearistype.sh\" ${tz}" $_log
done

build2 "cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO" $_log
build2 "zic -d $ZONEINFO -p America/Los_Angeles" $_log
build2 "unset ZONEINFO" $_log
build2 "cp -v /usr/share/zoneinfo/America/Los_Angeles /etc/localtime" $_log

printf "${_green}==>${_normal} Creating /etc/ld.so.conf\n"
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib
/usr/local/lib64
/opt/lib
/opt/lib64

# End /etc/ld.so.conf
EOF

# clean up
cd ..
rm -rf glibc-build
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
