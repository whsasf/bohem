#!/bin/bash
lofile=imap-operations.log
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
subject1=testemail-mixd-UTF-8-CRLF-7bit
subject2=testemail-mixd-UTF-8-CRLF-8bit
subject3=testemail-mixd-UTF-8-CRLF-base64
subject4=testemail-mixd-UTF-8-CRLF-quoted-printable
charsets=utf-8
count=1
mailfrom=xx2
rcptto=xx1
loginuser=xx1
deleteuser=xx1@openwave.com
FEPHost1=172.26.202.87
imailuser=imail2
mos=172.26.203.123:8081

#enable firstline
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXFIRSTLINE=true"\""
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/imboxmaint/clusterName=92xmc"\""  #for imboxmaint

#create 2 users:
curl -s -X PUT -d "cosId=default&password=p" "http://$mos/mxos/mailbox/v2/xx1@openwave.com/" |jq .
curl -s -X PUT -d "cosId=default&password=p" "http://$mos/mxos/mailbox/v2/xx2@openwave.com/" |jq .

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

#sending messages
for ((i=1;i<=$count;i++ ))
do
  exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:$mailfrom\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3
  echo -en "DATA\r\n" >&3
  ##echo -en "Subject: testmessage$i-ASCII-CRLF\r\n" >&3
  echo -en "subject:$subject1\r\n" >&3
  echo -en "MIME-Version: 1.0\r\n" >&3
  echo -en "Content-Type: text/plain; charset=$charsets\r\n" >&3
  echo -en "Content-Transfer-Encoding: 7bit\r\n" >&3
  echo -en "`cat message$i-7bit.txt`\r\n" >&3
  echo -en ".\r\n" >&3
  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	echo  -e  "\n\n sending message$i:"
	echo -e "\n"
	#cat smtp-temp.log
	echo  -e  "\n\n\ sending message$i:" >>smtp-operations.log
	echo -e "\n" >> smtp-operations.log
	echo -e "\n"
  cat smtp-temp.log >>smtp-operations.log
	exec 3>&-
done

echo "(1)++++++++++++++++++initial state++++++++++++++++++++++++++++++++++++++++++++++++"
#fetching messages
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >summary.log
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
#cat imap-temp.log
cat imap-temp.log >>summary.log
rm -rf  imap-temp.log
#rm -rf  smtp-temp.log



#get target content (firstline data) from output
cat summary.log |grep -a   "FETCH (FIRSTLINE ("  |grep -av UID  >fetch-target.txt 
unix2dos  fetch-target.txt  #LF to CRLF

diff  fetch-target.txt  fetch-template.txt >diff-temp.log


if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 1-1 FETCH Test failed  ###################### \033[0m\n" 
      cat  diff-temp.log
      #echo -ne   "\033[31m ###################### 1-1 FETCH Test failed  ###################### \033[0m\n">> ../all-summary.log
      cat  diff-temp.log >>all-summary.log
  else
    
      echo -ne   "\033[32m ###################### 1-1 FETCH Test success ######################\033[0m\n" 
      #echo -ne   "\033[32m ###################### 1-1 FETCH Test success ######################\033[0m\n"  >> ../all-summary.log
fi


#get uid-fetch content fron outcome 
cat summary.log |grep -a  "FETCH (FIRSTLINE ("  |grep -a  UID  >uidfetch-target-temp.txt 
awk -F " UID" '{print $1}'  uidfetch-target-temp.txt >uidfetch-target.txt

unix2dos  uidfetch-target.txt    #LF to CRLF
          
diff  uidfetch-target.txt  uidfetch-template.txt >diff-temp.log


if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 1-2 UID FETCH Test failed  ################## \033[0m\n\n" 
      cat  diff-temp.log
      #echo -ne   "\033[31m ###################### 1-2 UID FETCH Test failed  ################## \033[0m\n\n" >>../all-summary.log 
      cat  diff-temp.log >> ../all-summary.log

  else
    
      echo -ne   "\033[32m ###################### 1-2 UID FETCH Test success ##################\033[0m\n\n" 
      #echo -ne   "\033[32m ###################### 1-2 UID FETCH Test success ##################\033[0m\n\n" >>../all-summary.log
fi


#(2)disable firstline
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXFIRSTLINE=false"\""

#(3)Send message again

for ((i=1;i<=$count;i++ ))
do
  exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:$mailfrom\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3
  echo -en "DATA\r\n" >&3
  ##echo -en "Subject: testmessage$i-ASCII-CRLF\r\n" >&3
  echo -en "subject:$subject1\r\n" >&3
  echo -en "MIME-Version: 1.0\r\n" >&3
  echo -en "Content-Type: text/plain; charset=$charsets\r\n" >&3
  echo -en "Content-Transfer-Encoding: 7bit\r\n" >&3
  echo -en "`cat message$i-7bit.txt`\r\n" >&3
  echo -en ".\r\n" >&3
  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	echo  -e  "\n\n sending message$i:"
	echo -e "\n"
	#cat smtp-temp.log
	echo  -e  "\n\n\ sending message$i:" >>smtp-operations.log
	echo -e "\n" >> smtp-operations.log
	echo -e "\n"
  cat smtp-temp.log >>smtp-operations.log
	exec 3>&-
done

#(4)enable firstline
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXFIRSTLINE=true"\""
echo "(2)++++++++++++++++++State after append new message +++++++++++++++++++++++++++++++++++++++++++++++"
#(5)fetch firstline

#fetching messages
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!fetching first line data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
# run imboxmaint
ssh root@${IMAPHost} "su - ${user} -c \"imboxmaint -s   $deleteuser\""
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
#touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#grep -i FETCH imap-temp.log
cat imap-temp.log
cat imap-temp.log >summary.log
rm -rf  imap-temp.log
#rm -rf  smtp-temp.log

#(6) judge firstiline (the second should be empty)
#get target content (firstline data) from output
cat summary.log |grep -a   "FETCH (FIRSTLINE ("  |grep -av UID  >fetch-target2.txt 
unix2dos  fetch-target2.txt  #LF to CRLF

diff  fetch-target2.txt  fetch-template2.txt >diff-temp.log


if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 1-1 FETCH Test failed  ###################### \033[0m\n" 
      cat  diff-temp.log
      #echo -ne   "\033[31m ###################### 1-1 FETCH Test failed  ###################### \033[0m\n">> ../all-summary.log
      cat  diff-temp.log >>all-summary.log
  else
    
      echo -ne   "\033[32m ###################### 1-1 FETCH Test success ######################\033[0m\n" 
      #echo -ne   "\033[32m ###################### 1-1 FETCH Test success ######################\033[0m\n"  >> ../all-summary.log
fi


#get uid-fetch content fron outcome 
cat summary.log |grep -a  "FETCH (FIRSTLINE ("  |grep -a  UID  >uidfetch-target-temp.txt 
awk -F " UID" '{print $1}'  uidfetch-target-temp.txt >uidfetch-target2.txt

unix2dos  uidfetch-target2.txt    #LF to CRLF
          
diff  uidfetch-target2.txt  uidfetch-template2.txt >diff-temp.log
echo "(3)++++++++++++++++++State after imboxmaint++++++++++++++++++++++++++++++++++++++++++++++++"

if [ -s diff-temp.log ]; then   #not empty
      echo -ne   "\033[31m ###################### 1-2 UID FETCH Test failed  ################## \033[0m\n\n" 
      cat  diff-temp.log
      #echo -ne   "\033[31m ###################### 1-2 UID FETCH Test failed  ################## \033[0m\n\n" >>../all-summary.log 
      cat  diff-temp.log >> ../all-summary.log

  else
    
      echo -ne   "\033[32m ###################### 1-2 UID FETCH Test success ##################\033[0m\n\n" 
      #echo -ne   "\033[32m ###################### 1-2 UID FETCH Test success ##################\033[0m\n\n" >>../all-summary.log
fi



#(9)disable firstline
#ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXFIRSTLINE=false"\""

#(10)delete 2 users:
#delete 2 users:
curl -s -X DELETE  "http://$mos/mxos/mailbox/v2/xx1@openwave.com/" |jq .
curl -s -X DELETE  "http://$mos/mxos/mailbox/v2/xx2@openwave.com/" |jq .
rm -rf  diff-temp.log
rm -rf  target-temp.txt
rm -rf uidfetch-target-temp.txt 