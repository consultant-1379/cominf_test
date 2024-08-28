#!/bin/bash
G_SCRIPTDIR=$(cd $(/usr/bin/dirname $0); pwd)
G_SSH_SETUPSCRIPT=$G_SCRIPTDIR/ssh_setup.sh
G_SCRIPTNAME=$(/bin/basename $0)
. $G_SCRIPTDIR/ci_liveupgrade.env
l_server=`grep config /ericsson/config/ericsson_use_config | awk -F'=' '{print $2}'`

cd ${SMALL_UPGRADE_PATH}/Solaris_10/i386/ocs/bin/

if [ $l_server == "appserv" ]; then
	${SMALL_UPGRADE_PATH}/Solaris_10/i386/ocs/bin/cominf_small_upgrade.sh -p ${SMALL_UPGRADE_PATH} -y  || exit 1
else
	/usr/local/bin/expect $G_SCRIPTDIR/ci_upgrade.exp "./cominf_small_upgrade.sh -p ${SMALL_UPGRADE_PATH}" || exit 2
fi 

