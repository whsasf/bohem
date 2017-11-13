#!/bin/bash
#use for loop to do this
clientip=10.37.2.214
IMAPHost=172.26.202.87
IMAPPort=20143
POPHost=172.26.202.87
POPPort=20110
SMTPHost=172.26.202.87
SMTPPort=20025
FEPuser=imail2
count=10
NAThost=10.37.2.214
#username=mx95user$i
userpasswd=p
user=imail2
#clear  imap-operations.log  if existed
lofile=imap-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi

#delete old messages
for (( i=1;i<=$count;i++ ))
do 
   ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete mx95user$i@openwave.com  -all\""
done

#clear old log data
ssh root@$IMAPHost  'for j in `find /opt/imail2/log/ -name "*.[A-Za-z]*"` ; do cat /dev/null >$j; done'

#begin IMAP operations
echo -e "-1-IMAP operations:login,select inbox;fetch 1 message,logout;\n"
#j is the output redirections symbols
for ((i=1;i<=$count;i++ ))
do
  #clear old log data
  ssh root@$IMAPHost  'for j in `find /opt/imail2/log/ -name "*.[A-Za-z]*"` ; do cat /dev/null >$j; done'
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>imap-operations.log
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login mx95user$i m\r\n" >&3   #login failed
	echo -en "a login mx95user$i $userpasswd\r\n" >&3
	echo -en "a select inboxme\r\n" >&3
	echo -en "a select inbox\r\n" >&3
	echo -en "a append inbox {65}\r\n">&3
	echo -en "we are ################Chinese,we are ####################great!!\r\n">&3
	echo -en "a select inbox\r\n" >&3
	echo -en "a fetch 10 rfc822\r\n" >&3
	echo -en "a fetch 1 rfc822\r\n" >&3

	#get port number from here :
  clientsta=`netstat -na |grep -i ESTABLISHED|grep -i $IMAPHost|grep -v tcp6|grep $IMAPPort`
  serversta=`ssh root@$IMAPHost "netstat -na |grep -i ESTABLISHED|grep -i $clientip |grep -v tcp6|grep $IMAPPort"`
  NATsta=`ssh root@$NAThost "netstat -na |grep -i ESTABLISHED|grep -i $IMAPHost |grep -v tcp6|grep $IMAPPort"`
	echo -en "a logout\r\n" >&3

  touch imap-temp.log
	cat <&3 > imap-temp.log
	echo  -e  "\n\n-(1)-The IMAP process of mx95user$i is:"
	echo -e "\n"
	cat imap-temp.log
	echo  -e  "\n\n-(1)-The IMAP process of mx95user$i is:" >>imap-operations.log
	echo -e "\n" >> imap-operations.log
	echo -e "\n"
  cat imap-temp.log >>imap-operations.log
	exec 3>&-
	#judge if imap command operated successfully
	loginflag=`grep -i "login completed" imap-temp.log |wc -l`
	selectflag=`grep -i "select completed" imap-temp.log |wc -l`
	fetchflag=`grep -i "fetch completed" imap-temp.log |wc -l`
	logoutflag=`grep -i "logout completed"  imap-temp.log |wc -l`

	if [[ $loginflag == 1 ]] && [[ $selectflag == 1 ]] && [[ $fetchflag == 1 ]] && [[ $logoutflag == 1 ]]
	then
		echo -e ">>>>>>>>>>>>>IMAP operation for mx95user$i successfully!!<<<<<<<<<<<<<<<<\n"
		((j++))  # flags accumulate ,now j=1;
	else
		echo -e ">>>>>>>>>>>>>IMAP operation for mx95user$i unsuccessfully!!<<<<<<<<<<<<<<\n"
	fi

	#output the port number of server and client from here:

  echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from IMAP server are:###########\n"
	echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from IMAP server are:###########\n" >>imap-operations.log
	echo -ne "from client-->\n$clientsta\n"
	echo -ne "from client-->\n$clientsta\n" > port-temp.log
	echo -ne "from server-->\n$serversta\n"
	echo -ne "from server-->\n$serversta\n" >>port-temp.log
  echo -ne "from NATser-->\n$NATsta\n"   
  echo -ne "from NATser-->\n$NATsta\n"    >>port-temp.log
	cat port-temp.log >>imap-operations.log
  #q=`wc -l port-temp.log `  #q is a lines of port output
	#if [[ $q == 2 ]]
  #then
	#	((j++))  # flags accumulate ,now j=1;
	#fi

	#get imapserv.log :
		echo  -e  "\n\n-(3)-The IMAPlogs for account mx95user$i is:\n"
		echo  -e  "\n\n-(3)-The IMAPlogs for account mx95user$i is:\n" >>imap-operations.log
		#ssh root@$IMAPHost  'grep   mx95user'$i'  /opt/imail2/log/imapserv.log' >imaplog-temp.log
		ssh root@$IMAPHost  'cat /opt/imail2/log/imapserv.log |grep -v "user=xx"' >imaplog-temp.log #"user=xx" is a specific setting in my env only
		cat imaplog-temp.log
		cat imaplog-temp.log >> imap-operations.log
	#delimiter of each loop
done

rm -f imap-temp.log
rm -f port-temp.log
rm -f imaplog-temp.log




#need add trap functions
