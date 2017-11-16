#!/bin/bash
#use xx1@openave.com  p  as test uer

deleteuser=xx1@openwave.com
IMAPHost=10.49.58.118
IMAPPort=20143
loginuser=xx1
mailfrom=xx2
rcptto=xx1
SMTPHost=10.49.58.118
SMTPPort=20025
user=imail2
FEPHost1=10.49.58.118
imailuser=imail2
moshost=10.49.58.120:8081


#(0)add some keys and restart imap srevers:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=true";imconfcontrol -install -key "/*/common/notificationEventData=modseq"\""

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
echo "3333333333333333333333333333333333"
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
echo -en "a enable condstore\r\n" >&3
echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* firstline\r\n" >&3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log

#(5-1) check HIGHESTMODSEQ:
Hc=`grep "HIGHESTMODSEQ" imap-temp.log|wc -l`
if [ $Hc -eq 1 ];then
	echo -e "\033[32m can find HIGHESTMODSEQ in response,great!!!!!!! \033[0m\n"
		echo -e "\033[32m can find HIGHESTMODSEQ in response,great!!!!!!! \033[0m\n" > summary.log
else
	echo -e "\033[31m can not find HIGHESTMODSEQ in response,great!!!!!!! \033[0m\n"
		echo -e "\033[31m can not  find HIGHESTMODSEQ in response,great!!!!!!! \033[0m\n" > summary.log
fi
#(5-2)get initial modseq number:
modseq1=`cat imap-temp.log |grep MODSEQ|head -2|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq2=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
cat  imap-temp.log
echo "#############the initial mpdseq numbers are:" 
echo "modseq1=$modseq1"
echo "modseq2=$modseq2"


#echo "#############the initial mpdseq numbers are:"  >>summary.log
#echo "modseq1=$modseq1" >>summary.log
#echo "modseq2=$modseq2" >>summary.log

#(6)Now 1th some imap operations to change ,the modseq number should update accordingly ,and judge
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1 (flags)\r\n" >&3
echo -en "a Store 1 +flags.silent (\Answered)\r\n" >&3
sleep 3
echo -en "a fetch 1 (flags)\r\n" >&3
sleep 3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

let temp=$modseq1+2
modseq1=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`

#echo $temp
#echo $modseq1

if [ "$modseq1" -eq "$temp" ];then
	echo -e "\033[32m After operation 1 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation 1 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation 1 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation 1 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi

#(7)now, do operation2:  and judge

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 2 (flags)\r\n" >&3
echo -en "a Store 2 +flags.silent (\Answered)\r\n" >&3
sleep 3
echo -en "a fetch 2 (flags)\r\n" >&3
sleep 3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

let temp=$modseq2+2
modseq2=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
#echo $temp
#echo $modseq2

if [ $modseq2 -eq $temp ];then
	echo -e "\033[32m After operation 2 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation 2 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation 2 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation 2 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
fi


#(8)now, do operation3:  and judge

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1 (flags)\r\n" >&3
echo -en "a fetch 2 (flags)\r\n" >&3
echo -en "a Store 1 +flags.silent (\\Seen)\r\n" >&3
sleep 3
echo -en "a Store 1 +flags.silent (\\Deleted)\r\n" >&3
sleep 3
echo -en "a fetch 1 (flags)\r\n" >&3
echo -en "a Store 2 +flags.silent (\\Seen)\r\n" >&3
sleep 3
echo -en "a Store 2 +flags.silent (\\Deleted)\r\n" >&3
sleep 3
echo -en "a fetch 2 (flags)\r\n" >&3
sleep 3
echo -en "a fetch 1:* modseq\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

let temp1=$modseq1+3
let temp2=$modseq2+4
modseq1=`cat imap-temp.log |grep MODSEQ|head -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`
modseq2=`cat imap-temp.log |grep MODSEQ|tail -1|awk -F "(" '{print $3}'|awk -F ")" '{print $1}'`

#echo $temp1
#echo $temp2
#echo $modseq1
#echo $modseq2

if [ $modseq2 -eq $temp2 -a $modseq1 -eq $temp1 ];then
	echo -e "\033[32m After operation 3 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n"
	echo -e "\033[32m After operation 3 finish,modseq number increased accordingly,great!!!!!!! \033[0m\n" >>summary.log
else
  echo -e "\033[31m After operation 3 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" 
  echo -e "\033[31m After operation 3 finish,modseq number increased not accordingly,sad!!!!!!! \033[0m\n" >>summary.log
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