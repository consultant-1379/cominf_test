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
# PA1       110602		EWENHUG			Verify if diagnostics is running	
#--------------------------------------------------------------------------
#
#   Name       : tc29_syb_diagnostic_verification 
#
#   Description: Verify if diagnostics is running  
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
echo "[OUTPUT:TESTCASEDESCRIPTION:Verify if diagnostics is running]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------

# Do the test -------------------------------------
#
#

#check the space of the admindb, which should be updated every 3 min.
RESULT1=`su - sybase -c "/ericsson/syb/util/Count.sh admindb" | grep "mon_t_dbspace" | awk '{print $2}'`
echo "The current szie of mon_t_dbspace is $RESULT1"

#first check if we could read the result
if [ ! $RESULT1 ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="Could not read the mon_t_dbspace in admindb"
	echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
	exit 1
fi

echo "Sleep for 3min to check the spaceagain"
sleep 200
echo "After sleeping"

RESULT2=`su - sybase -c "/ericsson/syb/util/Count.sh admindb" | grep "mon_t_dbspace" | awk '{print $2}'`
echo "The size of mont_t_dbspace after 3 mins is $RESULT2"

#first check if we could read the result
if [ ! $RESULT1 ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="Could not read the mon_t_dbspace in admindb"
	echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
	exit 1
fi

if [ $RESULT1 -ge $RESULT2 ]; then
	echo "ERROR(Count.sh): The mon_t_dbspace should be updated every 3mins"
	RETURN_STATUS_REASON="The mon_t_dbspace should be updated every 3mins"
	RETURN_STATUS=1
	echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
	exit 1
fi



# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
fi

exit $RETURN_STATUS

