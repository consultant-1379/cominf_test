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
# Rev	Date		Prepared		Description
#
# PA1	071003		XRSOLFR			Verifies an environment file
#--------------------------------------------------------------------------
#
#   Name       : check_env_file.sh
#
#   Description: Checks that the file exist and that it sets the variable to the correct value.
#
#   Arguments  : Check for following arguments:
#					-d = debug
#					-f = environment file
#					-v = name of the variable to check
#					-w = the value to compare against
#					-n = testcase name
#


# Init --------------------------------------------
RETURN_STATUS=0

while getopts "df:n:v:w:" option
do
    case $option in
		d) DEBUG=1;;
		f) FILE=${OPTARG};;
		n) TEST_CASE=${OPTARG};;
		v) VARIABLE=${OPTARG};;
		w) VALUE=${OPTARG};;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that the files set the correct environment values.]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Checks that a file exists ------------------
check_file ()
{
	if [ ! -f "${1}" ]; then
		RETURN_STATUS=1 #Failed, file does not exist
		RETURN_STATUS_REASON="Missing file: ${1}"
		return 1
	fi	
	return 0
}



# Do the test -------------------------------------


check_file ${FILE}

if [[ $? -ne 1 ]]; then
	set -a
	. "${FILE}"
	CVALUE=$(eval echo \$${VARIABLE})
	if [[ $VALUE !=  $CVALUE ]]; then
		echo "Comparison for $VARIABLE failed!"
		echo "Got $CVALUE Expected: $VALUE"
		RETURN_STATUS=1 #Failed, value mismatch
		RETURN_STATUS_REASON="$VARIABLE does not have the correct value."
	fi
fi


# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
