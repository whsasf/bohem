#!/bin/bash


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

SMTPHost=172.26.202.87
SMTPPort=20025

IMAPHost=172.26.202.87
IMAPPort=20143

mailfrom=xx2
rcptto=xx1
loginuser=xx1
deleteuser=xx1@openwave.com

user=imail2
#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"


for ((i=1;i<=$count;i++ ))
do
  #create random messages ,compose messages ,append message
	temp=`shuf -n15  /usr/share/dict/words`
	cat header.txt  > message$i.txt
  echo $temp >>message$i.txt
  
  length=`wc -c message$i.txt |awk  '{print $1}'`
  
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a select inbox\r\n" >&3
	echo -en "a append inbox {$length}\r\n" >&3
	echo -en "`cat message$i.txt`\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 >imap-temp.log
	exec 3>&-
	cat imap-temp.log
done

  #Fetch mesages
  
  exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $loginuser p\r\n" >&3
	echo -en "a select inbox\r\n" >&3
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
          echo "the $i firstline data exist in message$i.txt" >>summary.log
         else
           echo "the $i firstline data not exist in message$i.txt" >>summary.log
         fi
         let i++ 
done < firstline.data

cat summary.log
echo -e "\n\n\n"
	#clear current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

rm -rf  imap-temp.log
#rm -rf  xx.txt