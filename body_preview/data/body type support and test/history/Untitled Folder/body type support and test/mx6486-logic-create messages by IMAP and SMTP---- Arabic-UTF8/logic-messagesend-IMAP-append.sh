#!/bin/bash
lofile=imap-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi

sumfile=summary.log
if [ -f "$sumfile" ]
then
	cat /dev/null >$sumfile
fi

SMTPHost=172.26.202.87
SMTPPort=20025

IMAPHost=172.26.202.87
IMAPPort=20143

count=24
mailfrom=xx2
rcptto=xx6

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   xx6@openwave.com  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

#sedning messages
for ((i=1;i<=$count;i++ ))
do
	length=`wc -c message-append$i.txt |awk  '{print $1}'`
	echo $length
	DATA=`cat message-append$i.txt`
  echo $DATA
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login xx6@openwave.com p\r\n" >&3
	echo -en "a select inbox\r\n" >&3
	echo -en "a append inbox {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
	cat imap-temp.log
  echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"
done

#fetching messages
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login xx6@openwave.com p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log
rm -rf  imap-temp.log
#rm -rf  smtp-temp.log
