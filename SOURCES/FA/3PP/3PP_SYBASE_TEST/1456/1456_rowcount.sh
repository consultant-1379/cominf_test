#!/bin/sh

AWK=/usr/bin/awk
SYBASE_ASE=ASE-15_0
SYBASE_OCS=OCS-15_0
TAIL=/usr/bin/tail
TOUCH=/usr/bin/touch
WC=/usr/bin/wc

# ********************************************************************
#
#       Pre-execution Operations
#
SA_PASS="sybase11"
SA_USER="sa"



ISQL="$SYBASE/$SYBASE_OCS/bin/isql"


tables=`$ISQL -Usa -P$SA_PASS -DActivitySupportDatabase << eof2 | grep " "| $AWK '$1 !~ /(---)/  { print $1 }'
set nocount on
select count (*) from sysobjects where type = "U"
go
eof2`



$ISQL -Usa -P$SA_PASS -DActivitySupportDatabase -w4000 -olist1 <<SQLEOF1
set nocount on
go
select name from sysobjects where type = "U"  
go
SQLEOF1

tail +3 list1 > newfile

rm list1 1>null 2>&1
for tableName in `cat newfile`; do
echo "set nocount on" >> listx
echo "go" >> listx
echo "select '$tableName'AS 'Table Name                   ',COUNT(*) AS 'Number of Rows' from $tableName" >> listx
echo "go" >> listx
done


echo "\n____________________________________________________________________"

$ISQL -Usa -P$SA_PASS -DActivitySupportDatabase -ilistx -olist <<SQLEOF2
SQLEOF2
printf "%-32s %-15s \n" " TABLE NAME"     "NUMBER OF ROWS"  
printf " "
echo " "
$AWK '$0 !~ /(Table Name  |---)/  { print $0 }' list

echo " "
echo  "Number of TABLES in ActivitySupportDatabase = "${tables}""

rm newfile 1>/ericsson/syb/tmp/null 2>&1
rm listx 1>/ericsson/syb/tmp/null 2>&1
rm list 1>/ericsson/syb/tmp/null 2>&1
rm -f null 1>/ericsson/syb/tmp/null 2>&1 

chmod 777 /ericsson/syb/tmp/* > /dev/null 2>/dev/null

end ()
