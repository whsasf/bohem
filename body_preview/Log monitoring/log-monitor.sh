#!/bin/bash
clientip=10.37.2.214
IMAPHost=172.26.202.87
IMAPPort=20143
POPHost=172.26.202.87
POPPort=20110
SMTPHost=172.26.202.87
SMTPPort=20025
MSSHost1=172.26.202.87
MSSHost2=172.26.203.121
mOSHost=172.26.203.123    
CassandraHost1=172.26.202.233 
CassandraHost2=172.26.202.234
CassandraHost3=172.26.202.245

FEPuser=imail2
user=imail2
#count=10
#NAThost=10.37.2.214
#username=mx95user$i
deleteuser=xx1@openwave.com
loginuser=xx1
loginuserpasswd=p
mailfrom="<xx2@openwave.com>"
rcptto="<xx1@openwave.com>"
 
#remove old record logs in locally
rm -rf *.log
 
#clear  IMAP, MTA, MSS, MXOS,Cassandra logs 
ssh root@${IMAPHost}  			 'cat /dev/null > /opt/imail2/log/imapserv.log'
ssh root@${SMTPHost}  			 'cat /dev/null > /opt/imail2/log/mta.log'
ssh root@${MSSHost1}  			 'cat /dev/null > /opt/imail2/log/mss.log'
ssh root@${MSSHost2}  			 'cat /dev/null > /opt/imail2/log/mss.log'
ssh root@${mOSHost}   			 'cat /dev/null > /opt/imail2/mxos/logs/mxos.log'  
ssh root@${CassandraHost1}   'cat /dev/null > /opt/cassandra/apache-cassandra-2.1.9/logs/system.log'
ssh root@${CassandraHost2}   'cat /dev/null > /opt/cassandra/apache-cassandra-2.1.9/logs/system.log'
ssh root@${CassandraHost3}   'cat /dev/null > /opt/cassandra/apache-cassandra-2.1.9/logs/system.log'

#enable firstline with key: /*/common/enableXFIRSTLINE: [true]
#doing IMAP operations related to body_preview:
# 0- delete first message in mailbox "immsgdelete xx1@openwave.com -all"   

# 1- Deliever 2 messages to xx1@openwave.com from xx2@openwave.com using MTA
# 2- IMAP append 2 messages to xx1@openwave.com in INBOX

# 3- "a login xx1 p"
# 4- "a select inbox"
# 5- "a fetch 2:3 rfc822"
# 6- "a fetch 2:3 firstline"
# 7- "a Store 2 +flags.silent (\deleted)"   
# 8- "a Store 3 +flags.silent (\deleted)" 
# 9- "a expunge"
# 10- "a select inbox"
# 11- "a fetch 1:2 firstline"
# 12- "a logout"

#begin
#0
ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""	 
#1                                                                          
exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$mailfrom\r\n" >&3
echo -en "RCPT TO:$rcptto\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat test-message1.txt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "QUIT\r\n" >&3
exec 3>&-

exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "MAIL FROM:$mailfrom\r\n" >&3
echo -en "RCPT TO:$rcptto\r\n" >&3
echo -en "DATA\r\n" >&3
echo -en "`cat test-message2.txt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "QUIT\r\n" >&3
exec 3>&-
	
#2    
length=`wc -c append-message1.txt |awk  '{print $1}'`  
DATA=`cat append-message1.txt`
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
exec 3>&-

length=`wc -c append-message2.txt |awk  '{print $1}'`  
DATA=`cat append-message2.txt`
exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {$length}\r\n" >&3
echo -en "$DATA\r\n" >&3
echo -en "a logout\r\n" >&3
exec 3>&-


#3-12

exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login $loginuser p\r\n" >&3   #3
echo -en "a select inbox\r\n" >&3         #4
echo -en "a fetch 2:3 rfc822\r\n" >&3     #5
echo -en "a fetch 2:3 firstline\r\n" >&3  #6
echo -en "a Store 2 +flags.silent (\deleted)\r\n" >&3  #7
echo -en "a Store 3 +flags.silent (\deleted)\r\n" >&3  #8
echo -en "a expunge\r\n" >&3  #9
echo -en "a select inbox\r\n" >&3   #10
echo -en "a fetch 1:2 firstline\r\n" >&3  #11
echo -en "a logout\r\n" >&3               #12     
cat <&3 >imap-temp.log
exec 3>&-     

cat   imap-temp.log 

#get all target logs back

ssh root@$IMAPHost  'cat /opt/imail2/log/imapserv.log' > imapserv-copy.log           
ssh root@$SMTPHost  'cat /opt/imail2/log/mta.log' >mta-copy.log         
ssh root@$MSSHost1  'cat /opt/imail2/log/mss.log' > mss1-copy.log        
ssh root@$MSSHost2  'cat /opt/imail2/log/mss.log' > mss2-copy.log        
ssh root@$mOSHost   'cat /opt/imail2/mxos/logs/mxos.log' > mxos-copy.log   
ssh root@${CassandraHost1}   'cat /opt/cassandra/apache-cassandra-2.1.9/logs/system.log' >cassandra1.log  
ssh root@${CassandraHost2}   'cat /opt/cassandra/apache-cassandra-2.1.9/logs/system.log' >cassandra2.log
ssh root@${CassandraHost3}   'cat /opt/cassandra/apache-cassandra-2.1.9/logs/system.log' >cassandra3.log

#analyze

grep -Ei  "error|warn|fatal"   *.log   |tee error.log
rm -rf  imap-temp.log   

