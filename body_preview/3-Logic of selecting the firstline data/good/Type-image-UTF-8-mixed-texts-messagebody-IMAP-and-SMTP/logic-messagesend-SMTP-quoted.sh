#!/bin/bash
lofile=smtp-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
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
     echo -en "`cat pics_with_UTF-8_mixed-messagebody-SMTP-quoted.txt`\r\n" >&3
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
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >>summary.log
rm -rf  imap-temp.log
rm -rf  smtp-temp.log

#get target content (firstline data) from output
cat summary.log |grep -a  "FETCH (FIRSTLINE ("  |grep -av UID  >fetch-target.txt 
unix2dos  fetch-target.txt  #LF to CRLF

diff fetch-target.txt  fetch-template-quoted.txt >diff-temp.log


if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 2-1 FETCH Test failed  ###################### \033[0m\n" 
      cat  diff-temp.log
      echo -ne   "\033[31m ###################### 2-1 FETCH Test failed  ###################### \033[0m\n">> ../all-summary.log
      cat  diff-temp.log >>all-summary.log
  else
    
      echo -ne   "\033[32m ###################### 2-1 FETCH Test success ######################\033[0m\n" 
      echo -ne   "\033[32m ###################### 2-1 FETCH Test success ######################\033[0m\n"  >> ../all-summary.log
fi


#get uid-fetch content fron outcome 
cat summary.log |grep -a   "FETCH (FIRSTLINE ("  |grep -a UID  >uidfetch-target-temp.txt 
awk -F " UID" '{print $1}'  uidfetch-target-temp.txt >uidfetch-target.txt

unix2dos  uidfetch-target.txt    #LF to CRLF
          
diff uidfetch-target.txt  uidfetch-template-quoted.txt >diff-temp.log


if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 2-2 UID FETCH Test failed  ################## \033[0m\n\n" 
      cat  diff-temp.log
      echo -ne   "\033[31m ###################### 2-2 UID FETCH Test failed  ################## \033[0m\n\n" >>../all-summary.log 
      cat  diff-temp.log >> ../all-summary.log

  else
    
      echo -ne   "\033[32m ###################### 2-2 UID FETCH Test success ##################\033[0m\n\n" 
      echo -ne   "\033[32m ###################### 2-2 UID FETCH Test success ##################\033[0m\n\n" >>../all-summary.log
fi

rm -rf  diff-temp.log
rm -rf  target-temp.txt
rm -rf uidfetch-target-temp.txt 