#!/bin/ksh

#--------------------------------------------------------------------------
# Ericsson AB    SCRIPT
#--------------------------------------------------------------------------
#
# (c) Ericsson AB 2007 - All rights reserved.
# 
# The copyright to the computer program(s) herein is the property
# of Ericsson AB, Sweden. The programs may be used and/or copied
# only with the written permission from Ericsson AB or
# in accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# 
#------ History ----------------------------------------------------------- 
# Rev		Date		Prepared		Description
#
# PA1       110602		EWENHUG			Verify that ase_post_install is completed	
#--------------------------------------------------------------------------
#
#   Name       : tc28_syb_ase_install.sh
#
#   Description: Verify that ase_post_install is completed  
#
#   Arguments  : Check for following arguments:
#                -d = debug
#                -n = testcase name
#

# Init --------------------------------------------

RETURN_STATUS=0

# Read input options
while getopts "dn:" option
do
    case $option in
        d) DEBUG=1;;
        n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Verify that ase_post_install is completed]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------

# Do the test -------------------------------------
#
#

#check whether the OSS has been installed
if [ ! -f /ericsson/config/.iistage ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="The OSS_INSTALL failed"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	exit 1
fi

#check the status of the installation
OSS_STATUS=`cat /ericsson/config/.iistage`
if [ "$OSS_STATUS" != "done" ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="/ericsson/config/.iistage:`cat /ericsson/config/\.iistage`"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	exit 1
fi

#verify the ase_post_install is completed
RESULT=`grep "Finish - ASE Post Install" /var/opt/sybase/sybase/log/*masterdataservice.ERRORLOG* | wc -l`
if [ $RESULT -eq 0 ]; then 
	RETURN_STATUS=1
	RETURN_STATUS_REASON="The ase_post_install failed"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	exit 1
fi

exit $RETURN_STATUS



