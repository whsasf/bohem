#!/bin/bash
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-7bit.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-8bit.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-base64.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-quoted.sh


cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-7bit.sh 
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-8bit.sh
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-base64.sh 
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-quoted.sh


name=`ls -al |grep messagebody. |awk  '{print $9}'|awk -F . '{print $1}'`
#echo $name
cp $name.txt  $name-IMAP-7bit.txt
cp $name.txt  $name-IMAP-8bit.txt
cp $name.txt  $name-IMAP-base64.txt
cp $name.txt  $name-IMAP-quoted.txt

cp $name.txt  $name-SMTP-7bit.txt
cp $name.txt  $name-SMTP-8bit.txt
cp $name.txt  $name-SMTP-base64.txt
cp $name.txt  $name-SMTP-quoted.txt

sed -i '/From:/d' $name-SMTP-7bit.txt
sed -i '/To:/d' $name-SMTP-7bit.txt

sed -i '/From:/d' $name-SMTP-8bit.txt
sed -i '/To:/d' $name-SMTP-8bit.txt

sed -i '/From:/d' $name-SMTP-base64.txt
sed -i '/To:/d' $name-SMTP-base64.txt

sed -i '/From:/d' $name-SMTP-quoted.txt
sed -i '/To:/d' $name-SMTP-quoted.txt

base64  message.txt >message-base64.txt  				      #create base64 smtp messagess
recode  ../qp  < message.txt  >message-quoted.txt     #create quoted-printable smtp messages,need install recode


sed -i  's/'$name'/'$name'-IMAP-7bit/g'  logic-messagesend-IMAP-append-7bit.sh
sed -i  's/'$name'/'$name'-IMAP-8bit/g'  logic-messagesend-IMAP-append-8bit.sh
sed -i  's/'$name'/'$name'-IMAP-base64/g'  logic-messagesend-IMAP-append-base64.sh
sed -i  's/'$name'/'$name'-IMAP-quoted/g'  logic-messagesend-IMAP-append-quoted.sh


sed -i  's/'$name'/'$name'-SMTP-7bit/g'  logic-messagesend-SMTP-7bit.sh
sed -i  's/'$name'/'$name'-SMTP-8bit/g'  logic-messagesend-SMTP-8bit.sh
sed -i  's/'$name'/'$name'-SMTP-base64/g'  logic-messagesend-SMTP-base64.sh
sed -i  's/'$name'/'$name'-SMTP-quoted/g'  logic-messagesend-SMTP-quoted.sh


linenu=`grep -n charset  $name-IMAP-7bit.txt |awk -F : '{print $1}'|head -n 1 `
#echo $linenu
let newline=$linenu+1
#echo $newline
sed -i ''$newline'd' $name-IMAP-7bit.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: 7bit'  $name-IMAP-7bit.txt

linenu=`grep -n charset  $name-IMAP-8bit.txt |awk -F : '{print $1}'|head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-IMAP-8bit.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: 8bit'  $name-IMAP-8bit.txt

linenu=`grep -n charset  $name-IMAP-base64.txt |awk -F : '{print $1}'|head -n 1  `
let newline=$linenu+1
sed -i ''$newline'd' $name-IMAP-base64.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: base64'  $name-IMAP-base64.txt

linenu=`grep -n charset  $name-IMAP-quoted.txt |awk -F : '{print $1}'|head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-IMAP-quoted.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: quoted-printable'  $name-IMAP-quoted.txt


linenu=`grep -n charset  $name-SMTP-7bit.txt |awk -F : '{print $1}' |head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-SMTP-7bit.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: 7bit'  $name-SMTP-7bit.txt

linenu=`grep -n charset  $name-SMTP-8bit.txt |awk -F : '{print $1}'|head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-SMTP-8bit.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: 8bit'  $name-SMTP-8bit.txt

linenu=`grep -n charset  $name-SMTP-base64.txt |awk -F : '{print $1}'|head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-SMTP-base64.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: base64'  $name-SMTP-base64.txt

linenu=`grep -n charset  $name-SMTP-quoted.txt |awk -F : '{print $1}'|head -n 1`
let newline=$linenu+1
sed -i ''$newline'd' $name-SMTP-quoted.txt
sed -i ''$linenu'a\Content-Transfer-Encoding: quoted-printable'  $name-SMTP-quoted.txt



