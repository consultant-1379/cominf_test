#!/bin/bash
inputVar=$1
fth_process_running=$(ps -ef | grep fth |grep -w -v "grep fth" |wc -l)
if [ $fth_process_running -gt 0 ]
then
	if [ "$inputVar" == "Off" ] 
	then
		while [ $fth_process_running -ne 0 ]
		do
			fth_process_id=$(ps -ef | grep fth |grep -w -v "grep fth" |awk '{print $2}')
			kill $fth_process_id
			fth_process_running=`expr $fth_process_running - 1`
		done	
	elif [ "$inputVar" == "On" ]
	then
		echo `ps -ef | grep fth |grep -w -v "grep fth"`
	fi
else
	echo "No fth process is running"
fi
