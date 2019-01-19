#!/tools/bin/bash
#################################################
# Title:    build-shell.sh                      #
# Date:     2018-12-20                          #
# Version:  0.1                                 #
# Author:   <samuel@samuelraynor.com>           #
# Options:                                      #
#################################################

set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall
source config.inc
source function.inc
PRGNAME=${0##*/}    # script name minus the path

#
#   Main line   
#
#msg "Building Full System"
#[ "${LFS_USER}" != $(whoami) ] && die "Not lfs user: FAILURE"
[ -z "${CLFS_TARGET}" ]  && die "Environment not set: FAILURE"
[ "${LFS_TOP}" = $(pwd) ] && build "Changing to ${LFS_TOP}" "cd ${LFS_TOP}" "${LOGDIR}/build-shell.log"


# execute all toolchanin scripts
for script in `find $LFS_TOP/scripts/clfs -type f | sort`
do
    cd $LFS_TOP/$BUILDDIR

    # execute the file
    TOPDIR=$LFS_TOP bash $script

done

exit 1
touch "$LFS_TOP/$LOGDIR/build-shell.completed"
exit 0
