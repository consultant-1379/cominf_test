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
# PA1		090730		EJOSODO	                First Version	
#--------------------------------------------------------------------------
#
#   Name       : tc24_syb_file_validation.sh 
#
#   Description: Checks for the existence of files and their origin 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#		 -f = files
#                -n = testcase name
#


# Init --------------------------------------------

RETURN_STATUS=0

# Read input options
while getopts "df:n:" option
do
    case $option in
        d) DEBUG=1;;
	f) FILES=$OPTARG;;
        n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks for the existence of files and their origin]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Do the test -------------------------------------
#
#
for file in $FILES
do
	echo "Checking existence of $file..."
	if [ ! -f $file ]; then
		RETURN_STATUS=1
		RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Missing file: $file "
	else
		echo "Checking origin of $file..."
		ORIGIN=`pkgchk -l -p $file`
		if [ ! -z $ORIGIN ]; then
			RETURN_STATUS=1
			RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Record of package delivery of file $file "
		fi
	fi
done

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
