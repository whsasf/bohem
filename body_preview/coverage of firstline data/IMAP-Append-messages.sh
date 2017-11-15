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


#create 2 folders  :  /mytest   and /mytest/xx

  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a list "" *\r\n" >&3
  echo -en "a create mytest\r\n" >&3
	echo -en "a create mytest/xx\r\n" >&3
	echo -en "a list "" *\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat imap-temp.log
  cat  imap-temp.log > imap-operations.log



#appending messages

	length=`wc -c mixed-UTF8-language-messagebody-IMAP.txt |awk  '{print $1}'`
	#echo -e "\n"
	#echo "Message$i body length = $length "
	#echo "Message$i is:"
	DATA=`cat mixed-UTF8-language-messagebody-IMAP.txt`
  #echo -e "$DATA"
  
  
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in inbox!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in inbox!!!!!!!!!!!!!!!!!!!!!!!!!!!!">imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append inbox {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
  cat imap-temp.log


	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Drafts!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Drafts!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append Drafts {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
   cat imap-temp.log

echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in SentMail!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in SentMail!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append SentMail {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
  cat imap-temp.log
  
  echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Spam!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Spam!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append Spam {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
  cat imap-temp.log
  
   echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Trash!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in Trash!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append Trash {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
  cat imap-temp.log

   echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in mytest!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in mytest!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append mytest {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
   cat imap-temp.log
   
   
   echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in mytest/xx!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!Appending message in mytest/xx!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a append mytest/xx {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
	echo -en "a logout\r\n" >&3
	#touch imap-temp.log
	cat <&3 >imap-temp.log
	exec 3>&-
  cat  imap-temp.log >> imap-operations.log
  cat imap-temp.log
 





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
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
cat  imap-temp.log >> imap-operations.log

cat imap-operations.log

grep -i "FETCH (FIRSTLINE" imap-operations.log >>summary.log
#cat imap-temp.log
#cat imap-temp.log >> summary.log 

c1=`grep "a OK FETCH completed"   imap-operations.log|wc -l`
c2=`grep "a OK UID FETCH completed"   imap-operations.log|wc -l`
echo $c1
echo $c2
if [ $c1 == 7 -a $c2 == 7 ];then
echo -ne   "\033[32m ###################### coverage test success  ###################### \033[0m\n" 
else
echo -ne   "\033[31m ###################### coverage test failed  ###################### \033[0m\n" 
fi
#clear current messages again
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

rm -rf  imap-temp.log
#rm -rf  smtp-temp.log