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
# Rev   Date    Prepared        Description
#
# PA1   070925  XRSOLFR         Checks if files and directories exist.
# PA2   091116  EQIIYAO         Modified to check multi files.
#--------------------------------------------------------------------------
#
#   Name       : check_filedir.sh
#
#   Description: Generic check file/directory testscript
#
#   Arguments  : Check for following arguments:
#					-d = debug
#					-p = directory paths in a colon-separated list
#					-f = file paths in a colon-separated list
#					-n = testcase name
#


# Init --------------------------------------------
RETURN_STATUS=0

while getopts "df:p:n:" option
do
    case $option in
		d) DEBUG=1;;
		f) FILE_PATHS=`echo $OPTARG | sed -e "s/:/ /g"`;; 
		p) DIR_PATHS=`echo $OPTARG | sed -e "s/:/ /g"`;;
		n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Tests if files and/or directories exists]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------



# Checks that a directory exists ------------------
check_directory ()
{
	if [ ! -d "${1}" ]; then
		RETURN_STATUS=1 #Failed, directory does not exist
		DIRECTORY_STATUS="${DIRECTORY_STATUS:=Missing directories}:${1}"
	fi	
}

# Checks that a file exists ------------------
check_file ()
{
	if [ ! -f "${1}" ]; then
		RETURN_STATUS=1 #Failed, file does not exist
		FILE_STATUS="${FILE_STATUS:=Missing files}:${1}"
	fi	
}



# Do the test -------------------------------------

# Check that the directories exist
for foo in $DIR_PATHS; do
	check_directory $foo
done

# Check that the files exist
for foo in $FILE_PATHS; do
	check_file $foo
done

if [[ $RETURN_STATUS -ne 0 ]]; then
	RETURN_STATUS_REASON="$DIRECTORY_STATUS $FILE_STATUS"
fi

       
# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
