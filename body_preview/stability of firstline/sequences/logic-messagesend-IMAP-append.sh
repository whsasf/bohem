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


#clear target files
fetchtarget=fetch-target.txt
if [ -f "$fetchtarget" ]
then
	cat /dev/null >$fetchtarget
fi
uidfetchtarget=uidfetch-target.txt
if [ -f "$uidfetchtarget" ]
then
	cat /dev/null >$uidfetchtarget
fi

SMTPHost=172.26.202.87
SMTPPort=20025

IMAPHost=172.26.202.87
IMAPPort=20143

count=26
mailfrom=xx2
rcptto=xx1
loginuser=xx1
deleteuser=xx1@openwave.com

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

#sedning messages  
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3  

for (( i=20;i<=$count;i++ ))
do
	length=`wc -c message-append$i.txt |awk  '{print $1}'`
	echo -e "\n"
	#echo "Message$i body length = $length "
	#echo "Message$i is:"
	DATA=`cat message-append$i.txt`
  #echo -e "$DATA"
 	echo -en "a append inbox {$length}\r\n" >&3
	echo -en "$DATA\r\n" >&3
done
echo -en "a logout\r\n" >&3
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"


#fetching messages
#method-1:
#login,select inbox,fetch firstline ,uid fetch firstline;shold work
echo "---------1-login,select inbox,fetch firstline ,uid fetch firstline;shold work--------------------"
echo -e "\033[32m\n11111111111111111111fetching first line data the 1 time11111111111111111111\033[0m\n"
echo -e "\033[32m\n11111111111111111111fetching first line data the 1 time11111111111111111111\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 



#method-2:
#login,select inbox,fetch，fetch firstline ,uid fetch firstline;shold work
echo "---------2-login,select inbox,fetch,fetch firstline ,uid fetch firstline;shold work--------------------"
echo -e "\033[32m\n22222222222222222222fetching first line data the 2 time22222222222222222222\033[0m\n"
echo -e "\033[32m\n22222222222222222222fetching first line data the 2 time22222222222222222222\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 

#method-3:
#login,select inbox,append,fetch，fetch firstline ,uid fetch firstline;shold work
echo "---------3-login,select inbox,append,fetch,fetch firstline ,uid fetch firstline;shold work--------------------"
echo -e "\033[32m\n33333333333333333333fetching first line data the 3 time33333333333333333333\033[0m\n"
echo -e "\033[32m\n33333333333333333333fetching first line data the 3 time33333333333333333333\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {9}\r\n" >&3
echo -en "xxxxxxxxx\r\n" >&3
echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 



#method-4:
#login,select inbox,append，fetch firstline ,uid fetch firstline;shold work
echo "---------4-login,select inbox,append,fetch,fetch firstline ,uid fetch firstline;shold work--------------------"
echo -e "\033[32m\n44444444444444444444fetching first line data the 4 time44444444444444444444\033[0m\n"
echo -e "\033[32m\n44444444444444444444fetching first line data the 4 time44444444444444444444\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {9}\r\n" >&3
echo -en "xxxxxxxxx\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 


#method-5:
#login,fetch firstline ,uid fetch firstline;shold fail
echo "---------5-login,fetch,fetch firstline ,uid fetch firstline;shold fail--------------------"
echo -e "\033[32m\n55555555555555555555 fetching first line data the 5 time55555555555555555555\033[0m\n"
echo -e "\033[32m\n55555555555555555555 fetching first line data the 5 time55555555555555555555\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
#echo -en "a select inbox\r\n" >&3
#echo -en "a append inbox {9}\r\n" >&3
#echo -en "xxxxxxxxx\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 


#method-6:
#login,select inbox,append，fetch firstline ,uid fetch firstline;shold fail
echo "---------6-login,select inbox,fetch exceed,fetch firstline exceed ,uid fetch firstline exceed;shold fail--------------------"
echo -e "\033[32m\n66666666666666666666fetching first line data the 6 time66666666666666666666\033[0m\n"
echo -e "\033[32m\n66666666666666666666fetching first line data the 6 time66666666666666666666\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a append inbox {9}\r\n" >&3
#echo -en "xxxxxxxxx\r\n" >&3
echo -en "a fetch 1:100 rfc822\r\n" >&3
echo -en "a fetch 1:100 firstline\r\n" >&3
echo -en "a uid fetch 1:100 firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 



#method-7:
#login,select inbox,append，fetch firstline ,uid fetch firstline;shold fail
echo "----------login,select inbox,fetch exceed,fetch firstline exceed ,uid fetch firstline exceed;shold fail--------------------"
echo -e "\033[32m\n77777777777777777777fetching first line data the 7 time77777777777777777777\033[0m\n"
echo -e "\033[32m\n77777777777777777777fetching first line data the 7 time77777777777777777777\033[0m\n" >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a append inbox {9}\r\n" >&3
#echo -en "xxxxxxxxx\r\n" >&3
echo -en "a fetch 10:100 rfc822\r\n" >&3
echo -en "a fetch 20:100 firstline\r\n" >&3
echo -en "a uid fetch 20:100 firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log 





rm -rf  imap-temp.log
#rm -rf  smtp-temp.log



rm -rf  diff-temp.log
rm -rf  target-temp.txt
rm -rf uidfetch-target-temp.txt 
