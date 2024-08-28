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
# A              First Version for OSSRC R5
#--------------------------------------------------------------------------
#
#   Name       : Syb_3PP_TC_07
#
#   Description: Test to see if the CLASSPATH has been defined
#
#   Arguments  : Check for following arguments:
#                -d = debug
#


# Init --------------------------------------------
RETURN_STATUS=0

while getopts ":d" option
do
    case $option in
        d) DEBUG=1;;
   esac
done

if [ $DEBUG ]; then
    set -x
fi
# -------------------------------------------------


# Mandatory information ---------------------------
echo [OUTPUT:TESTCASENAME:Syb_3PP_TC_07]
echo [OUTPUT:TESTCASEDESCRIPTION:Test to see if the CLASSPATH has been defined]
echo [OUTPUT:SCRIPTVERSION:PA1]
# -------------------------------------------------


# Do the test -------------------------------------
#
#
cpath="/opt/sybase/sybase/jConnect-6_0/classes:/opt/sybase/sybase/jConnect-6_0/classes/jconn3.jar"
set -a
. /etc/opt/ericsson/3ppenv/sybase.env
RES=`echo ${CLASSPATH} | grep ${cpath}`

if [ ! -z "${RES}" ] ; then
	RETURN_STATUS=0
else 
	RETURN_STATUS=1
	RETURN_STATUS_REASON="The CLASSPATH hasn't been defined for Sybase!"
fi
# -------------------------------------------------



# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
