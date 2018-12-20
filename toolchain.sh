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
[ -z "${LFS_TGT}" ]  && die "Environment not set: FAILURE"
[ ${PATH} = "/tools/bin:/bin:/usr/bin" ] || die "Path not set: FAILURE"
[ "${LFS}${LFS_TOP}" = $(pwd) ] && build "Changing to ${LFS}${LFS_TOP}" "cd ${LFS}${LFS_TOP}" "${LOGDIR}/toolchain.log"


# execute all toolchanin scripts
for script in `find $LFS_TOP/scripts/toolchain/ | sort`
do
	# source the file to share the environment
	source $script
done
exit 1
touch "$LOGDIR/toolchain.completed"
exit 0
