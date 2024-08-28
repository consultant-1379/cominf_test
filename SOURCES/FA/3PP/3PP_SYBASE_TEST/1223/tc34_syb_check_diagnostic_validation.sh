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
# A              First Version for OSSRC R5 Checks to see if there has been a JSAgent core dump during
#					    during upgrade
#--------------------------------------------------------------------------
#
#   Name       : tc34_check_diagnostic_report.sh
#


# Init --------------------------------------------
GREP="/bin/grep"
RETURN_STATUS=0
TEMPFILENAME=tempoutput.txt
BASH="/bin/bash"
DIAGSCRIPT="validate_diagnostics_test.bsh"
CD="/bin/cd"
DIRNAME="/bin/dirname"


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
echo [OUTPUT:TESTCASENAME:Syb_3PP_TC_34]
echo [OUTPUT:TESTCASEDESCRIPTION:Test to see if the diagnostics check succeeds.]
echo [OUTPUT:SCRIPTVERSION:PA1]
# -------------------------------------------------


# Do the test -------------------------------------
### Function: gather_diagnostics_output ###
#
#   Called within this script to gather select parts of the output from 
#   another script that checks sybase diagnostics.
#   
#   The function checks to see if the diagnostic script exists, executes it, checks
#   the exit code and then returns the output.  If the script is not found
#   or the script fails to execute, this script will output the failure reason
#   and exit with the exit code 7.
#
# Arguments:
#       none
# Return Values:
#       The output (if any) from the execution of the mentioned script
#
gather_diagnostics_output()
{
	if [ -e $DIAGSCRIPT ] ; then
                $BASH $DIAGSCRIPT > $TEMPFILENAME
                CODE=$?
                #echo $CODE
                if [ $CODE -ne 0 ] ; then
                        RETURN_STATUS=1
                        RETURN_STATUS_REASON="Diagnostics script failed execution"
                        echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
                        exit $RETURN_STATUS
                fi
                SCR_OUTPUT=`$GREP "NOK" $TEMPFILENAME`
        else
                RETURN_STATUS=1
                CURLOCATION=`pwd`
                RETURN_STATUS_REASON="Diagnostics script not found , location: $CURLOCATION"
                echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
                exit $RETURN_STATUS
        fi
}

cd `$DIRNAME $0`
# Main code
gather_diagnostics_output
if [ -z $SCR_OUTPUT ] ; then
	RETURN_STATUS=0
	exit $RETURN_STATUS
else
	RETURN_STATUS=1
	RETURN_STATUS_REASON=$SCR_OUTPUT
	echo [OUTPUT:REASON:$RETURN_STATUS_REASON]
	exit $RETURN_STATUS
fi
# ------------------------------------------------- 
