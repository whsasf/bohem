#!/bin/bash
#use xx1@openave.com  p  as test uer

deleteuser=xx1@openwave.com
IMAPHost=10.37.2.124
IMAPPort=20143
loginuser=xx1
mailfrom=xx2
rcptto=xx1
SMTPHost=10.37.2.124
SMTPPort=20025
user=imail2
FEPHost1=10.37.2.124
imailuser=imail2
moshost=10.37.2.125:8081


#(0)add some keys and restart imap srevers:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=true";imconfcontrol -install -key "/*/common/notificationEventData=modseq"\""
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/imboxmaint/clusterName=92xmc"\""  #for imboxmaint

#restart imapserv:
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""

# create 2 testusers:
curl -s -X PUT -d "cosId=default&password=p" "http://"$moshost"/mxos/mailbox/v2/"$mailfrom"@openwave.com" |jq .
curl -s -X PUT -d "cosId=default&password=p" "http://"$moshost"/mxos/mailbox/v2/"$rcptto"@openwave.com" |jq .
#(1) cleat current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

#(2)append one message to inbox
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {20}\r\n" >&3
echo -en "abdhro9365wbd84mgedu\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
#echo "3333333333333333333333333333333333"
#(3)smtp one message to inbox
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$mailfrom\r\n" >&3
echo -en "RCPT TO:$rcptto\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "Subject:test message\r\n" >&3
echo -en "\r\n" >&3
echo -en "我们都是中国人，how about you!!!??\r\n" >&3
echo -en ".\r\n" >&3
echo -en "QUIT\r\n" >&3
touch smtp-temp.log
cat <&3 > smtp-temp.log
exec 3>&-

#(4)fetch modseq
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

#(5)get initial modseq number:
modseq1=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq2=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`

echo "#############the initial mpdseq numbers are:"
echo "modseq1=$modseq1"
echo "modseq2=$modseq2"

echo "#############(1)the initial mpdseq numbers are:" >summary.log
echo "modseq1=$modseq1" >>summary.log
echo "modseq2=$modseq2" >>summary.log

#(6)now disable condstore and restart servers
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=false"\""
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
#(7) append one more messages
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {20}\r\n" >&3
echo -en "abdhro9365wbd84mgedu\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
#echo "3333333333333333333333333333333333"
#(8) send one more messages
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$mailfrom\r\n" >&3
echo -en "RCPT TO:$rcptto\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "Subject:test message\r\n" >&3
echo -en "\r\n" >&3
echo -en "我们都是中国人，how about you!!!??\r\n" >&3
echo -en ".\r\n" >&3
echo -en "QUIT\r\n" >&3
touch smtp-temp.log
cat <&3 > smtp-temp.log
exec 3>&-

#(9)now enable condstore and restart servers
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=true"\""
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""

#(10)now fetch modseq
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a  fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log

#(11)judge modseq number:
modseq11=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq22=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq33=`cat imap-temp.log |grep MODSEQ|tail -2|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq44=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`

echo "#############the cueeent mpdseq numbers are:"
echo "modseq11=$modseq11"
echo "modseq22=$modseq22"
echo "modseq33=$modseq33"
echo "modseq44=$modseq44"

echo "#############(2)After deliver 2 new messages,before imboxmaint ,the cueeent mpdseq numbers are:" >>summary.log
echo "modseq11=$modseq11" >>summary.log
echo "modseq22=$modseq22" >>summary.log
echo "modseq33=$modseq33" >>summary.log
echo "modseq44=$modseq44" >>summary.log

if [ "$modseq33" -eq 0 -a  "$modseq33" -eq 0 -a  "$modseq11" -eq "$modseq1" -a  "$modseq22" -eq "$modseq2" ] ;then
   echo -e "\033[32m After deliver 2 new messages,before imboxmaint,modseq number increased accordingly,great!!!!!!! \033[0m\n"
   echo -e "\033[32m After deliver 2 new messages,before imboxmaint,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log

else

 echo -e "\033[31m After deliver 2 new messages,before imboxmaint,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After deliver 2 new messages,before imboxmaint,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi

#(12) imboxmaint for mailbox
# run imboxmaint
ssh root@${IMAPHost} "su - ${user} -c \"imboxmaint -s   $deleteuser\""
sleep 20
# (13)now fetch again
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a uid fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

#(14) judge again,check if modseq number becomes imap UIDs.

modseq111=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq222=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq333=`cat imap-temp.log |grep MODSEQ|tail -2|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq444=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`


uid1=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $2}'|awk '{print $2}'`
uid2=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $2}'|awk '{print $2}'`
uid3=`cat imap-temp.log |grep MODSEQ|tail -2 |head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $2}'|awk '{print $2}'`
uid4=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $2}'|awk '{print $2}'`


#let temp11=$modseq111+2
#let temp22=$modseq222+2

echo "after imboxmaint.current modseq unmbers are:"

echo "modseq111=$modseq111"
echo "modseq222=$modseq222"
echo "modseq333=$modseq333"
echo "modseq444=$modseq444"
echo "after imboxmaint.current uid unmbers are:"
echo "uid1=$uid1"
echo "uid2=$uid2"
echo "uid3=$uid3"
echo "uid4=$uid4"

echo "after imboxmaint.current modseq unmbers are:" >>summary.log

echo "modseq111=$modseq111"  >>summary.log
echo "modseq222=$modseq222"  >>summary.log
echo "modseq333=$modseq333"  >>summary.log
echo "modseq444=$modseq444"  >>summary.log

echo "after imboxmaint.current uid unmbers are:" >>summary.log
echo "uid1=$uid1" >>summary.log
echo "uid2=$uid2" >>summary.log
echo "uid3=$uid3" >>summary.log
echo "uid4=$uid4" >>summary.log

if [ "$modseq333" -eq "$uid3" -a "$modseq444" -eq "$uid4" -a "$modseq111" -eq "$uid1" -a "$modseq222" -eq "$uid2" ] ;then

   echo -e "\033[32m After imboxmaint,modseq number using imap UID numbsers,great!!!!!!! \033[0m\n"
   echo -e "\033[32m After imboxmaint,modseq number using imap UID numbsers,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After imboxmaint,modseq number not using imap UID numbsers,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After imboxmaint,modseq number not using imap UID numbsers,sad!!!!!!! \033[0m\n" >summary.log

fi


#(15)Now 1th some imap operations to change ,the modseq number should update accordingly ,and judge
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
sleep 3
echo -en "a login $loginuser p\r\n" >&3
#echo -en "a enable condstore\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a Store 1 +flags.silent (\Answered)\r\n" >&3
sleep 5
echo -en "a fetch 1:* modseq\r\n" >&3
sleep 2
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
#cat imap-temp.log  >>summary.log


let temp=$modseq111+4
modseq1111=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq2222=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq3333=`cat imap-temp.log |grep MODSEQ|tail -2|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq4444=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
echo "temp=$temp"
#echo $modseq1

echo "After operation to message1 (total 4),modseq numbers are:"
echo "modseq1111=$modseq1111"
echo "modseq2222=$modseq2222"
echo "modseq3333=$modseq3333"
echo "modseq4444=$modseq4444"

echo "After operation to message1 (total 4),modseq numbers are:" >>summary.log
echo "modseq1111=$modseq1111"  >>summary.log
echo "modseq2222=$modseq2222"  >>summary.log
echo "modseq3333=$modseq3333"  >>summary.log
echo "modseq4444=$modseq4444"  >>summary.log


if [ "$modseq1111" -eq "$temp" ];then
	echo -e "\033[32m After operation to message1,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation to message1,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation to message1,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation to message1,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi

#(7)now, do operation2:  and judge

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a Store 3 +flags.silent (\Answered)\r\n" >&3
sleep 3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
#cat imap-temp.log  >>summary.log

let temp=$modseq3333+3

modseq33333=`cat imap-temp.log |grep MODSEQ|tail -2|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq11111=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq22222=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq44444=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
#echo $temp
#echo $modseq3333

echo "after operation to message2, the modseq numbers are:"
echo "modseq11111=$modseq11111"
echo "modseq22222=$modseq22222"
echo "modseq33333=$modseq33333"
echo "modseq44444=$modseq44444"

echo "after operation to message2, the modseq numbers are:"   >>summary.log 

echo "modseq11111=$modseq11111"  >>summary.log 
echo "modseq22222=$modseq22222"  >>summary.log 
echo "modseq33333=$modseq33333"  >>summary.log 
echo "modseq44444=$modseq44444"  >>summary.log 


if [ $modseq33333 -eq $temp ];then
	echo -e "\033[32m After operation to message2,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation to message2,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation to message2,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation to message2,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi


#(8)now, do operation3:  and judge

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a Store 2 +flags.silent (\\Seen)\r\n" >&3
echo -en "a Store 2 +flags.silent (\\Deleted)\r\n" >&3
echo -en "a Store 4 +flags.silent (\\Seen)\r\n" >&3
echo -en "a Store 4 +flags.silent (\\Deleted)\r\n" >&3
sleep 3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log

let temp1=$modseq22222+6
let temp2=$modseq44444+6
modseq222222=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq444444=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq333333=`cat imap-temp.log |grep MODSEQ|tail -2|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq111111=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
#echo $temp1
#echo $temp2
#echo $modseq22222
#echo $modseq44444

echo "after 2 operations to message 2 and message 4.the modseq numbers are:"
echo "modseq111111=$modseq111111"
echo "modseq222222=$modseq222222"
echo "modseq333333=$modseq333333"
echo "modseq444444=$modseq444444"

echo "after 2 operations to message 2 and message 4.the modseq numbers are:" >>summary.log
echo "modseq111111=$modseq111111" >>summary.log
echo "modseq222222=$modseq222222" >>summary.log
echo "modseq333333=$modseq333333" >>summary.log
echo "modseq444444=$modseq444444" >>summary.log



if [ "$modseq222222" -eq "$temp1" -a "$modseq444444" -eq "$temp2" ];then
	echo -e "\033[32m After operations to message2 and message4,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation to message2 and message4,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation to message2 and message4,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation to message2 and message4,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi



#()revert  the  keys and restart imap srevers:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=false";imconfcontrol -install -key "/*/common/notificationEventData"\""

#restart imapserv:
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""


#delete temp files:
rm -rf imap-temp.log
rm -rf smtp-temp.log
# cleat current messages
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

# delete 2 testusers:
curl -s -X DELETE   "http://"$moshost"/mxos/mailbox/v2/"$mailfrom"@openwave.com" |jq .
curl -s -X DELETE   "http://"$moshost"/mxos/mailbox/v2/"$rcptto"@openwave.com" |jq .

echo "#################showing summary.log############################"
echo 
cat summary.log