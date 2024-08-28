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
# PA2		090716		EJOSODO			Updated value of ISQL	
# PA3		091102		EQIIYAO			Updated value of CURR_PW
#--------------------------------------------------------------------------
#
#   Name       : tc15_syb_check_connection.sh 
#
#   Description: Checks that it is possible to connect to Sybase 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#                -u = sql user
#                -n = testcase name
#


# Init --------------------------------------------

#inc library
. /ericsson/syb/lib/syb_libsvc.sh
. /ericsson/syb/lib/syb_libsec.sh

RETURN_STATUS=0

# Read input options
while getopts "du:n:" option
do
    case $option in
        d) DEBUG=1;;
        u) SA_USER=${OPTARG};;
        n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that it is possible to connect to Sybase]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


# Do the test -------------------------------------
#
#

PWADMIN=pwAdmin 
ISQL=/opt/sybase/sybase/OCS-15_0/bin/isql
SYBASEMSG=/tmp/check_connection.$$

TSS=/opt/ericsson/bin/pwAdmin
SYBASE=/opt/sybase/sybase
SAP=$SYBASE/admin/etc/.sap

SQL_SERVER=`head -n 2 /opt/sybase/sybase/interfaces | tail -1`

#CURR_PW=`$PWADMIN -get $SQL_SERVER SQL $SA_USER 2>/dev/null`
#Check SA pwd if tss is available

if [ -x ${TSS} ]; then
    CURR_PW=`${TSS} -get $SQL_SERVER SQL $SA_USER 2>/dev/null`
    if [ ! "${CURR_PW}" ]; then
        if [ -s ${SYBASE}/admin/etc/.sybpw ]; then
            CURR_PW=`$CAT $SYBASE/admin/etc/.sybpw`
        fi
    fi
fi

if [ -s $SAP -a -z "${CURR_PW}" ]; then
    sys_dcsap
    CURR_PW=`cat $SAP`
    sys_ecsap
fi

if [ ! "${CURR_PW}" ]; then
    $ECHO "TSS is Unavailable & the Temporary Password file does not exist"
    exit 1
fi

# Do the test -------------------------------------
#
#
test_sybase_login()
{

$ISQL -w 5000 -U$SA_USER -P$CURR_PW -S$SQL_SERVER << EOISQL >>  $SYBASEMSG
EOISQL
# Do not put a space after EOISQL
 
# Check for any reported errors
egrep 'Msg [0-9][0-9]*\, Level ([0-9][0-9]*)' $SYBASEMSG >> /dev/null 2>&1
 
if [ $? -eq 0 ]; then
	RETURN_STATUS=1 # native version does not match
        RETURN_STATUS_REASON="${RETURN_STATUS_REASON}Not able to connect to Sybase for user $SA_USER."
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

test_sybase_login

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
