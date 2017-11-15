#!/bin/bash

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# (1)enable this key before testing : /*/common/enableXFIRSTLINE: [true]
# (2)create xx1@openwave.com and xx2@openwave.com  and make sure using xx1 and xx2  can connect to IMAP and POP
# (3)let testmaiche can ssh ro FEP servers without inputting passwords
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#summary function
function summary (){
echo "Execued test cases:"
cp  all-summary.log   my.log
cat my.log
successcount=`grep -i success  my.log|wc -l`
echo "success:$success"
failedcount=`grep -i failed my.log|wc -l`
echo "failed:$failedcount"
let totalcount=$successcount+$failedcount
echo "total: $totalcount"
echo  -e "===================Test SUmmary==============================\n\n"
echo "Total   testcases are:$totalcount"
echo "Success testcases are:$successcount"
echo "Failed  testcases are:$failedcount"
echo "Total  testcases  are:$totalcount" >>all-summary.log
echo "Success testcases are:$successcount" >>all-summary.log
echo "Failed  testcases are:$failedcount" >>all-summary.log
#exit 1
}
#trap summary SIGHUP SIGINT SIGTERM

#clear all-summary.log

FEPHost1=172.26.202.87
imailuser=imail2
mos=172.26.203.123:8081
allsumfile=all-summary.log
if [ -f "$allsumfile" ]
then
	cat /dev/null >$allsumfile
fi

#enable XFIRSTLINE key
num=52
ssh root@${FEPHost1} "su - ${imailuser} -c \"imconfcontrol -install -key "/*/common/enableXFIRSTLINE=true"\""
#create users
curl -s -X PUT -d "cosId=default&password=p" "http://$mos/mxos/mailbox/v2/xx1@openwave.com"|jq .
curl -s -X PUT -d "cosId=default&password=p" "http://$mos/mxos/mailbox/v2/xx2@openwave.com"|jq .

#DEFINE TEST CASES
#text/plain
t1="IMAP-and-SMTP-ASCII-chars-CRLF"
t2="IMAP-and-SMTP-Chinese-UTF8-CRLF"
t3="IMAP-and-SMTP-Chinese-GB2312-CRLF"
t4="IMAP-and-SMTP-Japanese-UTF8-CRLF"
t5="IMAP-and-SMTP-Japanese-EUC-JP-CRLF"
t6="IMAP-and-SMTP-Japanese-Shift_JIS-CRLF"
t7="IMAP-and-SMTP-Japanese-GB2312-CRLF"
t8="IMAP-and-SMTP-Arabic-UTF8-CRLF"
t9="IMAP-and-SMTP-Arabic-ISO-8859-6-CRLF "
t10="IMAP-and-SMTP-mixed-UTF-8-language"

#attachments (with message body or without)
t11="Type-attachment-pure-audio-IMAP-SMTP"
t12="Type-attachment-pure-image-IMAP-SMTP"
t13="Type-attachment-pure-pdf-IMAP-and-SMTP"
t14="Type-attachment-pure-python-IMAP-and-SMTP"
t15="Type-attachment-pure-tar-IMAP-and-SMTP"
t16="Type-attachment-pure-txt-IMAP-and-SMTP"
t17="Type-attachment-pure-video-IMAP-SMTP"
t18="Type-attachment-pure-virus-IMAP-and-SMTP"
t19="Type-attachment-audio-texts-IMAP-SMTP"
t20="Type-attachment-images-with-texts-IMAP-SMTP"
t21="Type-attachment-pdf-texts-IMAP-and-SMTP"
t22="Type-attachment-python-Texts-IMAP-and-SMTP"
t23="Type-attachment-tar-with-text-IMAP-and-SMTP"
t24="Type-attachment-txt-with-text-content-IMAP-and-SMTP"
t25="Type-attachment-video-with-texts-IMAP-SMTP"
t26="Type-attachment-virus-with-texts-IMAP-SMTP"

#formats message body
t27="Type-blac-bg-with-no-texts-IMAP-and-SMTP"
t28="Type-black-bg-with-huge-fonts-IMAP-andSMTP"
t29="Type-black-bg-with-mixed-style-texts-IMAP-and-SMTP"
t30="Type-black-bg-with-texts-IMAP-and-SMTP"

#Emoji
t31="Type-char-Emoji-IMAP-and-SMTP"
t32="Type-char-Emoji-UTF-8-text-IMAP-and-SMTP"
t33="Type-image-Emoji-IMAP-and-SMTP"
t34="Type-image-Emoji-UTF-8-text-IMAP-and-SMTP"

#Special messagebody contents
t35="Type-C-content-in-body-IMAP-SMTP"
t36="Type-C-content-with-normal-texts-IMAP-SMTP"
t37="Type-html-content-IMAP-SMTP"
t38="Type-HTML-contents-IMAP-and-SMTP"
t39="Type-HTML-contents-with-mixed-texts-IMAP-and-SMTP"
t40="Type-html-content-with-texts-IMAP-SMTP"
t41="Type-hyperlink-with-mixed-texts-IMAP-and-SMTP"
t42="Type-image-alternate-text-IMAP-and-SMTP"
t43="Type-image-UTF-8-Arabic-messagebody-IMAP-and-SMTP"
t44="Type-image-UTF-8-Chinese-messagebody-IMAP-and-SMTP"
t45="Type-image-UTF-8-English-message-body-IMAP-and-SMTP"
t46="Type-image-UTF-8-Japanese-messagebody-IMAP-and-SMTP"
t47="Type-image-UTF-8-mixed-texts-messagebody-IMAP-and-SMTP"
t48="Type-pure-hyperlink-IMAP-and-SMTP"
t49="Type-pure-image-messagebody-IMAP-and-SMTP"
t50="type-symbols-UTF8-IMAP-and-SMTP"
t51="Type-virus-code-IMAP-and-SMTP"
t52="Type-virus-code-with-texts-IMAP-and-SMTP"


chmod -R +x *.sh

#trap for error and ctrl+c and call cleanup fucntion,whill run cleanup command,once receiving 

		
echo -e  "-------------------------------------Test Process-------------------------------------\n\n">all-summary.log

echo -en "\n" >>all-summary.log

for (( i=1;i<=$num;i++ ))
do
#print test scope name
if (( i==1 ));then
  echo "##############################################" 
  echo "######   Test/Plain  Testing #################"
  echo "##############################################"
  echo 
  echo "##############################################" >>all-summary.log
  echo "######   Test/Plain  Testing #################" >>all-summary.log
  echo "##############################################" >>all-summary.log
  echo 
  
elif (( i==11 ));then
  echo "##############################################" 
  echo "######  Attachments with #####################"
  echo "##############################################"
  echo 
  echo "##############################################" >>all-summary.log
  echo "######  Attachments with  ####################" >>all-summary.log
  echo "##############################################" >>all-summary.log
  echo 
elif (( i==27 ));then
  echo "##############################################" 
  echo "###### Formats message body###################"
  echo "##############################################"
  echo 
  echo "##############################################" >>all-summary.log
  echo "###### Formats message body ##################" >>all-summary.log
  echo "##############################################" >>all-summary.log
  echo 
elif (( i==31 ));then
  echo "##############################################" 
  echo "################### Emoji ####################"
  echo "##############################################"
  echo 
  echo "##############################################" >>all-summary.log
  echo "################### Emoji ####################" >>all-summary.log
  echo "##############################################" >>all-summary.log
  echo 
elif (( i==35 ));then
  echo "##############################################" 
  echo "######## Special messagebody contents ########"
  echo "##############################################"
  echo 
  echo "##############################################" >>all-summary.log
  echo "######## Special messagebody contents ########" >>all-summary.log
  echo "##############################################" >>all-summary.log
  echo 
fi

temp=t`echo $i`
echo -e "================${!temp} Testing===============\n"
echo    "================${!temp} Testing===============" >>all-summary.log 
cd ${!temp}
pathtemp=`pwd`
path=`echo $pathtemp|awk -F "/" '{print $11}'`
echo -e "====current path is:$path================\n"
echo    "====current path is:$path================" >>../all-summary.log 
echo -e "====running logic-messagesend-IMAP-append-7bit ========\n"
echo    "====running logic-messagesend-IMAP-append-7bit ========" >>../all-summary.log 
bash logic-messagesend-IMAP-append-7bit.sh
echo -e "====running logic-messagesend-IMAP-append-8bit ========\n"
echo  "====running logic-messagesend-IMAP-append-8bit ========" >>../all-summary.log 
bash logic-messagesend-IMAP-append-8bit.sh
echo -e "====running logic-messagesend-IMAP-append-base64 ========\n"
echo  "====running logic-messagesend-IMAP-append-base64 ========" >>../all-summary.log 
bash logic-messagesend-IMAP-append-base64.sh
echo -e "====running logic-messagesend-IMAP-append-quoted-printable ========\n"
echo  "====running logic-messagesend-IMAP-append-quoted-printable ========" >>../all-summary.log 
bash logic-messagesend-IMAP-append-quoted.sh
echo -e "====running logic-messagesend-SMTP-7bit ========\n"
echo  "====running logic-messagesend-SMTP-7bit ========" >>../all-summary.log 
bash logic-messagesend-SMTP-7bit.sh
echo -e "====running logic-messagesend-SMTP-8bit ========\n"
echo  "====running logic-messagesend-SMTP-8bit ========" >>../all-summary.log 
bash logic-messagesend-SMTP-8bit.sh
echo -e "====running logic-messagesend-SMTP-base64 ========\n"
echo  "====running logic-messagesend-SMTP-base64 ========" >>../all-summary.log 
bash logic-messagesend-SMTP-base64.sh
echo -e "====running logic-messagesend-SMTP-quoted-printable ========\n"
echo  "====running logic-messagesend-SMTP-quoted-printable ========" >>../all-summary.log 
bash logic-messagesend-SMTP-quoted.sh
echo -e "================${!temp} Test finished===============\n"
echo  "================${!temp} Test finished===============" >>../all-summary.log 
cd ..

done

echo -e "\n\n"
echo   >>all-summary.log

echo -e "====================Test Results=============================\n\n"
cat all-summary.log



#delete users
curl -s -X DELETE  "http://$mos/mxos/mailbox/v2/xx1@openwave.com"|jq .
curl -s -X DELETE  "http://$mos/mxos/mailbox/v2/xx2@openwave.com"|jq .

# Test summary
echo  -e "===================Test SUmmary==============================\n\n"
summary