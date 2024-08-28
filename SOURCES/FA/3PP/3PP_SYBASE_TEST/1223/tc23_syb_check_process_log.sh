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
# PA1		090713		EJOSODO	                First Version	
#--------------------------------------------------------------------------
#
#   Name       : tc23_syb_check_process_log.sh 
#
#   Description: Checks that the process log is not too large 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#                -n = testcase name
#	TEST
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
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that the process log is not too large]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Do the test -------------------------------------
#
#

ACTUAL_LOG_SIZE=`ls -l /var/svc/log/ericsson-eric_3pp-sybase_process_monitor\:default.log | awk '{print $5}`
if [ ${ACTUAL_LOG_SIZE} -gt 10485760 ]; then
  RETURN_STATUS=1
  RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Sybase process monitor log size is too large."
fi

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
