#!/usr/bin/expect
######################################
#Script to configure SSH for comnfadm#
#Author: xsougha Date: <>	     #
######################################

set timeout 10

set om_infra_primary [lindex $argv 0]
set om_infra_secondary [lindex $argv 1]
set oss_master [lindex $argv 2]

# On ossmaster
# Creating ssh directory under comnfadm user on ossmaster if not present
spawn ssh $oss_master
expect "Password:"
send "shroot\r"
expect "#"
send "su - comnfadm\r"
sleep 10 
expect "#"
send "mkdir -p /home/comnfadm/.ssh\r"
expect "#"
send "exit\r"
expect eof

sleep 2

# On om_infra_primary
spawn ssh $om_infra_primary
# Configuring SSH for comnfadm user for om_infra_primary
send "scp //.ssh/id_dsa.pub $oss_master:/home/comnfadm/.ssh/COMINFServer_prim.pub\r"
expect "#"
send "exit\r"
expect eof

sleep 2

# On om_infra_secondary
spawn ssh $om_infra_secondary
# Configuring SSH for comnfadm user for omsrvs
send "scp //.ssh/id_dsa.pub $oss_master:/home/comnfadm/.ssh/COMINFServer_sec.pub\r"
expect "#"
send "exit\r"
expect eof

sleep 2

# On oss_master
spawn ssh $oss_master
expect "Password:"
send "shroot\r"
expect "#"
send "cat /home/comnfadm/.ssh/COMINFServer_prim.pub >> /home/comnfadm/.ssh/authorized_keys2\r"
expect "#"
send "cat /home/comnfadm/.ssh/COMINFServer_sec.pub >> /home/comnfadm/.ssh/authorized_keys2\r"
expect "#"
send "exit\r"
expect eof
 
# Testing whether SSH for comnfadmuser is corectly configured or not
# On om_infra_primary
spawn ssh $om_infra_primary
send "ssh -l comnfadm $oss_master\r"
expect "#"
send "exit\r"
expect eof

# On om_infra_secondary
spawn ssh $om_infra_secondary
send "ssh -l comnfadm $oss_master\r"
expect "#"
send "exit\r"
expect eof
