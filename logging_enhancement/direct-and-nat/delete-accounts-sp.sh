#!/bin/bash
counts=11
mxoshost=172.26.203.123:8081
echo "<<<<<<<<<<delete $counts accounts>>>>>>>>>>"
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/92SITE2-92xmc/mss/clusterName=mx-172-26-203-123"\""
for (( i=0;i<$counts;i++ ))
do
	 echo "Deleting account$i...................."
	 d=`curl -s  -X DELETE  "http://$mxoshost/mxos/mailbox/v2/mx95user$i@openwave.com" |jq . `
   if [ "$d" = "" ]
   then
      echo "mx95user$i deleted successfully!:-):-):-):-):-):-):-):-):-):-)"
   else
      echo "mx95user$i deleted not successfully!:-(:-(:-(:-(:-(:-(:-(:-(:-(:-("
      echo $d
fi
done
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/92SITE2-92xmc/mss/clusterName=92xmc"\""