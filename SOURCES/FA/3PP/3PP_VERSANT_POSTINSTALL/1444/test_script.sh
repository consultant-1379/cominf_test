#!/bin/bash


#inc lib
. /ericsson/versant/bin/vrsnt_libadm.sh

VINFO=/opt/versant/ODBMS/bin/vinfo
PKGINFO=/bin/pkginfo
VRSNT_TOOLSDIR=/opt/versant/ODBMS/bin/db2tty
alldbs="DMDB NADB NMSNADB AMDB ONRM_CS WRAN_SUBNETWORK_MIRROR_CS"

_DATE=/usr/xpg4/bin/date

ERIC_ETC=/ericsson/versant/etc
ENABLE_MONITOR=/ossrc/versant/.monitor_enabled

action=0

# get the current user
CURRENT_USER=`/usr/xpg4/bin/id -un` > /dev/null
# Figure out who we are
if [ "${CURRENT_USER}" != "nmsadm" ] ; then
        echo "This utility can only be run by nmsadm"
        exit 1
fi

init_variable

DAILY_BACKUP_CHECK="$ERIC_ETC/daily_backup_check.sh"

# ********************************************************************
#
#       functions
#
# ********************************************************************

CheckAllDBStatus()
{
        RETURN_COUNT=0

        $ECHO ""
        $ECHO "Check for the status of all databases:"
        $ECHO "-----------------------------------------------------------------------------------"

        #List_alldbs
        #alldbs=`$CAT $ALLDB_LOG`

        for db in $alldbs
        do
                DBSTATUS="Online"
                CheckdbStatus $db
                if [ $? -eq 1 ]; then
                        RETURN_COUNT=`$EXPR $RETURN_COUNT + 1`
                        DBSTATUS="Offline"
                fi
                printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBSTATUS}"
        done
        return $RETURN_COUNT
}


CheckAllDBMode()
{
        $ECHO ""
        $ECHO "Check for the mode of all databases:"
        $ECHO "-----------------------------------------------------------------------------------"

        RETURN_COUNT=0
        #List_alldbs
        #alldbs=`$CAT $ALLDB_LOG`
        for db in $alldbs
        do
                DBMODE="Multi-user"
                CheckdbMode $db
                if [ $? -eq 1 ]; then
                        RETURN_COUNT=`$EXPR $RETURN_COUNT + 1`
                        DBMODE="Not multi-user"
                fi
                printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBMODE}"
        done
        return $RETURN_COUNT
}


Checkdb()
{
        CheckAllDBMode
        RETURN_STATUS1=$?
        CheckAllDBStatus
        RETURN_STATUS2=$?

        if [ $RETURN_STATUS1 -ne 0 ]; then
                $ECHO "";$ECHO "There are ${RETURN_STATUS1} databases not in multi-user mode."
        fi
        if [ $RETURN_STATUS2 -ne 0 ]; then
                $ECHO "";$ECHO "There are ${RETURN_STATUS2} offline databases."
        fi
}

CheckDetails(){
        CheckAllDBStatus
        active_dbs=`/ericsson/versant/bin/vrsnt_activedb`
        $ECHO "-----------------------------------------------------------------------------------------------------------"
        active_dbs=`/ericsson/versant/bin/vrsnt_activedb`
        if [ `$ECHO $active_dbs | grep -v '^\s*$' | wc -l` -eq 0 ]; then
                $ECHO "No Running Databases, Please Start The Database First"
                return 1
        fi
        $ECHO "      For which database you want to check details"
        not_match=0
        while [ $not_match -eq 0 ]
        do
                $ECHO "      Please enter the database name: \c"
                read database
                for db in $active_dbs
                do
                        if [ "$database" == "$db" ]; then
                                not_match=1
                                break
                        fi
                done
                [ $not_match -eq 0 ] && $ECHO "      $database is not a running database"
                $ECHO
        done

        $ECHO "      Generating $database Details ..."
        $DBTOOL -sys -info -res -detail $database > /tmp/vrsnt_db_connections.log
        $ECHO >> /tmp/vrsnt_db_connections.log
        $ECHO "====================================      Processes connected to $database      ====================================" >> /tmp/vrsnt_db_connections.log
        $ECHO "      Parsing Process Info ..."
        $ECHO "====================================      Resource Details of $database      ===================================="
        parse_processes /tmp/vrsnt_db_connections.log /tmp/vrsnt_db_connections.log
        cat /tmp/vrsnt_db_connections.log
        rm /tmp/vrsnt_db_connections.log
}


NonMultiMode()
{
        CheckAllDBMode
        $ECHO "-----------------------------------------------------------------------------------------------------------"
        $ECHO "      Turning off multi-user mode for all DBs! Please wait..."
        for db in $alldbs
        do
                Unstartabledb $db
                if [ $? -eq 1 ]; then
                        RETURN_COUNT=`$EXPR $RETURN_COUNT + 1`
                        DBSTATUS="multi-user. NOT OK!"
                        printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBSTATUS}"
                fi
        done
        return $RETURN_COUNT

}

Stopdbs()
{
        CheckAllDBStatus
        $ECHO "-----------------------------------------------------------------------------------------------------------"
        $ECHO "      Stopping all databases! Please wait...."

        for db in $alldbs
        do
                        Stopdb $db
                if [ $? -eq 1 ]; then
                        RETURN_COUNT=`$EXPR $RETURN_COUNT + 1`
                        DBSTATUS="Failed to offline DB: $db"
                        printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBSTATUS}"
                fi
        done
        return $RETURN_COUNT
}


is_exist_db(){
        $DBLIST | grep "DB name" | nawk '{print $4}' | grep $1 > /dev/null
        return $?
}



print_alarms()
{

        return 0
}

CheckConnect()
{
for db in $alldbs; do
                $VRSNT_TOOLSDIR -d $db
                        DBRES="OK! db2tty finished sucessfully"
                if [ $? -eq 1 ]; then
                        RETURN_COUNT=`$EXPR $RETURN_COUNT + 1`
                        DBRES="NOK! db2tty did not finished sucessfully. Problem with $db"
                        printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBRES}"
                fi
                printf "%-30s %50s %-10s\n" "${db}" ".................................................." "${DBRES}"
        done
}

Quit()
{
        $ECHO;$ECHO "Wait for last check before you leave..."
        Checkdb > $TMP_CHECK
        offlinedb=`$CAT $TMP_CHECK | $GREP "offline databases" | $WC -l`
        nonmmodedb=`$CAT $TMP_CHECK | $GREP "not in multi-user" | $WC -l`

        if [ $nonmmodedb -gt 0 ]; then
                $ECHO;$ECHO "Do you want to set all unstartable databases into multi-user mode before you leave?(y or n)"
                read key;
                while [ ${key} != "y" -a ${key} != "n" ]
                do
                        $ECHO "Please type y or n!"
                        read key
                done
                if [ ${key} == "y" ]; then
                        $ECHO "Set all databases into multi-user mode. Please wait..."
                        MultimodeAlldbs > /dev/null
                        if [ $? -eq 0 ]; then
                                $ECHO "Complete!"
                        else
                                $ECHO "Failed!"
                        fi
                fi
        fi
        if [ $offlinedb -gt 0 ]; then
                $ECHO;$ECHO "Do you want to start the offline database before you leave?(y or n)"
                read key;
                while [ ${key} != "y" -a ${key} != "n" ]
                do
                        $ECHO "Please type y or n!"
                        read key
                done
                if [ ${key} == "y" ]; then
                        $ECHO "Starting all databases. Please wait..."
                        StartAlldbs > /dev/null
                        if [ $? -eq 0 ]; then
                                $ECHO "Complete!"
                        else
                                $ECHO "Failed!"
                        fi
                fi
        fi

        if [ -f $TMP_CHECK ]; then
                $RM $TMP_CHECK
        fi
        if [ -f $ACTIVEDB_LOG ]; then
                $RM $ACTIVEDB_LOG
        fi
        if [ -f $ACTIVEDB_LOG ]; then
                $RM $ALLDB_LOG
        fi

        $ECHO;$ECHO "Done!"
}

# ********************************************************************
#
#       Main body of program
#
# ********************************************************************

                   Checkdb;
                   NonMultiMode;
                   CheckAllDBMode;
                   Stopdbs;
                   CheckAllDBStatus;
                   MultimodeAlldbs;
                   CheckAllDBMode;
                   StartAlldbs;
                   Checkdb;
                   Quit;
                   CheckConnect;

