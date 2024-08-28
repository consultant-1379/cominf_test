#!/usr/bin/expect
###########################
#Update /etc/hosts entries#
#Author: xsougha Date:<>  #
###########################

set timeout 10

set om_infra_primary [lindex $argv 0]
set om_infra_secondary [lindex $argv 1]
set oss_master1 [lindex $argv 2]
set oss_master2 [lindex $argv 3]

# On om_infra_primary
spawn ssh $om_infra_primary
send "echo '$oss_master1 ossmaster' >> /etc/hosts\r"
expect "#"

sleep 2

send "echo '$oss_master2 oss2' >> /etc/hosts\r"
expect "#"
send "exit\r"
expect eof

sleep 2

# On om_infra_Secondary
spawn ssh $om_infra_secondary
send "echo '$oss_master1 ossmaster' >> /etc/hosts\r"
expect "#"

sleep 2

send "echo '$oss_master2 oss2' >> /etc/hosts\r"
expect "#"
send "exit\r"
expect eof
