#!/bin/bash

#clear  accounts-create.log  if existed
lofile=accounts-create.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi
touch accounts-create.log
counts=11
mxoshost=10.49.58.129:8081
echo "<<<<<<<<<<create $counts accounts>>>>>>>>>>"
for (( i=0;i<$counts;i++ ))
do
	echo "Creating account$i...................."
	curl -s  -X PUT  -d"cosId=default&password=p" "http://$mxoshost/mxos/mailbox/v2/mx95user$i@openwave.com" |jq . |tee temp.log
	#l=1 means creating correctly ,else failed
	l=`cat temp.log |wc -l`
	if [ $l = 1 ]
	then
		echo "account$i created successfully :-):-):-):-):-):-):-):-):-):-)"
	else
		echo "account$i created failed :-(:-(:-(:-(:-(:-(:-(:-(:-(:-("
		cat  temp.log
	cat temp.log >> accounts-create.log
	fi
	sleep 1
done
echo "===================accounts created finished========================="
#remove temp log file
rm -rf temp.log
