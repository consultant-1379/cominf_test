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
# PA1		070927		XRSSINI			Checks that the specified services (in SMF) are running if they exist
#--------------------------------------------------------------------------
#
#   Name       : check_svcs.sh
#
#   Description: Checks that the specified managed services in Solaris SMF are running if they exist
#
#   Arguments  : Check for following arguments:
#					-d = debug
#					-n = testcase name
#					-s = directory paths in a colon-separated list
#


# Init --------------------------------------------

# Get the name of our product from the framework
echo "[INPUT:PRODUCT]"
PROD=syb

RETURN_STATUS=0

#inc library
if [ ${PROD} = "syb" ]; then
. /ericsson/syb/lib/syb_libsvc.sh
fi

while getopts "dn:s:" option
do
    case $option in
        d) DEBUG=1;;
		 n) TEST_CASE=$OPTARG;;
		 s) SERVICES=`echo $OPTARG | sed -e "s/:/ /g"`;;
	esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:$TEST_CASE]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that SMF services are running if they exist]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Do the test -------------------------------------

if [ ${PROD} = "syb" ]; then
        svc_online
        RESULT=$?
        if [ $RESULT -ne 0 ]; then
                RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Sybase SMF services cannot be enabled"
		echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
		exit 1
        fi
fi


for foo in $SERVICES; do
	# Count lines that includes $foo
	PROCS=`svcs -a 2>/dev/null | grep ${foo} | cut -d' ' -f1 | wc -l`
	# Count lines that includes $foo and are online
	ONLINE_PROCS=`svcs -a 2>/dev/null | grep ${foo} | cut -d' ' -f1 | grep online | wc -l`

	# Check if all of the services were online
	if [ ! $PROCS = $ONLINE_PROCS ]; then
		RETURN_STATUS_REASON="${RETURN_STATUS_REASON:=Services offline}:${foo}"
		RETURN_STATUS=1
	fi
done


grep INFO /ericsson/eric3pp/etc/logging.properties > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
RETURN_STATUS_REASON="${RETURN_STATUS_REASON}: Current RMI Logging level is not INFO!!!"
fi



# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
