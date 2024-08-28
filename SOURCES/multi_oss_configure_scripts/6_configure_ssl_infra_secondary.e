#!/usr/bin/expect
#########################################
#SSL configuration on om_infra_secondary#
#########################################

set timeout 10

set send_slow {2 .5}

set om_infra_secondary [lindex $argv 0]

# On om_infra_secondary
spawn ssh $om_infra_secondary

# Verifying whether ssl.crt and rootca.cer are copied to omsrvm
send "bash /root/multi_oss_configure_scripts/check_ssl_and_root_certificates_infra_sec.sh $om_infra_secondary;echo $?\r"
expect {
	-re "0" {
	# Add a new CA root server certificate
	send -s "/ericsson/sdee/bin/prepSSL.sh\r"
	expect "LDAP Directory Manager password:"
	send -s "ldappass\r"
	expect "Choose an operation :"
	send -s "3\r"
	expect "Enter the location to the root ca certificate file:"
	send -s "/var/tmp/rootca.cer\r"
	expect "Enter the title of the Root CA Certificate:"
	send -s "cacert\r"
	sleep 5
	expect "Do you want to return to the main menu?"
	send -s "n\r"
	expect "#"

	sleep 2

	# Add a new SUNDS certificate
	send -s "/ericsson/sdee/bin/prepSSL.sh\r"
	expect "LDAP Directory Manager password:"
	send -s "ldappass\r"
	expect "Choose an operation :"
	send -s "2\r"
	expect "Enter the location of the Server generated file certificate:"
	send -s "/var/tmp/ssl.crt\r"
	expect "Enter certificate title:"
	send -s "servercert\r"
	sleep 5
	expect "Do you want to return to the main menu?"
	send -s "n\r"
	expect "#"

	# Changing the current SUN-DS SSL Assignment
	send -s "/ericsson/sdee/bin/prepSSL.sh\r"
	expect "LDAP Directory Manager password:"
	send -s "ldappass\r"
	expect "Choose an operation :"
	send -s "7\r"
	expect "Enter the alias of SUN-DS Certificate:"
	send -s "servercert\r"
	sleep 5
	expect "Do you want to return to the main menu?"
	send -s "n\r"
	expect "#"


	# List existing server certificate enabled with SUN-DS, existing root certificate enabled with SUN-DS, and current SSL Assign
	send -s "/ericsson/sdee/bin/prepSSL.sh\r"
	expect "LDAP Directory Manager password:"
	send -s "ldappass\r"
	expect "Choose an operation :"
	send -s "8\r"
	expect "Do you want to return to the main menu?"
	send -s "y\r"
	expect "Choose an operation :"
	send -s "9\r"
	expect "Do you want to return to the main menu?"
	send -s "y\r"
	expect "Choose an operation :"
	send -s "6\r"
	expect "Do you want to return to the main menu?"
	send -s "n\r"
	expect "#"
	}
	-re "1" {
		puts "rootca.cer and ssl.crt have not been copied to om_infra_secondary"
		send "exit\r"
		expect eof
	}
}
send "exit\r"
expect eof
