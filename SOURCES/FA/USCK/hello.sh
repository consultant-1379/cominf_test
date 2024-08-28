set -x
localhost=`hostname`
echo $localhost
echo "Hello World"
ip=$1
ssh root@$localhost
ssh root@$ip "ls -lrt"
exit

