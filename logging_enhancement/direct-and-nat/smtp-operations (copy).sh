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
rcptto=mx95user0
SUBJECT="Test Email"
DATA="Hi mauser0, this is mx95user$i, i'm seend you a test Email."
count=10
NAThost=10.37.2.214
#username=mx95user$i
userpasswd=p
#clear  smtp-operations.log  if existed
lofile=smtp-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi



#begin smtp operations
echo -e "-2-SMTP operations:send an Enail to mx95user0@openwave.com;\n"
#j is the output redirections symbols
for ((i=1;i<=$count;i++ ))
do
  #clear old log data
  ssh root@$SMTPHost  'for j in `find /opt/imail2/log/ -name "*.[A-Za-z]*"` ; do cat /dev/null >$j; done'
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>smtp-operations.log

  exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
  echo -en "MAIL FROM:mx95user$i\r\n" >&3
  echo -en "RCPT TO:me7\r\n" >&3            #to on exist account
#  echo -en "MAIL FROM:mx95user$i\r\n" >&3
  echo -en "RCPT TO:$rcptto\r\n" >&3        #success delieve
  echo -en "DATA\r\n" >&3
  echo -en "Subject: $SUBJECT\r\n" >&3
  echo -en "$DATA\r\n" >&3
  echo -en ".\r\n" >&3

	#get port number from here :
  clientsta=`netstat -na |grep -i ESTABLISHED|grep -i $SMTPHost|grep -v tcp6|grep $SMTPPort`
  serversta=`ssh root@$SMTPHost "netstat -na |grep -i ESTABLISHED|grep -i $clientip |grep -v tcp6|grep $SMTPPort"`

  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	echo  -e  "\n\n-(1)-The SMTP process of mx95user$i is:"
	echo -e "\n"
	cat smtp-temp.log
	echo  -e  "\n\n-(1)-The SMTP process of mx95user$i is:" >>smtp-operations.log
	echo -e "\n" >> smtp-operations.log
	echo -e "\n"
  cat smtp-temp.log >>smtp-operations.log
	exec 3>&-
	#judge if imap command operated successfully
	repttoflag=`grep -i "250 Recipient <mx95user0> Ok" smtp-temp.log | wc -l`
	dataflag=`grep -i "354 Ok Send data" smtp-temp.log | wc -l`
	messageflag=`grep -i "250 Message received" smtp-temp.log | wc -l`

	if [[ $repttoflag == 1 ]] && [[ $dataflag == 1 ]] && [[ $messageflag == 1 ]]
	then
		echo -e ">>>>>>>>>>>>>SMTP operation for mx95user$i successfully!!<<<<<<<<<<<<<<<<\n"
		#((j++))  # flags accumulate ,now j=1;
	else
		echo -e ">>>>>>>>>>>>>IMAP operation for mx95user$i unsuccessfully!!<<<<<<<<<<<<<<\n"
	fi

	#output the port number of server and client from here:

  echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from SMTP server are:###########\n"
	echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from SMTP server are:###########\n" >>smtp-operations.log
	echo -ne "from client--> $clientsta\n"
	echo -ne "from client--> $clientsta\n" > port-temp.log
	echo -ne "from server--> $serversta\n"
	echo -ne "from server--> $serversta\n" >>port-temp.log
	cat port-temp.log >>smtp-operations.log
  #q=`wc -l port-temp.log `  #q is a lines of port output
	#if [[ $q == 2 ]]
  #then
	#	((j++))  # flags accumulate ,now j=1;
	#fi

	#get imapserv.log :
		echo  -e  "\n\n-(3)-The SMTPlogs for account mx95user$i is:\n"
		echo  -e  "\n\n-(3)-The SMTPlogs for account mx95user$i is:\n" >>smtp-operations.log
		#ssh root@$SMTPHost  'grep   mx95user'$i'  /opt/imail2/log/mta.log' >smtplog-temp.log
		ssh root@$SMTPHost  'cat  /opt/imail2/log/mta.log |grep -v "user=xx"' >smtplog-temp.log #"user=xx" is a specific setting in my env only
		cat smtplog-temp.log
		cat smtplog-temp.log >> smtp-operations.log
	#delimiter of each loop
done
rm -rf imap-temp.log
rm -rf smtp-temp.log
rm -rf port-temp.log
rm -rf imaplog-temp.log
rm -rf smtplog-temp.log



#need add trap functions
