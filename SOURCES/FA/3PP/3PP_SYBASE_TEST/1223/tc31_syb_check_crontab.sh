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
# Rev     Date      Prepared        Description
#
# PA1     110718    EWENHUG         Check the crontab jobs
#--------------------------------------------------------------------------
#
#   Name       : check_permission.sh
#
#   Description: Generic check file/directory access permission testscript
#
#   Arguments  : Check for following arguments:
#					-d = debug
#					-f = x86 server cron job check list
#					-s = sparc server cron job check list
#					-n = testcase name
#


# Init --------------------------------------------
RETURN_STATUS=0

# Read input options
while getopts "df:s:n:" option
do
    case $option in
		d) DEBUG=1;;
		f) X86CHECKLIST=$OPTARG;;
		s) SPARCCHECKLIST=$OPTARG;;
		n) TEST_CASE=$OPTARG;;			 
   esac
done


if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Check the crontab jobs]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------


#---------do the test------------------------------

#---Function check sparc---

echo "sparc:$SPARCCHECKLIST"
echo "x86:$X86CHECKLIST"

check_sparc_server ()
{ 
	for item in $SPARCCHECKLIST
	do
	    echo "Check $item"
		CRONTAB=`crontab -l`
		itemcount=`echo "$CRONTAB" | grep -i "$item" | wc -l`
		if [ $itemcount -eq 0 ]; then
			echo "Failed to find cron job $item"
			RETURN_STATUS=1
			RETURN_STATUS_REASON="Failed to find cron job with $item"
			echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
			exit 1
		fi
	
	done
crontabc=`crontab -l`
item1=`echo "$crontabc"| grep -i "/ericsson/syb/conf/diag_proc_cache_test.ksh"`
check1="30 05 * * *  su - sybase -c \"/ericsson/syb/conf/diag_proc_cache_test.ksh >> /var/tmp/diag_proc_cache_test.txt\""
if [ "$item1"="$check1" ]; then
        echo "Yes1"
else
        echo "No1"
	RETURN_STATUS=1
       RETURN_STATUS_REASON="Not found expected cron job:$check1 "
       echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
         exit 1
fi

item=`echo "$crontabc" | grep -i "/ericsson/syb/backup/backup_sybase_db.sh" `
check2="0 03 * * 0 /ericsson/syb/backup/backup_sybase_db.sh"
if [ "$item"="check2"  ]; then
        echo "Yes2"
else
        echo "No2"
	RETURN_STATUS=1
       RETURN_STATUS_REASON="Not found expected cron job:$check2 "
       echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
         exit 1
fi
}

check_x86_server ()
{
	for item in $X86CHECKLIST
	do
	    echo "Check $item"
		CRONTAB=`crontab -l`
		itemcount=`echo "$CRONTAB" | grep -i "$item" | wc -l`
		if [ $itemcount -eq 0 ]; then
			echo "Failed to find cron job $item"
			RETURN_STATUS=1
			RETURN_STATUS_REASON="Failed to find cron job with $item"
			echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
			exit 1
		fi
	
	done	
	
	crontabc=`crontab -l`
	item1=`echo "$crontabc"| grep -i "/ericsson/syb/conf/diag_proc_cache_test.ksh"`
	check1="30 05 * * *  ssh \`/opt/VRTSvcs/bin/hagrp -state -localclus Sybase1|nawk '/ONLINE/{print $3}'\` 'su - sybase -c \"/ericsson/syb/conf/diag_proc_cache_test.ksh >> /var/tmp/diag_proc_cache_test.txt\"'"
	if [ "$item1"="$check1" ]; then
  	      echo "/ericsson/syb/conf/diag_proc_cache_test.ksh crontab syntax passed"
	else

                        RETURN_STATUS=1
			RETURN_STATUS_REASON="/ericsson/syb/conf/diag_proc_cache_test.ksh job does not match with $check1"
                        RETURN_STATUS_REASON="cron job diag_proc_cache_test.ksh does not match with expected one"
                        echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
                        exit 1
	fi	

	item2=`echo "$crontabc"| grep -i "/ericsson/syb/backup/syb_dbdump"`
	check2="ssh \`/opt/VRTSvcs/bin/hagrp -state -localclus Sybase1|nawk '/ONLINE/{print $3}'\` '/ericsson/syb/backup/syb_dbdump -B -D all -e -Z -S 30 -s 2 db masterdataservice'"
	if [ "$item2"="$check2" ]; then
       		 echo "Yes2"
	else
		RETURN_STATUS=1
                        RETURN_STATUS_REASON="/ericsson/syb/backup/syb_dbdump job does not match with $check2"
                        echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
                        exit 1
	fi
}

#Identify the server type(sparc / i386)
ServerInfo="`uname -a`"
echo "$ServerInfo"

Type=`echo "$ServerInfo" | grep -i "sparc" | wc -l`

if [ $Type -gt 0 ]; then
	echo "Server type is sparc"
	check_sparc_server
else
	echo "Server type is x86"
	check_x86_server
fi



# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
