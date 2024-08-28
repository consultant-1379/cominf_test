#!/usr/local/bin/expect
#---------------------------------------------------------------------
# Ericsson AB 2007
#---------------------------------------------------------------------
#
# ####################################################################
# # COPYRIGHT Ericsson AB 2007
# # 
# # The copyright to the computer program(s) herein is the property
# # of ERICSSON AB, Sweden. The programs may be used
# # and/or copied only with the written permission from ERICSSON
# # AB or in accordance with the terms and conditions
# # stipulated in the agreement/contract under which the program(s)
# # have been supplied.
# #                                         
# ####################################################################
#
#------ History ------------------------------------------------------
# Rev	Date	Prepared		Description
#
# R1A	20111006	enaggop		First version
#

set timeout 1800

proc timedout {} {
        send_error "The current command has timed out, exiting.\n"
        exit 1
}

spawn "/Liveupgrade/manage_be.bsh -A -b d70" 
set finished 0
while { $finished != 1 } {
expect {
       timeout timedout
                "Are you sure you wish to activate the Boot Environment d70Enter .Yes | No. *" {send "Yes\r"}
		eof	 {set finished 1}
		}
}

