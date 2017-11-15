#!/bin/bash
lofile=smtp-operations.log
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

#count=26
mailfrom=xx2
rcptto=xx1
loginuser=xx1
deleteuser=xx1@openwave.com

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""

#sedning messages
#for ((i=1;i<=$count;i++ ))
#do
	#DATA=`cat message$i.txt`
	echo -e "\n"
	echo "Message$i body is:"
	echo -e "$DATA"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Sending message$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Sending message$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>smtp-operations.log
  exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:$mailfrom\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3
  echo -en "DATA\r\n" >&3
  #echo -en "Subject: testmessage$i-ASCII-CRLF\r\n" >&3
  #echo -en "\r\n" >&3
  #if (( i== 1))
  #then
  #   echo -en ".\r\n" >&3
  #else
     echo -en "`cat empty-body-message.txt`\r\n" >&3
     echo -en ".\r\n" >&3
  #fi
  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	echo  -e  "\n\n sending message$i:"
	echo -e "\n"
	cat smtp-temp.log
	echo  -e  "\n\n\ sending message$i:" >>smtp-operations.log
	echo -e "\n" >> smtp-operations.log
	echo -e "\n"
  cat smtp-temp.log >>smtp-operations.log
	exec 3>&-
#done

#fetching messages
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log
rm -rf  imap-temp.log
rm -rf  smtp-temp.log
