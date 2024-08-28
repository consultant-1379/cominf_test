#!/bin/bash
set -x
EXPECT="/usr/local/bin/expect"
pkginfo -l JASScustm
if [ $? -eq 0 ]
then
	echo "JASScustm pkg installed,,, so removing the pkg"

$EXPECT << EOF
spawn pkgrm JASScustm
set timeout 60
expect "Do you want to remove this package"
send "y\r"
expect "Do you want to continue with the removal of this package"
send "y\r"
sleep 10
expect "#"
send "exit\r"
exit 0
expect closed
EOF
	pkginfo -l JASScustm
	if [ $? -eq 1 ]
	then
		echo "Sucessfully removed JASScustm pkg"
	fi

	if [ -f /var/tmp/JASScustm.pkg ]
	then
		echo "Found package"
		echo "Started pkg installation"

$EXPECT << EOF
spawn pkgadd -d /var/tmp/JASScustm.pkg
set timeout 60
#expect "all packages). (default: all) [\?,\?\?,q]:"
expect "all packages*"
send "all\r"
expect "Do you want to continue with the installation of <JASScustm>"
send "y\r"
expect "successful"
send "exit\r"
exit 0
expect closed
EOF
		
		pkginfo -l JASScustm
		if [ $? -eq 0 ]
		then
			echo "Sucessfully installed JASScustm.pkg"
		else
			echo "JASScustm.pkg was not installed,,,, please chk manually"
			exit 1
		fi
	fi
else
	echo "Security patch is not installed"
	if [ -f /var/tmp/JASScustm.pkg ]
	then
		echo "Found package"
		echo "Started pkg installation"

$EXPECT << EOF
spawn pkgadd -d /var/tmp/JASScustm.pkg
set timeout 60
#expect "all packages). (default: all) \\\\\\[\\\\\\?,\\\\\\?\\\\\\?,q\\\\\\]:"
expect "all packages*"
send "all\r"
expect "Do you want to continue with the installation of <JASScustm>"
send "y\r"
expect "successful"
send "exit\r"
exit 0
expect closed
EOF
		pkginfo -l JASScustm
		if [ $? -eq 0 ]
		then
			echo "Sucessfully installed JASScustm.pkg"
		else
			echo "JASScustm.pkg was not installed,,,, please chk manually"
			exit 1
		fi
	fi
fi
