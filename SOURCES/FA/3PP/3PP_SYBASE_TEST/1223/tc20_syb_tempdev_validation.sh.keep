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
# PA1		090609		EJOSODO			First Version	
#--------------------------------------------------------------------------
#
#   Name       : tc20_syb_tempdev_validation.sh 
#
#   Description: Checks that the tempdev devices exist and have the correct size. 
#
#   Arguments  : Check for following arguments:
#                -d = debug
#                -f = files
#                -s = sizes
#                -n = testcase name
#


# Init --------------------------------------------

RETURN_STATUS=0

# Read input options
while getopts "df:s:n:" option
do
    case $option in
        d) DEBUG=1;;
        f) FILES=$OPTARG;;
        s) SIZES=$OPTARG;;
        n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Checks that the tempdev devices exist and have the correct size.]"
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
TSS=/opt/ericsson/bin/pwAdmin
WC=/usr/bin/wc


# ********************************************************************
#
#       Pre-execution Operations
#
# ********************************************************************
#inc lib
. /ericsson/syb/lib/syb_libsec.sh


# ********************************************************************
#
#       Configuration Section
#
# ********************************************************************

# Amount of time in seconds between checking that Sybase is up
SYB_SLEEP_INT=15
# Number of times to try and test that sybase is up
SYB_UP_NUM_TRIES=40

# FMRI for sybase master
SYBASE_MASTER_FMRI="svc:/ericsson/eric_3pp/sybase_master_server"

# FMRI for sybase backup
SYBASE_BACKUP_FMRI="svc:/ericsson/eric_3pp/sybase_backup_server"

TSS=/opt/ericsson/bin/pwAdmin
SYBASE=/opt/sybase/sybase
SAP=$SYBASE/admin/etc/.sap

#inc library
. /ericsson/syb/lib/syb_libsec.sh



# ********************************************************************
#
#       Pre-execution Operations
#
# ********************************************************************



# ********************************************************************
#
#       functions
#
# ********************************************************************
### Function: abort_script ###
#
#   This will is called if the script is aborted thru an error
#   error signal sent by the kernel such as CTRL-C or if a serious
#   error is encountered during runtime
#
# Arguments:
#       $1 - Error message from part of program (Not always used)
# Return Values:
#       none
abort_script()
{
if [ "$NO_KILL_POINT" ]; then
    $ECHO "\nKilling this script can leave Sybase in a bad and"
    $ECHO "unstable state. It is much better to let if finish properly."
    $ECHO "Ignoring interrupt................"
    return
fi

_err_msg_=$1

if [ ! "$_err_msg_" ]; then
        _err_msg_="Script aborted.......\n"
fi

$ECHO "\n$_err_msg_\n"

cd $SCRIPTHOME

$RM -rf $TEM_LOG_DIR

exit 1
}

### Function: check_id_root ###
#
#   Check that the effective id of the user is 0
#   i.e. root. If not root, print error msg and exit.
#
# Arguments:
#       none
# Return Values:
#       none
check_id_root() 
{
_effect_id_=`$ID | $SED 's/uid=\([0-9]*\)(.*/\1/'`
if [ "$_effect_id_" != "0" ]; then
    _err_msg_="You must be root to execute this script."
    abort_script "$_err_msg_"
fi
}

### Function: get_absolute_path ###
#
# Determine absolute path to software
#
# Arguments:
#       none
# Return Values:
#       none
get_absolute_path()
{
cd `$DIRNAME $0`
_b_=`$BASENAME $0`
if [ ! -f ./$_b_ ]; then
    _err_msg_="Script can only be executed from directory
    where it resides. eg. ./`$BASENAME $0`\n"
    abort_script "$_err_msg_"
fi
SCRIPTHOME="$PWD"
}


### Function: setup_syb_env ###
#
# Setup Sybase Variables
#
# Arguments:
#       none
# Return Values:
#       none
setup_syb_env()
{
$SU - sybase >> /dev/null 2>&1 -c "$ENV |$EGREP '^(SYBASE|DSQUERY)' > /tmp/sybase_det.$$"

# Source the environment
set -a
. /tmp/sybase_det.$$
set +a

[ ! "$SYBASE" ] && SYBASE="/opt/sybase/sybase"
[ ! "$SYBASE_ASE" ] && SYBASE_ASE="ASE-15_0"
[ ! "$SYBASE_OCS" ] && SYBASE_OCS="OCS-15_0"

if [ ! "$DSQUERY" ]; then
    SQL_SERVER=`$HEAD -n 2 $SYBASE/interfaces | $TAIL -1`
else
    SQL_SERVER=$DSQUERY
fi   
$RM -f /tmp/sybase_det.$$

SQL_BACK_SERVER=${SQL_SERVER}_BACKUP

SA_USER="sa"

if [ ! "$DSQUERY" ]; then
    SQL_SERVER=`$HEAD -n 2 $SYBASE/interfaces | $TAIL -1`
else
    SQL_SERVER=$DSQUERY
fi

#Check SA pwd if tss is available

if [ -x ${TSS} ]; then
    SA_PASS=`${TSS} -get $SQL_SERVER SQL $SA_USER 2>/dev/null`
    if [ ! "${SA_PASS}" ]; then
        if [ -s ${SYBASE}/admin/etc/.sybpw ]; then
            SA_PASS=`$CAT $SYBASE/admin/etc/.sybpw`
        fi
    fi
fi

if [ -s $SAP -a -z "${SA_PASS}" ]; then
    sys_dcsap
    SA_PASS=`cat $SAP`
    sys_ecsap
fi

if [ ! "${SA_PASS}" ]; then
    $ECHO "TSS is Unavailable & the Temporary Password file does not exist"
    exit 1
fi

}


### Function: test_sybase_login ###
#
# Test that I can log into sybase 
#
# Arguments:
#       none
# Return Values:
#       none
test_sybase_login()
{
$ISQL -U$SA_USER  -S$SQL_SERVER << EOISQL >> /dev/null 2>&1
$SA_PASS
quit
go
EOISQL
# Do not put a space after EOISQL
return $?
}

# ********************************************************************
#
#       Main body of program
#
# ********************************************************************

# Trap all possible interrupts and remove temp files
# before exiting
trap "abort_script" 1 2 3 14 15

# Determine absolute path to software
get_absolute_path

# Check that the id of the user is root
check_id_root

# Setup Sybase Variables
setup_syb_env

# Setup SYBASE commands
ISQL="$SYBASE/$SYBASE_OCS/bin/isql"
STARTSERVER="$SYBASE/$SYBASE_ASE/install/startserver"
if [ ! -x "$ISQL" -o ! -x "$STARTSERVER" ]; then
    _err_msg_="$ISQL command not found."
    abort_script "$_err_msg_"
fi

# Test that I can log into sybase.
test_sybase_login 
 
# ********************************************************************
TSS=/opt/ericsson/bin/pwAdmin

SA_PASS=""
SA_USER="sa"

if [ ! "$DSQUERY" ]; then
    SQL_SERVER=`$HEAD -n 2 $SYBASE/interfaces | $TAIL -1`
else
    SQL_SERVER=$DSQUERY
fi

#Check SA pwd if tss is available 

if [ -x ${TSS} ]; then
    SA_PASS=`${TSS} -get $SQL_SERVER SQL $SA_USER 2>/dev/null`
    if [ ! "${SA_PASS}" ]; then
        if [ -s ${SYBASE}/admin/etc/.sybpw ]; then
            SA_PASS=`$CAT $SYBASE/admin/etc/.sybpw`
        fi
    fi
else
    if [ -s ${SYBASE}/admin/etc/.sybpw ]; then
        SA_PASS=`$CAT $SYBASE/admin/etc/.sybpw`
    fi
fi
if [ ! "${SA_PASS}" ]; then
    $ECHO "TSS is Unavailable & the Temporary Password file does not exist"
    exit 1
fi

# ********************************************************************
#
#       Configuration Section
#
# ********************************************************************

i=0

for foo in ${SIZES} ; do
	sizes[i]=$foo
	(( i += 1 ))
done

i=0

for foo in ${FILES} ; do
	if [ ! -f $foo ]; then
		RETURN_STATUS=1
		RETURN_STATUS_REASON=${RETURN_STATUS_REASON}"Missing file: $foo "
	else
		SIZE=`du -h $foo | awk -FM '{print $1}'`
		if [ $SIZE -ne ${sizes[i]} ]; then
			RETURN_STATUS=1
			RETURN_STATUS_REASON=${RETURN_STATUS_REASON}"$foo is of size $SIZE but was expected to be of size ${sizes[i]}."	
		fi 
	fi
	(( i += 1 ))
done

# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
