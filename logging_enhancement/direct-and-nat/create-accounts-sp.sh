#!/bin/bash

#clear  accounts-create.log  if existed
lofile=accounts-create.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi
touch accounts-create.log
counts=11
mxoshost=172.26.203.123:8081
FEPHost2=172.26.202.87
imailuser=imail2
echo "<<<<<<<<<<create $counts accounts>>>>>>>>>>"
for (( i=0;i<$counts;i++ ))
do
	echo "Creating account$i...................."
	curl -s  -X PUT  -d"cosId=default&password=p" "http://$mxoshost/mxos/mailbox/v2/mx95user$i@openwave.com" |jq . |tee temp.log
	ldiftmp="dn: mail=mx95user$i@openwave.com,dc=openwave,dc=com\nchangetype: modify\ndelete: mailmessagestore\n-\nadd: mailmessagestore\nmailmessagestore: 92xmc"
  echo -e $ldiftmp  >ldiftemp.ldif
  scp ldiftemp.ldif root@172.26.202.87:/opt/imail2
  ssh root@${FEPHost2} "chown imail2:imail   /opt/imail2/ldiftemp.ldif"
  ssh root@${FEPHost2} "su - ${imailuser} -c \"ldapmodify -h mx-172-26-202-87 -p 26006 -D cn=root  -w secret -f ldiftemp.ldif\""

  #ldapmodify -h mx-172-26-202-87 -p 26006 -D cn=root  -w secret -f ldiftemp.ldif
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
done
echo "===================accounts created finished========================="
#remove temp log file
rm -rf temp.log
rm -rf ldiftemp.ldif
