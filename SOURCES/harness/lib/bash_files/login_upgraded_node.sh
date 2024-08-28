#!/bin/bash
set -xv
inputVar=$1
SinputVar=$2

EXPECT=`which expect`

peer_ip=$(cat /etc/hosts |grep -i "ftpmservice asn_1" | grep -v masterservice |awk '{print $1}')
if [ "$inputVar" == "On" ]
then
$EXPECT << EOF
spawn ssh root@${peer_ip}
#exp_internal 1
while 1 {
        expect {
                "Are you sure you want to continue connecting" {
                        send "yes\r"}
                "Password:" {
                        send "shroot\r"
                        break}

                }
        }
expect "#"
send -- "reboot\r"
exit 0
expect closed
EOF

sleep 100 

fi

cat /etc/hosts |grep -i "ftpmservice asn_1" | grep -v masterservice
if [ $? -eq 0 ]
then
	if [ "$inputVar" == "Off" ]
	then
		mc_list_count=$(smtool -l | grep fth |grep -v fth_controller |wc -l)
	elif [ "$inputVar" == "On" ]
	then
		mc_list_count=$(smtool -l | grep fth |grep offline |wc -l)

		if [ $mc_list_count -eq 0 ]
		then
			flag=1
			mc_list_count=$(smtool -l | grep fth |grep failed |wc -l)
		fi
	fi

	
	if [ $mc_list_count -gt 0 ]
	then

		if [ "$inputVar" == "Off" ]
		then
			mc_list=$(smtool -l | grep fth |grep -v fth_controller |awk '{print $1}')
		elif [ "$inputVar" == "On" ]
		then
			mc_list=$(smtool -l | grep fth |grep offline |awk '{print $1}')
			if [ $flag -eq 1 ]
			then
				mc_list=$(smtool -l | grep fth |grep failed |awk '{print $1}')
			fi
				
		fi
		
		for mcs in $mc_list
		do
			if [ "$inputVar" == "Off" ]
			then
				echo "Offlining the MC: $mcs"
				smtool -offline $mcs -reason=upgrade -reasontext=Offline_FTH
			elif [ "$inputVar" == "On" ]
			then
				echo "Onling the MC: $mcs"
				smtool -online $mcs
			fi
		done
			sleep 5
	else
		if [ "$inputVar" == "Off" ]
		then
			echo "none of the fth MC's are present except fth_controller"
		elif [ "$inputVar" == "On" ]
		then
			echo "none of the fth MC's are offline"
		fi
	fi

if [[ "$inputVar" == "Off"  && ("$SinputVar" == "RB"  || "$SinputVar" == "CO") ]]
then
$EXPECT << EOF
spawn scp /var/tmp/login_peer_server.sh root@${peer_ip}:/var/tmp
#exp_internal 1
while 1 {
        expect {
                "Are you sure you want to continue connecting" {
                        send "yes\r"}
                "Password:" {
                        send "shroot\r"}
                "Password:" {
                        send "shroot\r"
                        break}

                }
                break
        }
expect "#"
exit 0
expect closed
EOF
fi


if [[ "$inputVar" == "Off"  && ("$SinputVar" == "RB" || "$SinputVar" == "CO") ]]
then

$EXPECT << EOF
spawn ssh root@${peer_ip}
while 1 {
        expect {
                "Are you sure you want to continue connecting" {
                        send "yes\r"}
                "Password:" {
                        send "shroot\r"
                        break}
                }
        }
expect "#"
send -- "chmod a+x /var/tmp/login_peer_server.sh\r"
expect "#"
send -- "/var/tmp/login_peer_server.sh Off\r"
expect " #"
send "exit\r"
exit 0
expect closed
EOF
elif [[ "$inputVar" == "On"  && ("$SinputVar" == "RB"  || "$SinputVar" == "CO") ]]
then
$EXPECT << EOF
spawn ssh root@${peer_ip}
while 1 {
        expect {
                "Are you sure you want to continue connecting" {
                        send "yes\r"}
                "Password:" {
                        send "shroot\r"
                        break}
                }
        }
expect "#"
send -- "chmod a+x /var/tmp/login_peer_server.sh\r"
expect "#"
send -- "/var/tmp/login_peer_server.sh On\r"
expect " #"
send "exit\r"
exit 0
expect closed
EOF
fi

else
	echo "There is no Peer Server deployed"
fi
