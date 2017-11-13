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
SUBJECT="Test Email"
DATA="Hi mauser0, this is mx95user$i, i'm seend you a test Email.xxxxxxxxbbbbbbbcccccccc!!!!!"
count=10
NAThost=10.37.2.214
#username=mx95user$i
userpasswd=p
#clear  pop-operations.log  if existed
lofile=pop-operations.log
if [ -f "$lofile" ]
then
	cat /dev/null >$lofile
fi




#begin pop operations
echo -e "-3-POP operations:login,read 1 message (the second one ,logout);\n"
for ((i=1;i<=$count;i++ ))
do
  
  #clear old log data
  ssh root@$POPHost  'for j in `find /opt/imail2/log/ -name "*.[A-Za-z]*"` ; do cat /dev/null >$j; done'
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!user mx95user$i!!!!!!!!!!!!!!!!!!!!!!!!!!!!">>smtp-operations.log

  #send one message from mx95user0  to mx95user$i
  exec 3<>/dev/tcp/$POPHost/$SMTPPort
  echo -en "MAIL FROM:mx95user0\r\n" >&3
  echo -en "RCPT TO:mx95user$i\r\n" >&3
  echo -en "DATA\r\n" >&3
  echo -en "Subject: $SUBJECT\r\n" >&3
  echo -en "$DATA\r\n" >&3
  echo -en ".\r\n" >&3
  echo -en "QUIT\r\n" >&3
  touch smtp-temp.log
	cat <&3 > smtp-temp.log
	cat smtp-temp.log
	exec 3>&-

  #POP operationas begin
	exec 3<>/dev/tcp/$POPHost/$POPPort
	echo -en "user mx95user$i\r\n" >&3
	echo -en "pass m\r\n" >&3  #login failed
	echo -en "user mx95user$i\r\n" >&3
	echo -en "pass $userpasswd\r\n" >&3  #login success
	echo -en "retr 5\r\n" >&3   #retr a noexist message
	echo -en "retr 2\r\n" >&3   #retr a existed message
  #get port number from here :
	clientsta=`netstat -na |grep -i ESTABLISHED|grep -i $POPHost|grep -v tcp6|grep $POPPort`
  serversta=`ssh root@$POPHost "netstat -na |grep -i ESTABLISHED|grep -i $clientip |grep -v tcp6|grep $POPPort"`

	echo -en "quit\r\n" >&3
	touch pop-temp.log
	cat <&3 > pop-temp.log
	echo  -e  "\n\n-(1)-The POP process of mx95user$i is:"
	echo -e "\n"
	cat pop-temp.log
	echo  -e  "\n\n-(1)-The POP process of mx95user$i is:" >>pop-operations.log
	echo -e "\n" >> pop-operations.log
	echo -e "\n"
	cat pop-temp.log >>pop-operations.log
	exec 3>&-


	#judge if POP command operated successfully
	loginflag=`grep -i "is welcome here" pop-temp.log | wc -l`
	readmessageflag=`grep -i octets  pop-temp.log | wc -l`

	if [[ $loginflag == 1 ]] && [[ $readmessageflag == 1 ]]
	then
		echo -e ">>>>>>>>>>>>>POP operation for mx95user$i successfully!!<<<<<<<<<<<<<<<<\n"
		#((j++))  # flags accumulate ,now j=1;
	else
		echo -e ">>>>>>>>>>>>>POP operation for mx95user$i unsuccessfully!!<<<<<<<<<<<<<<\n"
	fi

	#output the port number of server and client from here:

  echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from POP server are:###########\n"
	echo -e "\n\n-(2)-###############The TCP connection status for mx95user$i from client are and from POP server are:###########\n" >>pop-operations.log
	echo -ne "from client--> $clientsta\n"
	echo -ne "from client--> $clientsta\n" > port-temp.log
	echo -ne "from server--> $serversta\n"
	echo -ne "from server--> $serversta\n" >>port-temp.log
	cat port-temp.log >>pop-operations.log
  #q=`wc -l port-temp.log `  #q is a lines of port output
	#if [[ $q == 2 ]]
  #then
	#	((j++))  # flags accumulate ,now j=1;
	#fi

	#get imapserv.log :
		echo  -e  "\n\n-(3)-The POPlogs for account mx95user$i is:\n"
		echo  -e  "\n\n-(3)-The POPlogs for account mx95user$i is:\n" >>pop-operations.log
    #ssh root@$POPHost  'grep   mx95user'$i'  /opt/imail2/log/popserv.log' >poplog-temp.log
		ssh root@$POPHost  'cat  /opt/imail2/log/popserv.log |grep -v "user=xx"' >poplog-temp.log #"user=xx" is a specific setting in my env only
		cat poplog-temp.log
		cat poplog-temp.log >> pop-operations.log
	#delimiter of each loop
done
rm -rf imap-temp.log
rm -rf smtp-temp.log
rm -rf pop-temp.log
rm -rf port-temp.log
rm -rf imaplog-temp.log
rm -rf smtplog-temp.log
rm -rf poplog-temp.log



#need add trap functions
