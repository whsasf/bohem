#!/bin/bash
#use ramdom accounts
u1=`echo $RANDOM`
u2=`echo $RANDOM`
u3=`echo $RANDOM`
deleteuser=$u1@openwave.com
IMAPHost=10.37.2.124
IMAPPort=20143
loginuser1=$u1
loginuser2=$u2
loginuser3=$u3
mailfrom1=$u1
rcptto1=$u1
mailfrom2=$u2
rcptto2=$u2
mailfrom3=$u3
rcptto3=$u3
SMTPHost=10.37.2.124
SMTPPort=20025
user=imail2
FEPHost2=10.37.2.124
imailuser=imail2
moshost="10.37.2.125:8081"

echo $u1@openwave.com
echo $u2@openwave.com
echo $u3@openwave.com


#reaplce current messages test
cp 1-testmessage2to1.txt    1-testmessage2to1-SMTP.ttt
cp 2-testmessage1re2.txt    2-testmessage1re2-SMTP.ttt
cp 3-testmessage2re1.txt    3-testmessage2re1-SMTP.ttt
cp 4-testmessage3to2.txt    4-testmessage3to2-SMTP.ttt
cp 5-testmessage2re3.txt    5-testmessage2re3-SMTP.ttt
cp 6-testmessage3re2.txt    6-testmessage3re2-SMTP.ttt
cp 7-testmessage1to3.txt    7-testmessage1to3-SMTP.ttt
cp 8-testmessage3re1.txt    8-testmessage3re1-SMTP.ttt
cp 9-testmessage1re3.txt    9-testmessage1re3-SMTP.ttt
sed -i 's/xx1/'$u1'/g'  *testmessage*-SMTP.ttt
sed -i 's/xx2/'$u2'/g'  *testmessage*-SMTP.ttt
sed -i 's/xx3/'$u3'/g'  *testmessage*-SMTP.ttt

#add some keys:

#ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=true";imconfcontrol -install -key "/*/common/enableXTHREAD=true";imconfcontrol -install -key "/*/common/enableXFIRSTLINE=true";imconfcontrol -install -key "/*/imapserv/recentParticipantListCount=50"\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXTHREAD=true";imconfcontrol -install -key "/*/common/enableXFIRSTLINE=true";imconfcontrol -install -key "/*/imapserv/recentParticipantListCount=50"\""
#restart
#ssh root@${FEPHost2} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
0
# create 3 testusers:
echo "creating $u1@openwave.com ..."
curl -s -X PUT -d "cosId=default&password=p" "http://$moshost/mxos/mailbox/v2/$u1@openwave.com" |jq .
echo "creating $u2@openwave.com ..."
curl -s -X PUT -d "cosId=default&password=p" "http://$moshost/mxos/mailbox/v2/$u2@openwave.com" |jq .
echo "creating $u3@openwave.com ..."
curl -s -X PUT -d "cosId=default&password=p" "http://$moshost/mxos/mailbox/v2/$u3@openwave.com" |jq .

#create conversations through SMTP
#1 conversation between u1 and u2
#(1)Send first message :sending from u2 to u1
DATA=`cat 1-testmessage2to1-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u2\r\n" >&3
echo -en "RCPT TO:$u1\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 1-testmessage2to1-SMTP.ttt`\r\n">&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message1 send failed  ##################\033[0m\n\n"
fi

echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(2)apprnd second message :sending from u1 to u2
DATA=`cat 2-testmessage1re2-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u1\r\n" >&3
echo -en "RCPT TO:$u2\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 2-testmessage1re2-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message2 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(3)apprnd third message :sending from u2 to u1
DATA=`cat 3-testmessage2re1-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u2\r\n" >&3
echo -en "RCPT TO:$u1\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 3-testmessage2re1-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message3 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"


#2 conversation between u2 and u3
#(1)send first message :sending from u3 to u2
DATA=`cat 4-testmessage3to2-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u3\r\n" >&3
echo -en "RCPT TO:$u2\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 4-testmessage3to2-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message1 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(2)send second message :sending from u2 to u3
DATA=`cat 5-testmessage2re3-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u2\r\n" >&3
echo -en "RCPT TO:$u3\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 5-testmessage2re3-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message2 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(3)send second message :sending from u3 to u2
DATA=`cat 6-testmessage3re2-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u3\r\n" >&3
echo -en "RCPT TO:$u2\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 6-testmessage3re2-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message3 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#3 conversation between u3 and u1
#(1)send first message :sending from u1 to u3
DATA=`cat 7-testmessage1to3-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u1\r\n" >&3
echo -en "RCPT TO:$u3\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 7-testmessage1to3-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message1 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(2)send second message :sending from u3 to u1
DATA=`cat 8-testmessage3re1-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u3\r\n" >&3
echo -en "RCPT TO:$u1\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 8-testmessage3re1-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message2 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#(3)send second message :sending from u1 to u3
DATA=`cat 9-testmessage1re3-SMTP.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Sending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$u1\r\n" >&3
echo -en "RCPT TO:$u3\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat 9-testmessage1re3-SMTP.ttt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
n=`grep "Message received"   smtp-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 send success ##################\033[0m\n\n"
else
echo -e "\033[31m###################### Message3 send failed  ##################\033[0m\n\n"
fi
echo "!!!!!!!!!!!!!!!!send finished!!!!!!!!!!!!!!!"

#fetch-XTHREAD
echo "#############################################################################################" >summary.log
echo "######################################SUMMARY################################################" >>summary.log
echo "#############################################################################################" >>summary.log
echo >>summary.log
echo >>summary.log
echo "running X-THREAD commands now :"   >>summary.log
echo >>summary.log
echo >>summary.log
#fetch u1
echo "1----for u1 ,there should have 4 messages total,all unseen,belongs to 3 conversions,each has 2,1,1 messages:"  >>summary.log
echo >>summary.log
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-fetching u1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#(1) X-THREAD  COMMAND
echo "(1)######X-THREAD  COMMAND###########"
echo "(1)######X-THREAD  COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser1 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
#echo -en "a fetch 1:* rfc822\r\n" >&3 
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
cf=`grep "X-THREAD" smtp-temp.log |wc -l`
echo "#####################################$cf########################################"
if [ $cf -eq 4 ];then
echo -e "\033[32m###################### X-THREAD for u1 successfully!! ##################\033[0m\n\n" 
echo -e "\033[32m###################### X-THREAD for u1 successfully!! ##################\033[0m\n\n"   >>summary.log
else
echo -e "\033[31m###################### X-THREAD for u1 failed!! ##################\033[0m\n\n" 
echo -e "\033[31m###################### X-THREAD for u1 failed!! ##################\033[0m\n\n"  >>summary.log
fi
#(2) X-THREAD LIST COMMAND
echo "(2)######X-THREAD LIST COMMAND###########"
echo "(2)######X-THREAD LIST COMMAND###########"  >>summary.log
target=`grep "X-THREAD" smtp-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -2|tail -1`
latuid=`grep "X-THREAD" smtp-temp.log |awk '{print $4}' |head -2|tail -1`
let tem=latuid-1
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser1 p\r\n" >&3

echo -en "a select inbox\r\n" >&3

#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a uid fetch 1:* rfc822\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep "X-THREAD" smtp-temp.log  >> summary.log
uid1=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
if [ $uid1 -eq $latuid  -a $uid2 -eq $tem ];then
	echo -e "\033[32m###################### X-THREAD LIST for u1 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD LIST for u1 successfully!! ##################\033[0m\n\n"  >>summary.log
else
  echo -e "\033[31m###################### X-THREAD LIST for u1 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD LIST for u1 failed!! ##################\033[0m\n\n"  >>summary.log
fi

#(3)X-THREAD store command
#(3-1)  X-THREAD store command
echo "(3)######X-THREAD STORE COMMAND###########"
echo "(3)######X-THREAD STORE COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser1 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3

echo -en "a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen"  >>summary.log
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep -i "flags"  smtp-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser1 p\r\n" >&3

echo -en "a select inbox\r\n" >&3

echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
newc=`grep "X-THREAD" smtp-temp.log|awk '{print $6}'|head -2|tail -1`
if [ $newc -eq 0 ];then
	echo -e "\033[32m###################### X-THREAD STORE for u1 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD STORE for u1 successfully!! ##################\033[0m\n\n"  >>summary.log
else
	echo -e "\033[31m###################### X-THREAD STORE for u1 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD STORE for u1 failed!! ##################\033[0m\n\n"  >>summary.log
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >>summary.log

#fetch u2
echo "2----for u2 ,there should have 4 messages total,all unseen,belongs to 3 conversions,each has 2,1,1 messages:"  >>summary.log
echo >>summary.log
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-fetching u2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#(1) X-THREAD  COMMAND
echo "(1)######X-THREAD  COMMAND###########"
echo "(1)######X-THREAD  COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser2 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
cf=`grep "X-THREAD" smtp-temp.log |wc -l`
if [ $cf -eq 4 ];then
echo -e "\033[32m###################### X-THREAD for u2 successfully!! ##################\033[0m\n\n" 
echo -e "\033[32m###################### X-THREAD for u2 successfully!! ##################\033[0m\n\n"   >>summary.log
else
echo -e "\033[31m###################### X-THREAD for u2 failed!! ##################\033[0m\n\n" 
echo -e "\033[31m###################### X-THREAD for u2 failed!! ##################\033[0m\n\n"  >>summary.log
fi
#(2) X-THREAD LIST COMMAND
echo "(2)######X-THREAD LIST COMMAND###########"
echo "(2)######X-THREAD LIST COMMAND###########"  >>summary.log
target=`grep "X-THREAD" smtp-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -1`
latuid=`grep "X-THREAD" smtp-temp.log |awk '{print $4}' |head -1`
let tem=latuid-1
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser2 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a uid fetch 1:* rfc822\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep "X-THREAD" smtp-temp.log  >> summary.log
uid1=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
if [ $uid1 -eq $latuid  -a $uid2 -eq $tem ];then
	echo -e "\033[32m###################### X-THREAD LIST for u2 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD LIST for u2 successfully!! ##################\033[0m\n\n"  >>summary.log
else
  echo -e "\033[31m###################### X-THREAD LIST for u2 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD LIST for u2 failed!! ##################\033[0m\n\n"  >>summary.log
fi

#(3)X-THREAD store command
#(3-1)  X-THREAD store command
echo "(3)######X-THREAD STORE COMMAND###########"
echo "(3)######X-THREAD STORE COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser2 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen"  >>summary.log
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep -i "flags"  smtp-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser2 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
newc=`grep "X-THREAD" smtp-temp.log|awk '{print $6}'|head -1`
if [ $newc -eq 0 ];then
	echo -e "\033[32m###################### X-THREAD STORE for u2 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD STORE for u2 successfully!! ##################\033[0m\n\n"  >>summary.log
else
	echo -e "\033[31m###################### X-THREAD STORE for u2 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD STORE for u2 failed!! ##################\033[0m\n\n"  >>summary.log
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >>summary.log

##fetch u3
echo "3----for u3 ,there should have 4 messages total,all unseen,belongs to 3 conversions,each has 2,1,1 messages:"  >>summary.log
echo >>summary.log
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-fetching u3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#(1) X-THREAD  COMMAND
echo "(1)######X-THREAD  COMMAND###########"
echo "(1)######X-THREAD  COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser3 p\r\n" >&3

echo -en "a select inbox\r\n" >&3

echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
cf=`grep "X-THREAD" smtp-temp.log |wc -l`
if [ $cf -eq 4 ];then
echo -e "\033[32m###################### X-THREAD for u3 successfully!! ##################\033[0m\n\n" 
echo -e "\033[32m###################### X-THREAD for u3 successfully!! ##################\033[0m\n\n"   >>summary.log
else
echo -e "\033[31m###################### X-THREAD for u3 failed!! ##################\033[0m\n\n" 
echo -e "\033[31m###################### X-THREAD for u3 failed!! ##################\033[0m\n\n"  >>summary.log
fi
#(2) X-THREAD LIST COMMAND
echo "(2)######X-THREAD LIST COMMAND###########"
echo "(2)######X-THREAD LIST COMMAND###########"  >>summary.log
target=`grep "X-THREAD" smtp-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -1`
latuid=`grep "X-THREAD" smtp-temp.log |awk '{print $4}' |head -1`
let tem=latuid-1
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser3 p\r\n" >&3

echo -en "a select inbox\r\n" >&3

#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a uid fetch 1:* rfc822\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep "X-THREAD" smtp-temp.log  >> summary.log
uid1=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" smtp-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
if [ $uid1 -eq $latuid  -a $uid2 -eq $tem ];then
	echo -e "\033[32m###################### X-THREAD LIST for u3 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD LIST for u3 successfully!! ##################\033[0m\n\n"  >>summary.log
else
  echo -e "\033[31m###################### X-THREAD LIST for u3 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD LIST for u3 failed!! ##################\033[0m\n\n"  >>summary.log
fi

#(3)X-THREAD store command
#(3-1)  X-THREAD store command
echo "(3)######X-THREAD STORE COMMAND###########"
echo "(3)######X-THREAD STORE COMMAND###########"  >>summary.log
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser3 p\r\n" >&3

echo -en "a select inbox\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3

echo -en "a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen"  >>summary.log
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log  >>summary.log
grep -i "flags"  smtp-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser3 p\r\n" >&3

echo -en "a select inbox\r\n" >&3

echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch smtp-temp.log
cat <&3 >smtp-temp.log
exec 3>&-
#cat smtp-temp.log
grep "X-THREAD" smtp-temp.log  >> summary.log
newc=`grep "X-THREAD" smtp-temp.log|awk '{print $6}'|head -1`
if [ $newc -eq 0 ];then
	echo -e "\033[32m###################### X-THREAD STORE for u3 successfully!! ##################\033[0m\n\n" 
	echo -e "\033[32m###################### X-THREAD STORE for u3 successfully!! ##################\033[0m\n\n"  >>summary.log
else
	echo -e "\033[31m###################### X-THREAD STORE for u3 failed!! ##################\033[0m\n\n" 
	echo -e "\033[31m###################### X-THREAD STORE for u3 failed!! ##################\033[0m\n\n"  >>summary.log
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >>summary.log


#delete accounts
curl -s -X DELETE "http://$moshost/mxos/mailbox/v2/$u1@openwave.com" |jq .
curl -s -X DELETE "http://$moshost/mxos/mailbox/v2/$u2@openwave.com" |jq .
curl -s -X DELETE "http://$moshost/mxos/mailbox/v2/$u3@openwave.com" |jq .

#revert keys:
#ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXTHREAD=fals"\""
#ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableCONDSTORE=false";imconfcontrol -install -key "/*/common/enableXTHREAD=false"\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXTHREAD=false"\""

#restart
#ssh root@${FEPHost2} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
#cat smtp-temp.log
cat summary.log
#revert message test
#reaplce current messages test
#cp     1-testmessage2to1.ttt 1-testmessage2to1.txt  
#cp     2-testmessage1re2.ttt 2-testmessage1re2.txt
#cp     3-testmessage2re1.ttt 3-testmessage2re1.txt
#cp     4-testmessage3to2.ttt 4-testmessage3to2.txt
#cp     5-testmessage2re3.ttt 5-testmessage2re3.txt
#cp     6-testmessage3re2.ttt 6-testmessage3re2.txt
#cp     7-testmessage1to3.ttt 7-testmessage1to3.txt    
#cp     8-testmessage3re1.ttt 8-testmessage3re1.txt    
#cp     9-testmessage1re3.ttt 9-testmessage1re3.txt    

rm smtp-temp.log