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
# PA1		080527		EASHIMA	                First Version
# PA2		121002		EDAVIOC			Included function
#							that retieves engines
#							from isql
#
#--------------------------------------------------------------------------
#
#   Name       : tc16_syb_chk_online_engines.sh 
#
#   Description: Checks online sybase engines 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#                -n = testcase name
#


# Init --------------------------------------------

ISQL=/opt/sybase/sybase/OCS-15_0/bin/isql
USERNAME=sa
PASSWORD=sybase11

#inc library
. /ericsson/syb/lib/syb_libsvc.sh

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
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that the number of Online Sybase Engines should be equal to the number of engines at startup]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Do the test -------------------------------------
#
#

get_actual_engines ()
{
$ISQL -U${USERNAME} -P${PASSWORD} -otempfile.txt << EOISQL
select  "value: ",value from  sysconfigures where lower(name) = "max online engines"
go
EOISQL

if [ -e tempfile.txt ] ; then
	VAL=`cat tempfile.txt | grep "value: " | awk '{print $2}'`
	return $VAL
else
	RETURN_STATUS=7
	RETURN_STATUS_REASON="Unable to get actual engine value from isql"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
        exit $RETURN_STATUS
fi
}

check_online_engines ()
{
	EXP_ONLINE_ENGINES=`cat /ericsson/config/system.ini | grep "max online engines" | awk -F"=" '{print$2}'`

	get_actual_engines
        ACT_ONLINE_ENGINES=$?

	#ACT_ONLINE_ENGINES=`ps -ef | grep dataserver | grep -v grep | wc -l 2>/dev/null`

        #if [ $? -ne 0 ]; then
        #        RETURN_STATUS=7 #Failed, can not execute
        #        RETURN_STATUS_REASON="No able to find actual online engines...." 
        #        echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
        #        exit $RETURN_STATUS
        #fi

 	if [ $ACT_ONLINE_ENGINES -eq $EXP_ONLINE_ENGINES ]; then
		echo "Number of Online Sybase Engines are equal to the number of engines at startup"
        else
	        RETURN_STATUS=1  
		if [ $ACT_ONLINE_ENGINES -gt 1 ]; then
			RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Number of online sybase engines: $ACT_ONLINE_ENGINES, are not equal to the number of engine(s) at startup: $EXP_ONLINE_ENGINES"
		else
			RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Number of online sybase engine: $ACT_ONLINE_ENGINES, is not equal to the number of engine(s) at startup: $EXP_ONLINE_ENGINES"
		fi
        fi
}


# MAIN ---------------------------------------------------------------

svc_online
RESULT=$?
if [ $RESULT -ne 0 ]; then
        RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Sybase SMF services cannot be enabled"
        echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
        exit 1
fi

# Check if expected native version is the same as real expected version
check_online_engines

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
