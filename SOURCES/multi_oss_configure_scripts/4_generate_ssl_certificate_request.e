#!/usr/bin/expect
#############################################################################
#Generate SSL certificate request on om_infra_primary and om_onfra_secondary#
#############################################################################

set timeout 10
set send_slow {2 .5}

set om_infra_primary [lindex $argv 0]
set om_infra_secondary [lindex $argv 1]

# On om_infra_primary
spawn ssh $om_infra_primary
# Generating SSL certificate request
send -s "/ericsson/sdee/bin/prepSSL.sh\r"
expect "LDAP Directory Manager password:"
send -s "ldappass\r"
expect "Choose an operation :"
send -s "1\r"
expect "Enter organization value"
send -s "company\r"
expect "Enter City value"
send -s "city\r"
expect "Enter State value"
send -s "state\r"
expect "Enter Country value"
send -s "ie\r"
expect "Are these values correct?"
send -s "Yes\r"
expect "Do you want to return to the main menu?"
send -s "n\r"
expect "#"
send -s "exit\r"
expect eof

sleep 2

# On om_infra_secondary
spawn ssh $om_infra_secondary
# Generating SSL certificate request
send -s "/ericsson/sdee/bin/prepSSL.sh\r"
expect "LDAP Directory Manager password:"
send -s "ldappass\r"
expect "Choose an operation :"
send -s "1\r"
expect "Enter organization value"
send -s "company\r"
expect "Enter City value"
send -s "city\r"
expect "Enter State value"
send -s "state\r"
expect "Enter Country value"
send -s "ie\r"
expect "Are these values correct?"
send -s "Yes\r"
expect "Do you want to return to the main menu?"
send -s "n\r"
expect "#"
send -s "exit\r"
expect eof
