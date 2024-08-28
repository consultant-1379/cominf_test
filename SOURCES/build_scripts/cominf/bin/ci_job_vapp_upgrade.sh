#!/bin/bash
#------------------------------------------------------------------------
#
#       COPYRIGHT (C) ERICSSON RADIO SYSTEMS AB, Sweden
#
#       The copyright to the document(s) herein is the property of
#       Ericsson Radio Systems AB, Sweden.
#
#       The document(s) may be used and/or copied only with the written
#       permission from Ericsson Radio Systems AB or in accordance with
#       the terms and conditions stipulated in the agreement/contract
#       under which the document(s) have been supplied.
#
#------------------------------------------------------------------------
# History
# 17/05/2014    xgansre        First version

usage() {
cat << EOF

Usage:  ${G_SCRIPTNAME} -f <Test env file> [-b <job build number>] [-j <job name>] [-h] [-k] [-n]


-s smrs upgrade on system configured VAPP
-o ocs upgrade
-r R-state for ocs upgrade
-p Package for ocs upgrade
-d Delivery of ocs upgrade

This script is called by the Jenkins server. It performs the following actions:

-Copies software to servers defined in <Test env file>
-Installs software on servers defined in <Test env file>
-Kicks off test harness on OM Services Primary
-Copies test results from OM Services Primary to Jenkins server.


EOF

return 0

}

upgrade_smrs() {
	local l_ssh_nat_port=""
	local l_count=0
	IST_RUN=/opt/ericsson/sck/bin/ist_run	
	while [ $l_count -lt ${#CI_SERVER_IP[@]} ]; do
		[ "${CI_SERVER_CONFIG[$l_count]}" = system ] && {
			if [ -n "${CI_SERVER_SSH_NAT_PORT[$l_count]}" ]; then
				l_ssh_nat_port="-oPort=${CI_SERVER_SSH_NAT_PORT[$l_count]}"
			fi
		G_SMRS_PKGNAME=`grep swdi.latest.deployable.package $G_WORKSPACE/swdi/swdi.properties | awk '{print $3}'`
		$G_SSH_SETUPSCRIPT scp "$l_ssh_nat_port $G_WORKSPACE/swdi/pkg/$G_SMRS_PKGNAME root@${CI_SERVER_IP[$l_count]}:/var/tmp" ${CI_SERVER_ROOTPW[$l_count]} || {
			echo "ERROR: Failed to copy package to ossmater"
			return 1
		}
		echo "Installing the SMRS Package on ossmaster"
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port root@${CI_SERVER_IP[$l_count]} $IST_RUN -d /var/tmp/$G_SMRS_PKGNAME -auto -pa -force" ${CI_SERVER_ROOTPW[$l_count]} || {
			echo "ERROR: Failed to install the package"
			return 1
}
			echo "Running upgrade_smrs.sh on OSSRC_MASTER of ${CI_SERVER_IP[$l_count]}"
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port root@${CI_SERVER_IP[$l_count]} $G_REMOTE_SMRS_BIN_DIR/upgrade_smrs.sh -p shroot12 -i -r" ${CI_SERVER_ROOTPW[$l_count]} || {
				echo "ERROR: upgrade_smrs.sh script failed on server ${CI_SERVER_HOSTNAME[$l_count]}"
				return 1
			}
		}
		let l_count+=1
		
	done

	return $?
}

create_test_harness_tarball () {
	l_count=0
	echo "Creating test harness tar"
	#cd $WORKSPACE/workspace/$G_SMRS_KGB_JOBNAME
	tar -cf $G_TEST_HARNESS_TAR SOURCES/  || {
		echo "ERROR: unable to create test harness tarball"
		return 1
	}
	cat >/tmp/commands <<EOF || return 2	
	cd $G_REMOTE_TEST_HARNESS_DIR
	/usr/sfw/bin/gtar -xf $G_REMOTE_TEST_HARNESS_DIR/cominf_test.tar
EOF
	cat >/tmp/vapp_workspace <<EOF || return 2	
	cd $VAPP_WORKSPACE
	/bin/gtar -xf $VAPP_WORKSPACE/cominf_test.tar
EOF
 	chmod 777 /tmp/commands /tmp/vapp_workspace
	while [ "$l_count" -lt ${#CI_SERVER_IP[@]} ]; do
                if [ "${CI_SERVER_CONFIG[$l_count]}" = scripting_server ]; then
			$G_SSH_SETUPSCRIPT ssh "root@${CI_SERVER_IP[$l_count]} mkdir -p $VAPP_WORKSPACE" ${CI_SERVER_ROOTPW[$l_count]}|| {
                                echo "ERROR: Unable to create $VAPP_WORKSPACE directory in ${CI_SERVER_CONFIG[$l_count]}"
                                return 1
                        }
			$G_SSH_SETUPSCRIPT ssh "root@${CI_SERVER_IP[$l_count]} chown ossrcdm:ossrcdm $VAPP_WORKSPACE" ${CI_SERVER_ROOTPW[$l_count]}|| {
                                echo "ERROR: Unable to create $VAPP_WORKSPACE directory in ${CI_SERVER_CONFIG[$l_count]}"
                                return 1
                        }
			$G_SSH_SETUPSCRIPT scp "$G_TEST_HARNESS_TAR /tmp/vapp_workspace root@${CI_SERVER_IP[$l_count]}:$VAPP_WORKSPACE/" ${CI_SERVER_ROOTPW[$l_count]}  > /dev/null || {
				echo "ERROR: Unable to copy $G_TEST_HARNESS_TAR on server ${CI_SERVER_HOSTNAME[$l_count]}"
				return 2
			}
			$G_SSH_SETUPSCRIPT ssh "root@${CI_SERVER_IP[$l_count]} $VAPP_WORKSPACE/vapp_workspace " ${CI_SERVER_ROOTPW[$l_count]} || {
				echo "ERROR: Unable to untar $G_REMOTE_TEST_HARNESS_DIR/cominf_test.tar in ${CI_SERVER_CONFIG[$l_count]}"
				return 5
			}
		fi

                if [ "${CI_SERVER_HARNESS_HOST[$l_count]}" = TRUE ]; then
		[ "${CI_SERVER_CONFIG[$l_count]}" = system ] && {
			if [ -n "${CI_SERVER_SSH_NAT_PORT[$l_count]}" ]; then
				l_ssh_nat_port="-oPort=${CI_SERVER_SSH_NAT_PORT[$l_count]}"
			fi
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port  root@${CI_SERVER_IP[$l_count]} mkdir -p $G_REMOTE_TEST_HARNESS_DIR" ${CI_SERVER_ROOTPW[$l_count]}|| {
				echo "ERROR: Unable to create $G_REMOTE_TEST_HARNESS_DIR directory in ${CI_SERVER_CONFIG[$l_count]}"
				return 1
			}
			echo "Copying test harness tar to  OSSRC_MASTER of ${CI_SERVER_IP[$l_count]}"
			$G_SSH_SETUPSCRIPT scp "$l_ssh_nat_port  $G_TEST_HARNESS_TAR /tmp/commands root@${CI_SERVER_IP[$l_count]}:$G_REMOTE_TEST_HARNESS_DIR/" ${CI_SERVER_ROOTPW[$l_count]}  > /dev/null || {
				echo "ERROR: Unable to copy $G_TEST_HARNESS_TAR on server ${CI_SERVER_HOSTNAME[$l_count]}"
				return 2
			}
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port  root@${CI_SERVER_IP[$l_count]} $G_REMOTE_TEST_HARNESS_DIR/commands " ${CI_SERVER_ROOTPW[$l_count]} || {
				echo "ERROR: Unable to untar $G_REMOTE_TEST_HARNESS_DIR/cominf_test.tar in ${CI_SERVER_CONFIG[$l_count]}"
				return 5
			}
			
			
		}
		[ "${CI_SERVER_CONFIG[$l_count]}" = om_serv_master ] && {
			if [ -n "${CI_SERVER_SSH_NAT_PORT[$l_count]}" ]; then
				l_ssh_nat_port="-oPort=${CI_SERVER_SSH_NAT_PORT[$l_count]}"
			fi
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port  root@${CI_SERVER_IP[$l_count]} mkdir -p $G_REMOTE_TEST_HARNESS_DIR" ${CI_SERVER_ROOTPW[$l_count]}|| {
				echo "ERROR: Unable to create $G_REMOTE_TEST_HARNESS_DIR directory in ${CI_SERVER_CONFIG[$l_count]}"
				return 3
			}
			echo "Copying test harness tar to om_serv_master of ${CI_SERVER_IP[$l_count]}"
			$G_SSH_SETUPSCRIPT scp "$l_ssh_nat_port  $G_TEST_HARNESS_TAR /tmp/commands root@${CI_SERVER_IP[$l_count]}:$G_REMOTE_TEST_HARNESS_DIR/" ${CI_SERVER_ROOTPW[$l_count]} > /dev/null || {
				echo "ERROR: upgrade_smrs.sh script failed on server ${CI_SERVER_HOSTNAME[$l_count]}"
				return 4
			}
			$G_SSH_SETUPSCRIPT ssh "$l_ssh_nat_port  root@${CI_SERVER_IP[$l_count]} $G_REMOTE_TEST_HARNESS_DIR/commands " ${CI_SERVER_ROOTPW[$l_count]}|| {
				echo "ERROR: Unable to untar $G_REMOTE_TEST_HARNESS_DIR/cominf_test.tar in ${CI_SERVER_CONFIG[$l_count]}"
				return 6
			}
		}
		fi
	let l_count+=1	
		
	done
	
}
get_harness_host() {
        local l_count=0
        G_HARNESS_HOST=""
        G_HARNESS_HOST_ROOTPW=""
        G_HARNESS_HOST_SSH_NAT_PORT=""
        G_HARNESS_HOST_CONFIGTYPE=""
	G_HARNESS_HOST_NAME=""
        while [ $l_count -lt ${#CI_SERVER_IP[@]} ]; do
                if [ "${CI_SERVER_HARNESS_HOST[$l_count]}" = TRUE ]; then
                        G_HARNESS_HOST=${CI_SERVER_IP[$l_count]}
                        G_HARNESS_HOST_ROOTPW=${CI_SERVER_ROOTPW[$l_count]}
                        G_HARNESS_HOST_SSH_NAT_PORT="-oPort=${CI_SERVER_SSH_NAT_PORT[$l_count]}"
                        G_HARNESS_HOST_CONFIGTYPE=${CI_SERVER_CONFIG[$l_count]}
			G_HARNESS_HOST_NAME=${CI_SERVER_HOSTNAME[$l_count]}
                        break
                fi
                let l_count+=1
        done
        [ -z "$G_HARNESS_HOST" ] && return 1
        return 0

}

start_test_harness() {
        # start the harness on the remote server
        get_harness_host || {
                echo "Error failed to find test harness host"
                return 1
        }
        if [ -z "$G_HARNESS_HOST" ]; then
                echo "Unable to determine server on which to start harness"
                return 1
        fi
        echo "starting test harness on $G_HARNESS_HOST!"
	$G_SSH_SETUPSCRIPT ssh "-T $G_HARNESS_HOST_SSH_NAT_PORT root@$G_HARNESS_HOST $G_REMOTE_TEST_HARNESS_COMMAND < /dev/null > /tmp/harness.log 2>&1" $G_HARNESS_HOST_ROOTPW
        G_HARNESS_RETCODE=$?
        /bin/rm -f /tmp/harness.log > /dev/null 2>&1
        $G_SSH_SETUPSCRIPT scp "$G_HARNESS_HOST_SSH_NAT_PORT  root@$G_HARNESS_HOST:/tmp/harness.log /tmp" $G_HARNESS_HOST_ROOTPW &&
        cat /tmp/harness.log

        return $G_HARNESS_RETCODE

}
start_test_harness_onVAPP() {
        # start the harness on the remote server
        get_harness_host || {
                echo "Error failed to find test harness host"
                return 1
        }
        if [ -z "$G_HARNESS_HOST" ]; then
                echo "Unable to determine server on which to start harness"
                return 1
        fi
	rm -rf /home/ossrcdm/.ssh/known_hosts
        echo "starting test harness on $G_HARNESS_HOST!"
	$G_SSH_SETUPSCRIPT ssh "-o StrictHostKeyChecking=no root@$G_HARNESS_HOST_NAME $G_REMOTE_TEST_HARNESS_COMMAND < /dev/null > /tmp/harness.log 2>&1" $G_HARNESS_HOST_ROOTPW
        G_HARNESS_RETCODE=$?
        /bin/rm -f /tmp/harness.log > /dev/null 2>&1
        $G_SSH_SETUPSCRIPT scp "-o StrictHostKeyChecking=no root@$G_HARNESS_HOST_NAME:/tmp/harness.log /tmp" $G_HARNESS_HOST_ROOTPW &&
        cat /tmp/harness.log

        return $G_HARNESS_RETCODE

}

copy_test_results() {
        # make directory for harness results if needed
        echo "copying results of test harness to CI server dir=$G_RESULTS_DIR "
        # copy test harness results back to CI server
        $G_SSH_SETUPSCRIPT scp "-o StrictHostKeyChecking=no $G_HARNESS_HOST_SSH_NAT_PORT root@$G_HARNESS_HOST:/$G_REMOTE_TEST_HARNESS_RESULTS_TGZ $G_RESULTS_DIR" $G_HARNESS_HOST_ROOTPW  || {
                echo "Error - Failed to copy test harness results from $G_HARNESS_HOST to CI server"
                return 1
        }
        # expand test results
        #cd $WORKSPACE/workspace/$G_SMRS_KGB_JOBNAME/$BUILD_NUMBER
        tar -zxvf "$G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL" > /dev/null 2>&1 || {
                echo "Error - failed to unpack file $G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL"
                return 1
        }
        # remove the tar file
        /bin/rm -f "$G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL" || {
                echo "warning - unable to delete local results tarball $G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL"
       }

        return 0

}
copy_test_results_to_VAPP() {
        # make directory for harness results if needed
        echo "copying results of test harness to CI server dir=$VAPP_WORKSPACE"
        # copy test harness results back to CI server
        $G_SSH_SETUPSCRIPT scp " -o StrictHostKeyChecking=no root@$G_HARNESS_HOST_NAME:/$G_REMOTE_TEST_HARNESS_RESULTS_TGZ $VAPP_WORKSPACE" $G_HARNESS_HOST_ROOTPW  || {
                echo "Error - Failed to copy test harness results from $G_HARNESS_HOST_NAME to CI server"
                return 1
        }
        # expand test results
        #cd $WORKSPACE/workspace/$G_SMRS_KGB_JOBNAME/$BUILD_NUMBER
	cd $VAPP_WORKSPACE/
        tar -zxvf "$VAPP_WORKSPACE/$G_TEST_HARNESS_RESULTS_TARBALL" > /dev/null 2>&1 || {
                echo "Error - failed to unpack file $G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL"
                return 1
        }
        # remove the tar file
        /bin/rm -f "$VAPP_WORKSPACE/$G_TEST_HARNESS_RESULTS_TARBALL" || {
                echo "warning - unable to delete local results tarball $G_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL"
       }
	mkdir -p /tmp/manual_reports 
	scp  -o StrictHostKeyChecking=no $VAPP_WORKSPACE/$BUILD_NUMBER/manual_report.csv /tmp/manual_reports/

        return 0

}
copy_package_to_vapp () {
        cat >/tmp/commands <<EOF || return 2    
        cd /var/tmp/
        echo y | unzip /var/tmp/$PACKAGE_ZIP
        sleep 1
        echo y | pkgadd -d /var/tmp/$PACKAGE.pkg all
EOF
        chmod 777 /tmp/commands

	if [[ "${PACKAGE}" = ERICocs || "${PACKAGE}" = ERICsdse ]]; then

        echo "Copying the $PACKAGE_ZIP from workspace to omsrvm of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2204  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to omsrvm"
                return 4
        }
        echo "Upgrading the $PACKAGE on omsrvm"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2204 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null || {
                echo "ERROR:Removing the $PACKAGE in omsrvm"
                return 4
        }
        $G_SSH_SETUPSCRIPT ssh "-oPort=2204 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in omsrvm"
                return 4
        }

        echo "Copying the $PACKAGE_ZIP from workspace to omsrvs of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2207  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to omsrvs"
                return 4
        }
        echo "Upgrading the $PACKAGE on omsrvs"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2207 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null || {
                echo "ERROR:Removing the $PACKAGE in omsrvs"
                return 4
        }
        $G_SSH_SETUPSCRIPT ssh "-oPort=2207 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in omsrvs"
                return 4
        }
	        echo "Copying the $PACKAGE_ZIP from workspace to omsas of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2203  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to omsas"
                return 4
        }
        echo "Upgrading the $PACKAGE on omsas"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2203 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null || {
                echo "ERROR:Removing the $PACKAGE in omsas"
                return 4
        }
        $G_SSH_SETUPSCRIPT ssh "-oPort=2203 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in omsas"
                return 4
        }
	fi

#Updating for ERICodj
if [ "${PACKAGE}" = ERICodj ]; then
	echo "Copying the $PACKAGE_ZIP from workspace to omsrvm of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2204  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
        echo "ERROR:Copying $PACKAGE_ZIP to omsrvm"
        return 4
        }

	echo "Upgrading the $PACKAGE on omsrvm"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2204 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null
	ret_val=$?

	if [ ${ret_val} -eq 1 ]; then
		echo "Adding the new package $PACKAGE"
	elif [ ${ret_val} -eq 0 ]; then
                echo "Successfully removed the previous $PACKAGE package on omsrvm"
	else
		echo "ERROR:Removing the $PACKAGE in omsrvm"
                return 4
	fi

	echo "Adding the latest $PACKAGE package on omsrvm"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2204 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null || {
                echo "ERROR:adding the $PACKAGE in omsrvm"
                return 4
        }

        echo "Copying the $PACKAGE_ZIP from workspace to omsrvs of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2207  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to omsrvs"
                return 4
        }
        echo "Upgrading the $PACKAGE on omsrvs"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2207 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null
	ret_val=$?

        if [ ${ret_val} -eq 1 ]; then
		echo "Adding the new package $PACKAGE"
        elif [ ${ret_val} -eq 0 ]; then
                echo "Successfully removed the previous $PACKAGE package on omsrvs"
        else
                echo "ERROR:Removing the $PACKAGE in omsrvs"
                return 4
        fi

	echo "Adding the latest $PACKAGE package on omsrvs"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2207 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in omsrvs"
                return 4
        }

                echo "Copying the $PACKAGE_ZIP from workspace to omsas of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2203  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to omsas"
                return 4
        }
        echo "Upgrading the $PACKAGE on omsas"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2203 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null
	ret_val=$?

        if [ ${ret_val} -eq 1 ]; then
		echo "Adding the new package $PACKAGE"
        elif [ ${ret_val} -eq 0 ]; then
                echo "Successfully removed the previous $PACKAGE package on omsas"
        else
                echo "ERROR:Removing the $PACKAGE in omsas"
                return 4
        fi

	echo "Adding the latest $PACKAGE package on omsas"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2203 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in omsas"
                return 4
        }
fi

if [ "${PACKAGE}" = ERICocs ]; then
        echo "Copying the $PACKAGE_ZIP from workspace to uas of VAPP"
        $G_SSH_SETUPSCRIPT scp "-oPort=2206  /tmp/commands  $G_WORKSPACE/$PACKAGE_ZIP root@$G_VAPP_IP:/var/tmp/" shroot > /dev/null  || {
                echo "ERROR:Copying $PACKAGE_ZIP to uas"
                return 4
        }
        echo "Upgrading the $PACKAGE uas"
        $G_SSH_SETUPSCRIPT ssh "-oPort=2206 root@$G_VAPP_IP \"echo 'y' | pkgrm $PACKAGE\"" shroot > /dev/null  || {
                echo "ERROR:Removing the $PACKAGE in uas"
                return 4
        }
        $G_SSH_SETUPSCRIPT ssh "-oPort=2206 root@$G_VAPP_IP /var/tmp/commands" shroot > /dev/null  || {
                echo "ERROR:adding the $PACKAGE in uas"
                return 4
        }
fi

}


#MAIN

G_SCRIPTDIR=$(cd $(/usr/bin/dirname $0); pwd)
G_ETCDIR=$( dirname $G_SCRIPTDIR )/etc
G_BINDIR=$( dirname $G_SCRIPTDIR )/bin
G_WORKSPACE=$(cd $(/usr/bin/dirname $0); cd ../../../../; pwd)
G_SCRIPTNAME=$(/bin/basename $0)
G_SMRS_UPGRADE=FALSE
G_OCS_UPGRADE=FALSE
G_SSH_SETUPSCRIPT=$G_SCRIPTDIR/ssh_setup.sh
G_REMOTE_SMRS_BIN_DIR="/opt/ericsson/nms_bismrs_mc/bin"
G_START_TEST_HARNESS=FALSE
G_REMOTE_TEST_HARNESS_DIR="/opt/ericsson/cominf_test"
G_REMOTE_TEST_HARNESS_SCRIPT="$G_REMOTE_TEST_HARNESS_DIR/SOURCES/harness/bin/atcominf.bsh"
G_PKG_DELIVERY=FALSE
G_STAGING_AREA="/vobs/cominf_media/media_build/om_services/dvd/Solaris_10/i386/Packages"
G_II_TESTWARE=FALSE
G_UPG_TESTWARE=FALSE
G_EC=FALSE

while getopts "sohtf:r:p:dec" opt; do

	case $opt in
		s)
			G_SMRS_UPGRADE=TRUE
		;;
		o)
			G_OCS_UPGRADE=TRUE
		;;
		t)
			G_START_TEST_HARNESS=TRUE
		;;
		f)
			G_ENVFILE=$OPTARG
                ;;
                r)
                        R_STATE=$OPTARG
                ;;
                p)
                        PACKAGE=$OPTARG
                ;;
                d)
                        G_PKG_DELIVERY=TRUE
                ;;
                i)
                        G_II_TESTWARE=TRUE
                ;;
		c)
			Delivery_type=EC
		;;
                u)
                        G_UPG_TESTWARE=TRUE
                ;;
                e)
                        G_EC=TRUE
                ;;
		h)
			usage
			exit 0
		;;
		?)      # Print usage and exit error
			printf "${SCRIPTNAME}: ERROR: Invalid option: '${OPTARG}'.\n"
			usage
			exit 1
		;;

	esac
done

if [ $G_PKG_DELIVERY = FALSE ]; then
	if [ -s $G_ENVFILE ]; then
		if [ $G_II_TESTWARE = TRUE ]; then
			$G_BINDIR/ci_syncIP.bsh $G_ENVFILE II
		elif [ $G_UPG_TESTWARE = TRUE ]; then
			$G_BINDIR/ci_syncIP.bsh $G_ENVFILE U
		else 
			$G_BINDIR/ci_syncIP.bsh $G_ENVFILE S
		fi
. $G_ENVFILE
	else 
		echo "ERROR: $G_ENVFILE file is missing"
		exit 2
	fi
fi
	G_VAPP_IP=`grep "CI_SERVER_IP\[4\]" $G_ENVFILE | awk -F= '{print $2}'`
	G_TEST_HARNESS_RESULTS_TARBALL=${BUILD_NUMBER}_report.tar.gz
	G_REMOTE_TEST_RESULTS_DIR="/var/tmp/reports/ci"
	G_REMOTE_TEST_HARNESS_RESULTS_TGZ="$G_REMOTE_TEST_RESULTS_DIR/$G_TEST_HARNESS_RESULTS_TARBALL"

if [[ "${G_SMRS_UPGRADE}" = TRUE && "${G_START_TEST_HARNESS}" = FALSE ]]; then
	[[ ${G_EC} = FALSE ]] && VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/SMRS_KGB_AT_MASTER"
	[[ ${G_EC} = TRUE ]] && VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/SMRS_EC_KGB"
	G_TEST_HARNESS_TAR=${G_WORKSPACE}/cominf_test.tar

	upgrade_smrs || exit 1
	create_test_harness_tarball || exit 3
	
fi
G_WORKSPACE=${G_WORKSPACE}
G_TEST_HARNESS_TAR=${G_WORKSPACE}/cominf_test.tar

if [[ "${G_OCS_UPGRADE}" = TRUE && "${G_START_TEST_HARNESS}" = FALSE ]]; then
        if [ ${PACKAGE} = ERICocs ]; then
		PACKAGE_ZIP=19089-CXC1731203_$R_STATE.zip
		if [ "${Delivery_type}" = EC ] ; then
			VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICOCS_EC_MEDIA_PACKAGE_KGB"	
		else
			VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICOCS_PKG_KGB"
		fi
        elif [ ${PACKAGE} = ERICsdse ]; then
                PACKAGE_ZIP=19089-CXC1731204_$R_STATE.zip
		VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICSDSE_PKG_KGB"

	#Updating for ERICodj
        elif [ ${PACKAGE} = ERICodj ]; then
                PACKAGE_ZIP=19089-CXC1739570_$R_STATE.zip
		VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERIC_OPENDJ_KGB"
        else
                echo "Specified $PACKAGE is invalid"
                exit 1
        fi
        copy_package_to_vapp || exit 1
	create_test_harness_tarball || exit 3

fi


if [ "$G_START_TEST_HARNESS" = TRUE ]; then

if [ "${G_OCS_UPGRADE}" = TRUE ]; then
        if [ ${PACKAGE} = ERICocs ]; then
			if [ "${Delivery_type}" = EC ] ; then
				VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICOCS_EC_MEDIA_PACKAGE_KGB"	
			else
                VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICOCS_PKG_KGB"
			fi
        elif [ ${PACKAGE} = ERICsdse ]; then
                VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERICSDSE_PKG_KGB"

	#Updating for ERICodj
        elif [ ${PACKAGE} = ERICodj ]; then
                VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/ERIC_OPENDJ_KGB"
        else
                echo "Specified $PACKAGE is invalid"
                exit 1
        fi
elif [ "${G_SMRS_UPGRADE}" = TRUE ]; then
        [[ ${G_EC} = FALSE ]] && VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/SMRS_KGB_AT_MASTER"
        [[ ${G_EC} = TRUE ]] && VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/SMRS_EC_KGB"
else
	VAPP_WORKSPACE="/home/ossrcdm/jenkins/workspace/iso_harness"
fi

start_test_harness_onVAPP
copy_test_results_to_VAPP || exit 5
	#copy_test_results || exit 5
        if [ $G_HARNESS_RETCODE -ne 0 ]; then
                echo "** Test harness returned non-zero error code $G_HARNESS_RETCODE **"
                echo "** Job failed **"
        else
                echo -e "\n\n** Job completed successfully **\n\n"
        fi

fi

if [ "${G_PKG_DELIVERY}" = TRUE ]; then
        if [ "${PACKAGE}" = ERICocs ]; then
                PACKAGE_DM_DIR=/vobs/ocs_design/src/com/ericsson/oss/ocs_x86/dm/pkg
        elif [ "${PACKAGE}" = ERICsdse ]; then
                PACKAGE_DM_DIR=/vobs/cominf_sdse/src/com/ericsson/oss/sdse/SDSE_X86/ERICsdse/dm/pkg
        elif [ "${PACKAGE}" = ERICodj ]; then
                PACKAGE_DM_DIR=/vobs/cominf_sdse/src/com/ericsson/oss/odj/ODJ_X86/ERICodj/dm/pkg
        else
                echo "Specified $PACKAGE is invalid"
                exit 1
        fi
        if cmp -s  $G_STAGING_AREA/$PACKAGE.pkg  $PACKAGE_DM_DIR/$PACKAGE.pkg 2>/dev/null; then
                echo "New package file   $PACKAGE_DM_DIR/$PACKAGE.pkg same as file in staging area. No need to copy."
        else
                /usr/atria/bin/cleartool setview -exec "/usr/atria/bin/cleartool co -nc $G_STAGING_AREA/$PACKAGE.pkg" cominfbld1_view  || {
                        echo "Unable to checkout $G_STAGING_AREA/$PACKAGE.pkg in staging area"
                        exit 1
                }
                # copy package from tmp location to staging area
                /usr/atria/bin/cleartool setview -exec "cp -f $PACKAGE_DM_DIR/$PACKAGE.pkg $G_STAGING_AREA/$PACKAGE.pkg" cominfbld1_view  > /dev/null || {
                        echo "Failed to copy  $PACKAGE.pkg to media staging area $G_STAGING_AREA"
                         exit 1
                }
                /usr/atria/bin/cleartool setview -exec "/usr/atria/bin/cleartool ci -nc $G_STAGING_AREA/$PACKAGE.pkg" cominfbld1_view  >> /dev/null || {
                        echo "Unable to check in $G_STAGING_AREA/$PACKAGE.pkg in staging area"
                        exit 1
                }
		echo "Updating R-state in media info file"
		rstate=`/usr/atria/bin/cleartool setview -exec "/proj/jkadm100/bin/lxb sol10u10sparc /usr/bin/pkginfo -ld $PACKAGE_DM_DIR/$PACKAGE.pkg | grep VERSION" cominfbld1_view`
		rstate=`echo $rstate | awk '{print $2}'`
		pkg=${PACKAGE}
		/usr/atria/bin/cleartool setview -exec "sed = /vobs/cominf_media/media_build/om_services/dvd/manifest/media_info | sed 'N;s/\n/ /' > /tmp/media_info_tmp.$$" cominfbld1_view 
#		sed = /vobs/cominf_media/media_build/om_services/dvd/manifest/media_info | sed 'N;s/\n/ /' > /tmp/media_info_tmp
		lno=$(sed -n "/NAME=$pkg/,/RSTATE/=" /tmp/media_info_tmp.$$ | tail -1 )
		rs=$(sed -n "/NAME=$pkg/,/RSTATE/p" /tmp/media_info_tmp.$$ | tail -1 |awk -F= '{print $2}')
		/usr/atria/bin/cleartool setview -exec "/usr/atria/bin/cleartool co -nc /vobs/cominf_media/media_build/om_services/dvd/manifest/media_info" cominfbld1_view  || {
	        	echo "Unable to checkout media info file"
	                exit 1
	        }
		/usr/atria/bin/cleartool setview -exec "sed -i "$lno\s/$rs/$rstate/" /vobs/cominf_media/media_build/om_services/dvd/manifest/media_info" cominfbld1_view || {
			echo "Unable to edit media Info file"
			exit 1
		}
		/usr/atria/bin/cleartool setview -exec "/usr/atria/bin/cleartool ci -nc /vobs/cominf_media/media_build/om_services/dvd/manifest/media_info" cominfbld1_view  >> /dev/null || {
			echo "Unable to checkin media info file"
	                exit 1
	        }
        fi
	rm /tmp/media_info_tmp.$$

fi
