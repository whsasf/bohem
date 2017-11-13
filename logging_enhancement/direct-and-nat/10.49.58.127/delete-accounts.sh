#!/bin/bash
counts=11
mxoshost=10.49.58.129:8081
echo "<<<<<<<<<<delete $counts accounts>>>>>>>>>>"
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
