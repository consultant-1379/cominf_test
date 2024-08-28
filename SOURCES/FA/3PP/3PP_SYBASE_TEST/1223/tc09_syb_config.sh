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
#   Name       : Syb_3PP_TC_09
#
#   Description: Test for the SYBASE configuration file
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
echo [OUTPUT:TESTCASENAME:Syb_3PP_TC_09]
echo [OUTPUT:TESTCASEDESCRIPTION:Test for the Sybase configuration file]
echo [OUTPUT:SCRIPTVERSION:PA1]
# -------------------------------------------------


# Do the test -------------------------------------
#

if [ -f /opt/sybase/sybase/ASE-15_0/masterdataservice.cfg ]; then
	RETURN_STATUS=0
else 
	RETURN_STATUS=1
	RETURN_STATUS_REASON="Sybase configuration file missing!"
fi
# -------------------------------------------------



# Return status and reason ------------------------
if [ "$RETURN_STATUS_REASON" ]; then
  echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
fi

exit $RETURN_STATUS
# -------------------------------------------------
