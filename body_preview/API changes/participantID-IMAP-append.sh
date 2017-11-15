#!/bin/bash
#use ramdom accounts
u1=`echo $RANDOM`
u2=`echo $RANDOM`
u3=`echo $RANDOM`
deleteuser=$u1@openwave.com
IMAPHost=172.26.202.87
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
SMTPHost=172.26.202.87
SMTPPort=20025
user=imail2
FEPHost2=172.26.202.87
imailuser=imail2
moshost="172.26.203.123:8081"


echo $u1@openwave.com
echo $u2@openwave.com
echo $u3@openwave.com

#reaplce current messages test
cp 1-testmessage2to1.txt    1-testmessage2to1.ttt
cp 2-testmessage1re2.txt    2-testmessage1re2.ttt
cp 3-testmessage2re1.txt    3-testmessage2re1.ttt
cp 4-testmessage3to2.txt    4-testmessage3to2.ttt
cp 5-testmessage2re3.txt    5-testmessage2re3.ttt
cp 6-testmessage3re2.txt    6-testmessage3re2.ttt
cp 7-testmessage1to3.txt    7-testmessage1to3.ttt
cp 8-testmessage3re1.txt    8-testmessage3re1.ttt
cp 9-testmessage1re3.txt    9-testmessage1re3.ttt
sed -i 's/xx1/'$u1'/g'  *testmessage*.ttt
sed -i 's/xx2/'$u2'/g'  *testmessage*.ttt
sed -i 's/xx3/'$u3'/g'  *testmessage*.ttt
 

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

#clear current messages
#ssh root@${FEPHost2} "su - ${imailuser} -c \"immsgdelete $u1@openwave.com -all\""
#ssh root@${FEPHost2} "su - ${imailuser} -c \"immsgdelete $u2@openwave.com -all\""
#ssh root@${FEPHost2} "su - ${imailuser} -c \"immsgdelete $u3@openwave.com -all\""

#create conversations through IMAP append
#1 conversation between u1 and u2
#(1)append first message :sending from u2 to u1
length=`wc -c 1-testmessage2to1.ttt |awk  '{print $1}'`
DATA=`cat 1-testmessage2to1.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message1 append failed  ##################\033[0m\n\n" 
fi

echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(2)apprnd second message :sending from u1 to u2
length=`wc -c 2-testmessage1re2.ttt |awk  '{print $1}'`
DATA=`cat 2-testmessage1re2.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser2 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message2 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(3)apprnd third message :sending from u2 to u1
length=`wc -c 3-testmessage2re1.ttt |awk  '{print $1}'`
DATA=`cat 3-testmessage2re1.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message3 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"


#2 conversation between u2 and u3
#(1)append first message :sending from u3 to u2
length=`wc -c 4-testmessage3to2.ttt |awk  '{print $1}'`
DATA=`cat 4-testmessage3to2.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser2 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message1 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(2)append second message :sending from u2 to u3
length=`wc -c 5-testmessage2re3.ttt |awk  '{print $1}'`
DATA=`cat 5-testmessage2re3.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser3 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message2 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(3)append second message :sending from u3 to u2
length=`wc -c 6-testmessage3re2.ttt |awk  '{print $1}'`
DATA=`cat 6-testmessage3re2.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser2 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message3 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#3 conversation between u3 and u1
#(1)append first message :sending from u1 to u3
length=`wc -c 7-testmessage1to3.ttt |awk  '{print $1}'`
DATA=`cat 7-testmessage1to3.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message1-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser3 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message1 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message1 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(2)append second message :sending from u3 to u1
length=`wc -c 8-testmessage3re1.ttt |awk  '{print $1}'`
DATA=`cat 8-testmessage3re1.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message2-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message2 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message2 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"

#(3)append second message :sending from u1 to u3
length=`wc -c 9-testmessage1re3.ttt |awk  '{print $1}'`
DATA=`cat 9-testmessage1re3.ttt`
echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!-Appending message3-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser3 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
n=`grep "APPEND completed"   imap-temp.log |wc -l`
if [ $n -eq 1 ];then
echo -e "\033[32m###################### Message3 append success ##################\033[0m\n\n" 
else
echo -e "\033[31m###################### Message3 append failed  ##################\033[0m\n\n" 
fi
echo "!!!!!!!!!!!!!!!!append finished!!!!!!!!!!!!!!!"


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

#echo -en "a capability\r\n" >&3

echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1:* rfc822\r\n" >&3 

echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3

echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
cf=`grep "X-THREAD" imap-temp.log |wc -l`
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
target=`grep "X-THREAD" imap-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -2|tail -1`
latuid=`grep "X-THREAD" imap-temp.log |awk '{print $4}' |head -2|tail -1`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep "X-THREAD" imap-temp.log  >> summary.log
uid1=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep -i "flags"  imap-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
newc=`grep "X-THREAD" imap-temp.log|awk '{print $6}'|head -2|tail -1`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
cf=`grep "X-THREAD" imap-temp.log |wc -l`
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
target=`grep "X-THREAD" imap-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -1`
latuid=`grep "X-THREAD" imap-temp.log |awk '{print $4}' |head -1`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep "X-THREAD" imap-temp.log  >> summary.log
uid1=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep -i "flags"  imap-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser2 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
newc=`grep "X-THREAD" imap-temp.log|awk '{print $6}'|head -1`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
cf=`grep "X-THREAD" imap-temp.log |wc -l`
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
target=`grep "X-THREAD" imap-temp.log |awk '{print $3}' |awk -F "("  '{print $2}'|head -1`
latuid=`grep "X-THREAD" imap-temp.log |awk '{print $4}' |head -1`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep "X-THREAD" imap-temp.log  >> summary.log
uid1=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $3}'|awk -F "(" '{print $2}'`
uid2=`grep "X-THREAD" imap-temp.log |head -1|awk '{print $4}'|awk -F ")" '{print $1}'`
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
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log  >>summary.log
grep -i "flags"  imap-temp.log >>summary.log

#(3-2)  X-THREAD  command
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort

echo -en "a login $loginuser3 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo "#real command: a UID X-THREAD (PARTICIPANTS) UTF-8 ALL"  >>summary.log
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
#echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
echo -en "a logout\r\n" >&3
touch imap-temp.log
cat <&3 >imap-temp.log
exec 3>&-
#cat imap-temp.log
grep "X-THREAD" imap-temp.log  >> summary.log
newc=`grep "X-THREAD" imap-temp.log|awk '{print $6}'|head -1`
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
#cat imap-temp.log
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


rm imap-temp.log