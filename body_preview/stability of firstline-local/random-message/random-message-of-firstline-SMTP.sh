#prepared for firstline testing,
#you can run it after creating users xx1@openwave.com and xx2@openwave.com, or modify the shell to meet your env
#and also add this key:                                                                                                                                                
#/*/common/enableXFIRSTLINE: [true]                                                                                                                  


#!/bin/bash

#numbers of emails you want
count=200


sumfile=summary.log
if [ -f "$sumfile" ]
then
	cat /dev/null >$sumfile
fi


xxtxt=xx.txt
if [ -f "$xxtxt" ]
then
	cat /dev/null >$xxtxt
fi

SMTPHost=10.37.2.124
SMTPPort=20025

IMAPHost=10.37.2.124
IMAPPort=20143

mailfrom=xx2
rcptto=xx1
loginuser=xx1
deleteuser=xx1@openwave.com

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"


#create random messages ,compose messages ,append message
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
for (( i=1;i<=$count;i++ ))
do
  #create random messages ,compose messages ,append message
  # "-n"  number of words you want to combine to a sentence
	temp=`shuf -n15  /usr/share/dict/words`
	cat header.txt  > message$i.txt
	#echo "#################$i################################"
  #cat message$i.txt
	#echo "#################################################"

  echo $temp >>message$i.txt
  
  #exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:$mailfrom\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3
  echo -en "DATA\r\n" >&3
	echo -en "`cat message$i.txt`\r\n" >&3
  echo -en ".\r\n" >&3
#  echo -en "QUIT\r\n" >&3
#	cat <&3 > smtp-temp.log
#	exec 3>&-
#	cat smtp-temp.log
done
echo -en "QUIT\r\n" >&3
cat <&3 > smtp-temp.log
exec 3>&-
cat smtp-temp.log


#Fetch mesages

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1:* rfc822\r\n" >&3
echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a logout\r\n" >&3
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
grep "FETCH (FIRSTLINE"  imap-temp.log >xx.txt

cat xx.txt |awk -F '"'  '{print $2}'  >firstline.data 

#compare
i=1
echo -e "\n\nbegin compare:\n\n" >summary.log
#cat /dev/null>message1.txt
while read LINE
do
      echo "the $i line data is:($LINE)"
      grep "$LINE" message$i.txt >/dev/null
       if [ $? -eq 0 ]; then
        #echo "the $i firstline data exist in message$i.txt" >>summary.log
        echo -ne "\033[32m ################# the $i firstline data exist in message$i.txt #####\033[0m\n" >>summary.log
       else
         #echo "the $i firstline data not exist in message$i.txt" >>summary.log
          echo -ne "\033[31m ################# the $i firstline data not exist in message$i.txt #####\033[0m\n" >>summary.log
       fi
       let i++ 
done < firstline.data

cat summary.log
echo -e "\n\n\n"
	#clear current messages
#ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
#echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

rm -rf  smtp-temp.log
rm -rf  imap-temp.log
#rm -rf  xx.txt