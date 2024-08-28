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
# Rev     Date      Prepared        Description
#
# PA1     110718    EWENHUG         Check the device is not a real file but a link 
#--------------------------------------------------------------------------
#
#   Name       : check_permission.sh
#
#   Description: Generic check file/directory access permission testscript
#
#   Arguments  : Check for following arguments:
#					-d = debug
#					-f = device to be checked
#					-n = testcase name
#


# Init --------------------------------------------
RETURN_STATUS=0
RECURSE=FALSE
while getopts "df:n:" option
do
    case $option in
		d) DEBUG=1;;
		f) DEVICE=$OPTARG;;
		n) TEST_CASE=$OPTARG;;			 
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Check the device is not a real file but a link]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


#---------do the test------------------------------

if [ -f $DEVICE ]; then
	REATURN_STATUS=1
	REATURN_STATUS_REASON="Failed to find the device at $DEVICE"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	exit 1
fi

DOC=`ls -l $DEVICE | cut -c1`

if [ $DOC="l" ]; then
	echo "$DEVICE is a link file, and linked to `ls -l $DEVICE` | awk '{print $11}'"
else
	RETRUN_STATUS=0
	REATURN_STATUS_REASON="$DEVICE is not a link file"
fi

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------