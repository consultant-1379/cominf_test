#!/usr/bin/expect
###################################################################################################################
#Setting passwordless login				      					      		  #
#Script to be executed on a server/gateway which has access to om_infra_primary, om_infra_secondary and oss_master#
#Author: xsougha	Date<>				    					      		  #
###################################################################################################################

set timeout 10

set om_infra_primary [lindex $argv 0]
set om_infra_secondary [lindex $argv 1]
set oss_master1 [lindex $argv 2]
set oss_master2 [lindex $argv 3]

# On om_infra_primary
spawn ssh $om_infra_primary
expect "#"
# Setting passwordless login from om_infra_primary to oss_master1
send "cat //.ssh/id_rsa.pub | ssh $oss_master1 'cat >> .ssh/authorized_keys' \r"
expect "Password:"
send "shroot\r"
expect "#"

sleep 2

# Setting passwordless login from om_infra_primary to oss_master2
send "cat //.ssh/id_rsa.pub | ssh $oss_master2 'cat >> .ssh/authorized_keys' \r"
expect "Password:"
send "shroot\r"
expect "#"
send "exit\r"
expect eof

sleep 2

# On om_infra_secondary
spawn ssh $om_infra_secondary
expect "#"
# Setting passwordless login from om_infra_secondary to oss_master1
send "cat //.ssh/id_rsa.pub | ssh $oss_master1 'cat >> .ssh/authorized_keys' \r"
expect "Password:"
send "shroot\r"
expect "#"

sleep 2

# Setting passwordless login from om_infra_secondary to oss_master2
send "cat //.ssh/id_rsa.pub | ssh $oss_master2 'cat >> .ssh/authorized_keys' \r"
expect "Password:"
send "shroot\r"
expect "#"
send "exit\r"
expect eof
