#!/bin/bash
IMAPHost=172.26.202.87
IMAPPort=20143
SMTPHost=172.26.202.87
SMTPPort=20025
user=imail2
deleteuser=xx1@openwave.com

ssh root@${IMAPHost} "su - ${user} -c \"immsgdelete   $deleteuser  -all\""
echo "!!!!!!!!!!!!!!!!!!!!!!message delete successfully!!!!!!!!!!!!!!!!!"

exec 3<>/dev/tcp/$SMTPHost/$SMTPPort
echo -en "mail from:xx2\r\n" >&3
echo -en "rcpt to:xx1\r\n" >&3
echo -en "data\r\n" >&3
echo -en "`cat message.txt`\r\n" >&3
echo -en ".\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >smtp-temp.log
exec 3>&-

cat smtp-temp.log



exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
echo -en "a login xx1 p\r\n" >&3
echo -en "a select inbox\r\n" >&3
echo -en "a fetch 1 rfc822\r\n" >&3
echo -en "a logout\r\n" >&3
cat <&3 >imap-temp.log
exec 3>&-
cat imap-temp.log
rm -rf  smtp-temp.log
rm -rf  imap-temp.log