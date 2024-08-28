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
# Rev   Date    Prepared        	Description
#
# A     120928  First Version 		 Checks to see if there has been
#                                        a JSAgent core dump during
#					 upgrade
#--------------------------------------------------------------------------
#
#   Name       : tc33_syb_check_core_dump.sh 
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
echo [OUTPUT:TESTCASENAME:Syb_3PP_TC_33]
echo [OUTPUT:TESTCASEDESCRIPTION:Test to see if there are any JSAgent core dumps.]
echo [OUTPUT:SCRIPTVERSION:PA1]
# -------------------------------------------------


# Do the test -------------------------------------
JS_COREDUMP=`ls -al /ossrc/upgrade/core/*jsagent* | wc -l`

if [ -z $JS_COREDUMP ]; then
	RETURN_STATUS=0
else
	RETURN_STATUS=1
	RETURN_STATUS_REASON="JSAgent core dump file found"
fi
# ------------------------------------------------- 
