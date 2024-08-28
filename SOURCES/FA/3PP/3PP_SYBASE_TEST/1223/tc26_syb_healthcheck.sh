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
# Rev       Date        Prepared            Description
#
# PA1       110601      EWENHUG             Use the healthcheck tool to check the sybase
#--------------------------------------------------------------------------
#
#   Name       : tc26_syb_healthcheck.sh
#
#   Description: Automate the heathcheck tool for sybase
#
#   Arguments  : Check for following arguments:
#					-d = debuunam
#					-o = number of check items
#					-n = testcase name
#

# Init --------------------------------------------
RETURN_STATUS=0

while getopts "do:n:" option
do
    case $option in
		d) DEBUG=1;;
		o) ITEMSCOUNT=$OPTARG;;
		n) TEST_CASE=$OPTARG;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------

# Mandatory information ---------------------------
echo "[OUTPUT:TESTCASENAME:${TEST_CASE}]"
echo "[OUTPUT:TESTCASEDESCRIPTION:Sybase Heath Check]"
echo "[OUTPUT:SCRIPTVERSION:PA1]"
# -------------------------------------------------

# Do the test -------------------------------------

TOOL=/ericsson/syb/util/dba_tools

echo "Start the heathcheck"

if [ ! $ITEMSCOUNT ]; then
	RETURN_STATUS=7
	RETURN_STATUS_REASON="The number of health check items argument is not available, please check the config file."
	exit RETURN_STATUS
fi

if [ ! -f $TOOL ]; then
	RETURN_STATUS=7
	RETURN_STATUS_REASON="${RETURN_STATUS_REASON} The sybase health check tool is not availble."
	exit RETURN_STATUS
else
	echo "Sybase Healthcheck tool exist, start to check the sybase"
fi

#sybase tool need the <<sybase>> user to excute
echo "=================RESULT==================="
RESULT=$(expect - <<EOF
set timeout 240
spawn su - sybase -c \"/ericsson/syb/util/dba_tools\" 
expect "Enter your choice:"  
send "13\r" 
expect {
	"Press <Return> to continue:" { 
		send \"\r\" 
	}
	"/tmp/healthcheck_output: cannot create" { 
		send \003
	}
	timeout {
		send \003
	}
}
expect "Enter your choice:"
send \"0\r\"
EOF)

#First check whether we get all results(OK! or Not OK!) from the check items
RESCOUNT=`echo "$RESULT" | grep -i "\.\.\.\.\.\.\.\.\." | wc -l`

if [ $RESCOUNT -lt $ITEMSCOUNT ]; then
	RETURN_STATUS=1
	RETURN_STATUS_REASON="The health check cannot finish the checking"
	echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
	exit 1
fi

#Not OK! Count
NOTOK=`echo "$RESULT" | grep -wi "OK" | grep "Not OK" | wc -l`
echo "============$NOTOK Not OK have been found ================"

#GET the NOTOK check items
if [ $NOTOK -gt 0 ]; then
	LISTS=`echo "$RESULT" | grep -i "\.\.\.\.\.\.\.\.\." | grep -v "\.\.\.OK"`
	NUMBER_OF_LINES=`echo "$LISTS" | wc -l`
	LINE_NUMBER=1
    while [ $LINE_NUMBER -le $NUMBER_OF_LINES ]
	do
		LINE=`echo "$LISTS" | awk NR==$LINE_NUMBER `
		ITEM=`echo "$LINE" | awk -F"." '{print $1}' | tr -d '\a'`
		FAILEDCHECIITEM="${FAILEDCHECIITEM}-$ITEM"
		(( LINE_NUMBER+=1 ))
	done
	
	RETURN_STATUS=1
	RETURN_STATUS_REASON="$FAILEDCHECIITEM failed"
else
	echo "ALL OK!"
fi
# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:"$RETURN_STATUS_REASON"]
fi

exit $RETURN_STATUS



	
	
