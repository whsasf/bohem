#!/bin/bash


lofile=imap-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
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
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"


#create 2 maiolboxes  :  /mytest   and /mytest/xx

  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a list "" *\r\n" >&3
  echo -en "a create mytest\r\n" >&3
	echo -en "a create mytest/xx\r\n" >&3
	echo -en "a list "" *\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch smtp-temp.log
	cat <&3 >smtp-temp.log
	exec 3>&-
  cat smtp-temp.log
  cat  smtp-temp.log > smtp-operations.log


   #sending message to inbox
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Sending message!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Sending message!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>smtp-operations.log
  exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:$mailfrom\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3
  echo -en "DATA\r\n" >&3
	echo -en "`cat mixed-UTF8-language-messagebody-SMTP.txt`\r\n" >&3
  echo -en ".\r\n" >&3
  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	echo -e "\n"
	cat smtp-temp.log
	echo -e "\n" >> smtp-operations.log
	echo -e "\n"
  cat smtp-temp.log >>smtp-operations.log
	exec 3>&-


#copy message
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a select inbox\r\n" >&3
	echo -en "a copy 1 Drafts\r\n" >&3
	echo -en "a copy 1 SentMail\r\n" >&3
	echo -en "a copy 1 Spam\r\n" >&3
	echo -en "a copy 1 Trash\r\n" >&3
	echo -en "a copy 1 mytest\r\n" >&3
	echo -en "a copy 1 mytest/xx\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch smtp-temp.log
	cat <&3 >smtp-temp.log
	exec 3>&-
  cat smtp-temp.log
  cat  smtp-temp.log > smtp-operations.log



#fetching messages
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
#echo "fetching inbox">>
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching Drafts
echo -en "a select Drafts\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching SentMail
echo -en "a select SentMail\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching Spam
echo -en "a select Spam\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching Trash
echo -en "a select Trash\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching mytest
echo -en "a select mytest\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
#fetching mytest/xx
echo -en "a select mytest/xx\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a delete mytest/xx\r\n" >&3
echo -en "a delete mytest\r\n" >&3
echo -en "a logout\r\n" >&3
#touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
cat smtp-temp.log
cat  smtp-temp.log >> imap-operations.log

cat imap-operations.log

c1=`grep "a OK FETCH completed"   smtp-temp.log|wc -l`
c2=`grep "a OK UID FETCH completed"   smtp-temp.log|wc -l`
echo $c1
echo $c2
if [ $c1 == 7 -a $c2 == 7 ];then
echo -ne   "\033[32m ###################### coverage test success  ###################### \033[0m\n" 
else
echo -ne   "\033[31m ###################### coverage test failed  ###################### \033[0m\n" 
fi
grep -i "FETCH (FIRSTLINE" imap-operations.log >>summary.log
#cat smtp-temp.log
#cat smtp-temp.log >> summary.log

#clear current messages again
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

rm -rf  smtp-temp.log
#rm -rf  smtp-temp.log