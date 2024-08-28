#!/bin/bash
latest_dir=$(ls -lrt /var/opt/SUNWjass/run/ | tail -1 |awk '{print $9}')
errors=$(cat /var/opt/SUNWjass/run/$latest_dir/jass-audit-log.txt | grep FAIL | grep -v "permissions" | grep -v "UID/GID")
echo "Find the below Node Hardening Errors from $1"
echo "$errors"
