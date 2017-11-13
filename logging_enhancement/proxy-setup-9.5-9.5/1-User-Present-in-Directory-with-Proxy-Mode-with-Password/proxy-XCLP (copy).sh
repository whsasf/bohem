#!/bin/bash
#change the variables to meet your env in your testing
mos1="172.26.202.245:8081"
mos2="172.26.203.123:8081"
testaccount1="procu1@openwave.com"
testaccount2="procu2@openwave.com"
FEPHost1=172.26.202.233
FEPHost2=172.26.202.87
IMAPHost1=172.26.202.233
IMAPHost2=172.26.202.87
POPHost1=172.26.202.233
POPHost2=172.26.202.87
SMTPHost1=172.26.202.233
SMTPHost2=172.26.202.87
IMAPPort1=10143
IMAPPort2=20143
POPPort1=10110
POPPort2=20110
SMTPPort1=10025
SMTPPort2=20025
imailuser=imail2
loginuser1=procu1
loginuser2=procu2
wrongfrom=xx2
correctfrom=procu1
rcptto=procu2
message="hi,procu2,this is procu1.good day to you !hahahahha!"

#target# used to judge if FEP logs log correct "frpmhost:fromport"
target1="fromhost=10.37.2.214:fromport="
target2="fromhost=172.26.202.233:fromport="

targett1="fromhost=10.37.2.214:fromport=|fromhost=\[10.37.2.214\]:fromport="

#targett2="fromhost=10.37.2.214:|fromhost=\[10.37.2.214\]:fromport="



#preparations 
echo -e "\n\n########################## !!!preparations!!! ###############################"
#env preparations .THis test suit contains:user present in directary with password: mta.smtp.pop, mta-tls,pop-tls,smtp-tls
#Two independent environment,first one: Mx9.5-1(172.26.202.233 imapport:10143, popport:10110 smtpport:10025), proxy server.
#    the other one is                   Mx9.5-2(172.26.202.87  imapport:20143, popport:20110 smtpport:20025), 

#edit keys:

#for IMAP and pop, there is only two settings related to XCLP those are as below
#1. allowXCLP=true
#2. XclpAllowedIPs=172.26.202.233
echo -e "\n\n########################## add keys ###############################"
#(1)Mx9.5-1 IMAP/POP setting:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/imapserv/ImapProxyAuthenticate=false";imconfcontrol -install -key "/*/imapserv/imapProxyHost=imap://172.26.202.87:20143";imconfcontrol -install -key "/*/imapserv/imapProxyPort=20143";imconfcontrol -install -key "/*/popserv/popProxyHost=pop://172.26.202.87:20110";imconfcontrol -install -key "/*/popserv/popProxyPort=20110"\""
#(2)9.5-1 MTA setting:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/mta/mtaProxyAuthentication=true";imconfcontrol -install -key "/*/mta/mtaProxyUnknownAccount=true";imconfcontrol -install -key "/*/mta/mtaProxyAuthentication=true";imconfcontrol -install -key "/*/mta/mtaProxyUnknownTarget=smtp://172.26.202.87:20025";imconfcontrol -install -key "/inbound-standardmta-direct/mta/requireAuthentication=true";imconfcontrol -install -key "/*/mta/relaySourcePolicy=allowAll";imconfcontrol -install -key "/inbound-standardmta-direct/mta/relaySourcePolicy=allowAll";imconfcontrol -install -key "/*/mxos/defaultPasswordStoreType=clear"\""
#(3)9.5-2 MTA setting:
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/mta/requireAuthentication=true";imconfcontrol -install -key "/inbound-standardmta-direct/mta/requireAuthentication=true";imconfcontrol -install -key "/*/mta/relaySourcePolicy=allowAll";imconfcontrol -install -key "/inbound-standardmta-direct/mta/relaySourcePolicy=allowAll";imconfcontrol -install -key "/*/mxos/defaultPasswordStoreType=clear"\""
#(3-2) 9.5-2 enable xclp
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/allowXCLP=true";imconfcontrol -install -key "/*/improxy/sendClientIp=true";imconfcontrol -install -key "/*/imapserv/allowXCLP=true";imconfcontrol -install -key "/*/imapserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/imapserv/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/imapserv/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/*/common/xclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/imapserv/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/mta/allowXCLP=true";imconfcontrol -install -key "/*/mta/enableOutboundXCLP=true";imconfcontrol -install -key "/*/mta/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/mta/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/mta/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/inbound-standardmta-direct/mta/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/mta/enableOutboundXCLP=true";imconfcontrol -install -key "/*/popserv/allowXCLP=true";imconfcontrol -install -key "/*/popserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/popserv/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/popserv/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/popserv/XclpAllowedIPs=10.37.2.214";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/enableOutboundXCLP=true"\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/allowXCLP=true";imconfcontrol -install -key "/*/improxy/sendClientIp=true";imconfcontrol -install -key "/*/imapserv/allowXCLP=true";imconfcontrol -install -key "/*/imapserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/imapserv/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/imapserv/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/*/common/xclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/imapserv/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/mta/allowXCLP=true";imconfcontrol -install -key "/*/mta/enableOutboundXCLP=true";imconfcontrol -install -key "/*/mta/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/mta/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/mta/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/inbound-standardmta-direct/mta/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/mta/enableOutboundXCLP=true";imconfcontrol -install -key "/*/popserv/allowXCLP=true";imconfcontrol -install -key "/*/popserv/enableOutboundXCLP=true";imconfcontrol -install -key "/*/popserv/outboundXCLPExpectsReply=true";imconfcontrol -install -key "/*/popserv/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/popserv/XclpAllowedIPs=172.26.202.233";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/allowXCLP=true";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/enableOutboundXCLP=true"\""
#（3-3） restart FEPs
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
#(4)Create same user on Mx9.5-1 and Mx9.5-2,  enable user proxy on Mx9.5-1 by Mos. status=proxy ,enable mailsmtpauth for both users in 
# MX9.5-1 and MX9.5-2
echo -e "\n\n########################## create test users using mxos apis ###############################"
#MX9.5-1:
curl -s -X PUT -d "cosId=default&password=p&status=proxy&smtpAuthenticationEnabled=yes" "http://$mos1/mxos/mailbox/v2/$testaccount1/"|jq .
curl -s -X PUT -d "cosId=default&password=p&status=proxy&smtpAuthenticationEnabled=yes" "http://$mos1/mxos/mailbox/v2/$testaccount2/"|jq .
#MX9.5-2: 
curl -s -X PUT -d "cosId=default&password=p&smtpAuthenticationEnabled=yes" "http://$mos2/mxos/mailbox/v2/$testaccount1/"|jq .
curl -s -X PUT -d "cosId=default&password=p&smtpAuthenticationEnabled=yes" "http://$mos2/mxos/mailbox/v2/$testaccount2/"|jq .

#append one message into mailboxex on procu1 and procu2 on MX9.5-2,now MX9.5-2 have 2 messages for each mailbox, only 1 for MX9.5-1:

exec 3<>/dev/tcp/$IMAPHost2/$IMAPPort2
echo -en "a login $loginuser1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a append inbox {10}\r\n" >&3
echo -en "2-11111111\r\n" >&3
echo -en "a logout\r\n" >&3
exec 3>&-

#exec 3<>/dev/tcp/$IMAPHost2/$IMAPPort2
#echo -en "a login $loginuser2 p\r\n" >&3
#echo -en "a select inbox\r\n" >&3
#echo -en "a append inbox {10}\r\n" >&3
#echo -en "2-22222222\r\n" >&3
#echo -en "a logout\r\n" >&3
#exec 3>&-



#IMAP proxy testing
echo -e "\n\n###################################### IMAP proxy testing ###########################################"

#clear all imapserv.log in MX9.5-1 and MX9.5-2
ssh root@${IMAPHost1}  			 'cat /dev/null > /opt/imail2/log/imapserv.log'
ssh root@${IMAPHost2}  			 'cat /dev/null > /opt/imail2/log/imapserv.log'

#Doing IMAP operations
exec 3<>/dev/tcp/$IMAPHost1/$IMAPPort1
#echo -en "a xclp 10.37.2.214\r\n" >&3
#sleep 1
echo -en "a login $loginuser1 p\r\n" >&3
#echo -en "a xclp 10.37.2.214\r\n" >&3
echo -en "a select xxx\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 2 rfc822\r\n" >&3
echo -en "a fetch 5 rfc822\r\n" >&3
echo -en "a logout\r\n" >&3
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log

#Now gether imap logs from MX9.5-1 and MX9.5-2
ssh root@$IMAPHost1  'cat /opt/imail2/log/imapserv.log' > imapserv1.log
ssh root@$IMAPHost2  'cat /opt/imail2/log/imapserv.log' > imapserv2.log

#Prepare the summary-imap.log
echo -e  "The imap operations logs telneting to MX9.5-1:\n\n" >summary-imap.log
cat imap-temp.log >>summary-imap.log
echo -e "\n\n" >>summary-imap.log
echo -e "\n\nIMAPserv.log from MX9.5-1:\n"
cat imapserv1.log
echo -e "\n\nIMAPserv.log from MX9.5-2:\n"
cat imapserv2.log
echo -e "\n\nIMAPserv.log from MX9.5-1:\n" >>summary-imap.log
cat imapserv1.log >>summary-imap.log
echo -e "\n\nIMAPserv.log from MX9.5-2:\n" >>summary-imap.log
cat imapserv2.log >>summary-imap.log
#analyze    

c1=`grep $target1 imapserv1.log|wc -l`
c2=`grep $target2 imapserv2.log|wc -l`
let cc1=c1+c2
if (( $cc1 == 16 ))
then
  echo -ne "\n\033[32m#####Logging enhancement for IMAP proxy is ok!!##### \033[0m\n\n"
  echo -ne "\n\033[32m#####Logging enhancement for IMAP proxy is ok!!##### \033[0m\n\n" >>summary-imap.log
  echo -ne "\n\033[32m#####Logging enhancement for IMAP proxy is ok!!##### \033[0m\n\n" >outcome.log
else
  echo -ne "\n\033[31m#####Logging enhancement for IMAP proxy not ok!!##### \033[0m\n\n"
  echo -ne "\n\033[31m#####Logging enhancement for IMAP proxy not ok!!##### \033[0m\n\n" >>summary-imap.log
  echo -ne "\n\033[31m#####Logging enhancement for IMAP proxy not ok!!##### \033[0m\n\n" >outcome.log
fi



#POP proxy testing
echo -e "\n\n###################################### POP proxy testing ###########################################"

#clear all popserv.log in MX9.5-1 and MX9.5-2
ssh root@${POPHost1}  'cat /dev/null > /opt/imail2/log/popserv.log'
ssh root@${POPHost2}  'cat /dev/null > /opt/imail2/log/popserv.log'

#Doing POP operations

exec 3<>/dev/tcp/$POPHost1/$POPPort1
echo -en "user $loginuser1\r\n" >&3
sleep 1
echo -en "pass p\r\n" >&3
echo -en "list\r\n" >&3
echo -en "retr 2\r\n" >&3
echo -en "retr 3\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >pop-temp.log
exec 3>&-

cat pop-temp.log

#Now gether pop logs from MX9.5-1 and MX9.5-2
ssh root@$POPHost1  'cat /opt/imail2/log/popserv.log' > popserv1.log
ssh root@$POPHost2  'cat /opt/imail2/log/popserv.log' > popserv2.log

#Prepare the summary-pop.log
echo -e  "The pop operations logs telneting to MX9.5-1:\n\n" >summary-pop.log
cat pop-temp.log >>summary-pop.log
echo -e "\n\n" >>summary-pop.log
echo -e "\n\nPOPserv.log from MX9.5-1:\n"
cat popserv1.log
echo -e "\n\nPOPserv.log from MX9.5-2:\n"
cat popserv2.log
echo -e "\n\nPOPserv.log from MX9.5-1:\n" >>summary-pop.log
cat popserv1.log >>summary-pop.log
echo -e "\n\nPOPserv.log from MX9.5-2:\n" >>summary-pop.log
cat popserv2.log >>summary-pop.log
#analyze    

c1=`grep $target1 popserv1.log|wc -l`
c2=`grep $target2 popserv2.log|wc -l`
let cc1=c1+c2
if (( $cc1 == 6 ))
then
  echo -ne "\n\033[32m#####Logging enhancement for POP proxy is ok!!##### \033[0m\n\n"
  echo -ne "\n\033[32m#####Logging enhancement for POP proxy is ok!!##### \033[0m\n\n" >>summary-pop.log
  echo -ne "\n\033[32m#####Logging enhancement for POP proxy is ok!!##### \033[0m\n\n" >>outcome.log
else
  echo -ne "\n\033[31m#####Logging enhancement for POP proxy not ok!!##### \033[0m\n\n"
  echo -ne "\n\033[31m#####Logging enhancement for pop proxy not ok!!##### \033[0m\n\n" >>summary-pop.log
  echo -ne "\n\033[31m#####Logging enhancement for POP proxy not ok!!##### \033[0m\n\n" >>outcome.log
fi






#SMTP relay testing
echo -e "\n\n###################################### SMTP proxy testing ###########################################"

#clear all mta.log in MX9.5-1 and MX9.5-2
ssh root@${SMTPHost1}  'cat /dev/null > /opt/imail2/log/mta.log'
ssh root@${SMTPHost2}  'cat /dev/null > /opt/imail2/log/mta.log'

#Doing SMTP operations

exec 3<>/dev/tcp/$SMTPHost1/$SMTPPort1
#echo -en "xclp 10.37.2.214\r\n" >&3
echo -en "auth login\r\n" >&3
echo -en "cHJvY3UxQG9wZW53YXZlLmNvbQ==\r\n" >&3
echo -en "cA==\r\n" >&3
echo -en "xclp 10.37.2.214\r\n" >&3
echo -en "mail from:$wrongfrom\r\n" >&3
echo -en "mail from:$correctfrom\r\n" >&3
echo -en "rcpt to:$rcptto\r\n" >&3
echo -en "data\r\n" >&3
echo -en "`echo -n $message`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-

cat smtp-temp.log

#Now gether smtp logs from MX9.5-1 and MX9.5-2
ssh root@$SMTPHost1  'cat /opt/imail2/log/mta.log' > mta1.log
ssh root@$SMTPHost2  'cat /opt/imail2/log/mta.log' > mta2.log

#Prepare the summary-smtp.log
echo -e  "The smtp operations logs telneting to MX9.5-1:\n\n" >summary-smtp.log
cat smtp-temp.log >>summary-smtp.log
echo -e "\n\n" >>summary-smtp.log
echo -e "\n\nSMTPserv.log from MX9.5-1:\n"
cat mta1.log
echo -e "\n\nSMTPserv.log from MX9.5-2:\n"
cat mta2.log
echo -e "\n\nSMTPserv.log from MX9.5-1:\n" >>summary-smtp.log
cat mta1.log >>summary-smtp.log
echo -e "\n\nSMTPserv.log from MX9.5-2:\n" >>summary-smtp.log
cat mta2.log >>summary-smtp.log
#analyze    
c1=`grep -E "$targett1" mta1.log|wc -l`
c2=`grep -E "$targett1" mta2.log|wc -l`
let cc1=c1+c2
if (( $cc1 == 12 ))
then
  echo -ne "\n\033[32m#####Logging enhancement for SMTP Relay is ok!!##### \033[0m\n\n"
  echo -ne "\n\033[32m#####Logging enhancement for SMTP Relay is ok!!##### \033[0m\n\n" >>summary-smtp.log
  echo -ne "\n\033[32m#####Logging enhancement for SMTP Relay is ok!!##### \033[0m\n\n" >>outcome.log
else
  echo -ne "\n\033[31m#####Logging enhancement for SMTP Relay not ok!!##### \033[0m\n\n"
  echo -ne "\n\033[31m#####Logging enhancement for SMTP Relay not ok!!##### \033[0m\n\n" >>summary-smtp.log
  echo -ne "\n\033[31m#####Logging enhancement for SMTP Relay not ok!!##### \033[0m\n\n" >>outcome.log
fi



#delete all tests accounts:
echo -e "\n\n########################## delete all tests accounts: ###############################"
curl -s -X DELETE "http://$mos1/mxos/mailbox/v2/$testaccount1/"|jq .
curl -s -X DELETE "http://$mos1/mxos/mailbox/v2/$testaccount2/"|jq .
curl -s -X DELETE "http://$mos2/mxos/mailbox/v2/$testaccount1/"|jq .
curl -s -X DELETE "http://$mos2/mxos/mailbox/v2/$testaccount2/"|jq .

#revert all the editted keys
echo -e "\n\n########################## revert all the editted keys ###############################"
#(1)Mx9.5-1 IMAP/POP setting:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/imapserv/ImapProxyAuthenticate";imconfcontrol -install -key "/*/imapserv/imapProxyHost= ";imconfcontrol -install -key "/*/imapserv/imapProxyPort= ";imconfcontrol -install -key "/*/popserv/popProxyHost= ";imconfcontrol -install -key "/*/popserv/popProxyPort= "\""
#(2)9.5-1 MTA setting:
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/mta/mtaProxyAuthentication";imconfcontrol -install -key "/*/mta/requireAuthentication";imconfcontrol -install -key "/*/mta/mtaProxyUnknownAccount";imconfcontrol -install -key "/*/mta/mtaProxyUnknownTarget= ";imconfcontrol -install -key "/inbound-standardmta-direct/mta/requireAuthentication";imconfcontrol -install -key "/*/mta/relaySourcePolicy= ";imconfcontrol -install -key "/inbound-standardmta-direct/mta/relaySourcePolicy= ";imconfcontrol -install -key "/*/mxos/defaultPasswordStoreType=sha512"\""
#(3)9.5-2 MTA setting:
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/mta/requireAuthentication";imconfcontrol -install -key "/inbound-standardmta-direct/mta/requireAuthentication";imconfcontrol -install -key "/*/mta/relaySourcePolicy= ";imconfcontrol -install -key "/inbound-standardmta-direct/mta/relaySourcePolicy= ";imconfcontrol -install -key "/*/mxos/defaultPasswordStoreType=sha512"\""
#(3-2)9.5-2 disable XCLP
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/allowXCLP";imconfcontrol -install -key "/*/improxy/sendClientIp";imconfcontrol -install -key "/*/imapserv/allowXCLP";imconfcontrol -install -key "/*/imapserv/enableOutboundXCLP";imconfcontrol -install -key "/*/imapserv/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/imapserv/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/imapserv/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/enableOutboundXCLP";imconfcontrol -install -key "/*/mta/allowXCLP";imconfcontrol -install -key "/*/mta/enableOutboundXCLP";imconfcontrol -install -key "/*/mta/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/mta/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/mta/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/mta/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/mta/enableOutboundXCLP";imconfcontrol -install -key "/*/popserv/allowXCLP";imconfcontrol -install -key "/*/popserv/enableOutboundXCLP";imconfcontrol -install -key "/*/popserv/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/popserv/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/popserv/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/enableOutboundXCLP";imconfcontrol -install -key "/*/common/xclpAllowedIPs= "\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/allowXCLP";imconfcontrol -install -key "/*/improxy/sendClientIp";imconfcontrol -install -key "/*/imapserv/allowXCLP";imconfcontrol -install -key "/*/imapserv/enableOutboundXCLP";imconfcontrol -install -key "/*/imapserv/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/imapserv/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/imapserv/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/imapserv/enableOutboundXCLP";imconfcontrol -install -key "/*/mta/allowXCLP";imconfcontrol -install -key "/*/mta/enableOutboundXCLP";imconfcontrol -install -key "/*/mta/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/mta/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/mta/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/mta/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/mta/enableOutboundXCLP";imconfcontrol -install -key "/*/popserv/allowXCLP";imconfcontrol -install -key "/*/popserv/enableOutboundXCLP";imconfcontrol -install -key "/*/popserv/outboundXCLPExpectsReply";imconfcontrol -install -key "/*/popserv/XclpAllowedIPs= ";imconfcontrol -install -key "/92SITE2-inbound-standardmta-direct/popserv/XclpAllowedIPs= ";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/allowXCLP";imconfcontrol -install -key "/inbound-standardmta-direct/popserv/enableOutboundXCLP";imconfcontrol -install -key "/*/common/xclpAllowedIPs= "\""
#（3-3） restart FEPs
ssh root@${FEPHost1} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
ssh root@${FEPHost2} "su - ${imailuser} -c \"/opt/imail2/lib/imservctrl killStart\""
#display outcome:
echo -e "\n\n################################# The outcome of tests: ##############################\n"
cat outcome.log


#clear all temp logs
rm -rf  imap-temp.log 