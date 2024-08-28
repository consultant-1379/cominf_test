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
# PA1           110527		EWENHUG			Fix the problem when TSS failed, no fail reason	
#--------------------------------------------------------------------------
#
#   Name       : tc25_syb_file_presentation_validation.sh 
#
#   Description: Checks the existence of the sybase scripts/files 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#		         -f = file containing Sybase scripts/config files
#                -n = testcase name
#


# Init --------------------------------------------

RETURN_STATUS=0

# Read input options
while getopts "df:n:" option
do
    case $option in
        d) DEBUG=1;;
		f) FILE=$OPTARG;;
        n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks for the existence of sybase files and scripts]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------

# ********************************************************************
#
#       Command Section
#
# ********************************************************************
AWK=/usr/bin/awk
BASENAME=/usr/bin/basename
CAT=/usr/bin/cat
CHMOD=/usr/bin/chmod
CLEAR=/usr/bin/clear
CP=/usr/bin/cp
DATE=/usr/bin/date
DIRNAME=/usr/bin/dirname
ECHO=/usr/bin/echo
EGREP=/usr/bin/egrep
ENV=/usr/bin/env
EXPR=/usr/bin/expr
GREP=/usr/bin/grep
HEAD=/usr/bin/head
HIDDENFILE=/opt/sybase/sybase/admin/etc/.sybpw
ID=/usr/bin/id
LS=/usr/bin/ls
MKDIR=/usr/bin/mkdir
MORE=/usr/bin/more
MV=/usr/bin/mv
NAWK=/usr/bin/nawk
PWD=/usr/bin/pwd
RM=/usr/bin/rm
SED=/usr/bin/sed
SLEEP=/usr/bin/sleep
SORT=/usr/bin/sort
SU=/usr/bin/su
TAIL=/usr/bin/tail
TAR=/usr/bin/tar
TOUCH=/usr/bin/touch
TSS=/opt/ericsson/bin/pwAdminNR
WC=/usr/bin/wc



# Do the test -------------------------------------
#
#
if [ ! -f $FILE ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="${RETURN_STATUS_REASON}File $FILE does not exist!"
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	
	exit 1
else
	
	echo "Start to check the existence of sybase scripts/config files."
	cat $FILE | while read LINE
    do		
		# the LINE could be a path of a directory, not a path, so check again
		if [ ! -f $LINE ]; then
			if [ ! -d $LINE ]; then
				RETURN_STATUS=1
				RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Missing file/directory: $LINE.  "
				echo "Missing $LINE "
			else
				echo "Directory: $LINE exits"
			fi
		else
			echo "File: $LINE exits"
		fi   
	done
fi

echo "Finish checking the existence of sybase scripts/config files."

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
	
