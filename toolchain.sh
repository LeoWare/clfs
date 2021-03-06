#!/bin/bash
#################################################
# Title:    toolchain.sh			            #
# Date:     2018-12-20			                #
# Version:	0.1			                     	#
# Author:	<samuel@samuelraynor.com>	        #
# Options:					                    #
#################################################

set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall
source config.inc
source function.inc
PRGNAME=${0##*/}	# script name minus the path

#
#	Main line	
#
#msg "Building Chapter 5 Tool chain"
[ "${LFS_USER}" != $(whoami) ] && die "Not lfs user: FAILURE"
[ -z "${CLFS_TARGET}" ]  && die "Environment not set: FAILURE"
[ "${LFS}${LFS_TOP}" = $(pwd) ] && build "Changing to ${LFS}${LFS_TOP}" "cd ${LFS}${LFS_TOP}" "${LOGDIR}/toolchain.log"


# execute all toolchain scripts
for script in `find $LFS$LFS_TOP/scripts/toolchain -type f | sort`
do
	cd $LFS$LFS_TOP/$BUILDDIR

	# TODO: build a check so we're not sourcing it every time. doesn't hurt anything, though
	# if script is 16-build-variables,
	# reload ~/.bashrc
	source ~/.bashrc

	# execute the file
	TOPDIR=$LFS$LFS_TOP bash $script

done

touch "$LFS$LFS_TOP/$LOGDIR/toolchain.completed"
exit 0
