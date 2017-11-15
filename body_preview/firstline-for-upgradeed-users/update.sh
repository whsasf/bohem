#!/bin/bash

#function to delete line iwth this contents: #DATA=`cat message$i.txt`

#function dele()
#{
#xx=`grep -n "#DATA="   logic-messagesend-SMTP.sh |awk -F : '{print $1}'`
#echo $xx
#if [ "$xx" -eq 0 ];then
#   echo "can not find,do nothing!"
#else
#   sed -i '$xxd' logic-messagesend-SMTP.sh
#   echo "find,delete finished"
#fi
#}
#dele
#delete some old files:
#rm -rf logic-messagesend-IMAP-append-*.sh
#rm -rf logic-messagesend-SMTP-*.sh

#delete line iwth this contents: #DATA=`cat message$i.txt`
cp logic-messagesend-SMTP.sh        logic-messagesend-SMTP.sh.bak
cp logic-messagesend-IMAP-append.sh logic-messagesend-IMAP-append.sh.bak
sed -i '/#DATA=/d' logic-messagesend-SMTP.sh

#delete the current headers in smtp sh
sed -i '/MIME-Version/d' logic-messagesend-SMTP.sh
sed -i '/Content-Type/d' logic-messagesend-SMTP.sh
sed -i '/Content-Transfer-Encoding/d' logic-messagesend-SMTP.sh



#change this number everytime
##############################
number=2                    #
##############################

##########################################################################
subject1=testemail-mixd-UTF-8-CRLF-7bit                                       #
subject2=testemail-mixd-UTF-8-CRLF-8bit                                       #
subject3=testemail-mixd-UTF-8-CRLF-base64                                     #
subject4=testemail-mixd-UTF-8-CRLF-quoted-printable                           #
charsets=utf-8                                                           #
##########################################################################

#create headers
#create 7bit-header:                                                     
echo "from:xx2@openwave.com" >header-7bit.txt                            
echo "to:xx1@openwave.com" >>header-7bit.txt                                                   
echo "subject:$subject1" >>header-7bit.txt               
echo "MIME-Version: 1.0" >>header-7bit.txt                               
echo "Content-Type: text/plain; charset=$charsets" >>header-7bit.txt         
echo -e "Content-Transfer-Encoding: 7bit\n" >>header-7bit.txt                 
                                                                         
#create header-8bit:                                                     
echo "from:xx2@openwave.com" >header-8bit.txt                          
echo "to:xx1@openwave.com" >>header-8bit.txt                                                     
echo "subject:$subject2" >>header-8bit.txt               
echo "MIME-Version: 1.0" >>header-8bit.txt                               
echo "Content-Type: text/plain; charset=$charsets" >>header-8bit.txt         
echo -e "Content-Transfer-Encoding: 8bit\n" >>header-8bit.txt                 
                                                                         
#create header-base64:                                                   
echo "from:xx2@openwave.com" >header-base64.txt
echo "to:xx1@openwave.com" >>header-base64.txt                                                 
echo "subject:$subject3" >>header-base64.txt                             
echo "MIME-Version: 1.0" >>header-base64.txt                             
echo "Content-Type: text/plain; charset=$charsets" >>header-base64.txt   
echo -e "Content-Transfer-Encoding: base64\n" >>header-base64.txt             
                                                                         
#create quoted-printable-header:                                         
echo "from:xx2@openwave.com" >header-quoted.txt                          
echo "to:xx1@openwave.com" >>header-quoted.txt                                                 
echo "subject:$subject4" >>header-quoted.txt                             
echo "MIME-Version: 1.0" >>header-quoted.txt                             
echo "Content-Type: text/plain; charset=$charsets" >>header-quoted.txt          
echo -e "Content-Transfer-Encoding: quoted-printable\n" >>header-quoted.txt     

#creating sh files 
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-7bit.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-8bit.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-base64.sh
cp logic-messagesend-IMAP-append.sh  logic-messagesend-IMAP-append-quoted.sh

cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-7bit.sh 
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-8bit.sh
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-base64.sh 
cp logic-messagesend-SMTP.sh   logic-messagesend-SMTP-quoted.sh


#add some variables
sed -i '/#!/a\subject1=testemail-mixd-UTF-8-CRLF-7bit\nsubject2=testemail-mixd-UTF-8-CRLF-8bit\nsubject3=testemail-mixd-UTF-8-CRLF-base64\nsubject4=testemail-mixd-UTF-8-CRLF-quoted-printable\ncharsets=utf-8\n'  logic-messagesend-SMTP-*.sh 

#create smtp messages 
for ((i=1;i<$number;i++))
do
    cp  message$i.txt message$i-7bit.txt        				      #7bit
    cp  message$i.txt message$i-8bit.txt         		  	      #8bit
    base64  message$i.txt >message$i-base64.txt  				      #create base64 smtp messagess
    recode  ../qp  < message$i.txt  >message$i-quoted.txt     #create quoted-printable smtp messages,need install recode
done

#echo -en "\n" >>message1-7bit.txt
#echo -en "\n" >>message1-8bit.txt
#echo -en "\n" >>message1-base64.txt
#echo -en "\n" >>message1-quoted.txt

#create IMAP-append messages
for ((i=1;i<$number;i++))
do
    cat  header-7bit.txt     message$i-7bit.txt > message-append$i-7bit.txt       #7bit
    cat  header-8bit.txt     message$i-8bit.txt > message-append$i-8bit.txt       #8bit
    cat  header-base64.txt   message$i-base64.txt > message-append$i-base64.txt  	#create base64 smtp messagess
    cat  header-quoted.txt   message$i-quoted.txt > message-append$i-quoted.txt   #create quoted-printable smtp messages,need install recode
done

#edit smtp sh files -logic-messagesend-SMTP-7bit.sh
sed -i '/Subject/s/echo/#echo/g'  logic-messagesend-SMTP-7bit.sh  #change
sed -i '/Subject/a\  echo -en "subject:$subject1\\r\\n" >&3\n  echo -en "MIME-Version: 1.0\\r\\n" >&3\n  echo -en "Content-Type: text/plain; charset=$charsets\\r\\n" >&3\n  echo -en "Content-Transfer-Encoding: 7bit\\r\\n" >&3'  logic-messagesend-SMTP-7bit.sh  #add
sed -i  '/cat mixed-UTF8-language/s/mixed-UTF8-language-messagebody.txt/message$i-7bit.txt/g'  logic-messagesend-SMTP-7bit.sh

#edit smtp sh files -logic-messagesend-SMTP-8bit.sh
sed -i '/Subject/s/echo/#echo/g'  logic-messagesend-SMTP-8bit.sh  #change
sed -i '/Subject/a\  echo -en "subject:$subject2\\r\\n" >&3\n  echo -en "MIME-Version: 1.0\\r\\n" >&3\n  echo -en "Content-Type: text/plain; charset=$charsets\\r\\n" >&3\n  echo -en "Content-Transfer-Encoding: 8bit\\r\\n" >&3'  logic-messagesend-SMTP-8bit.sh  #add
sed -i  '/cat mixed-UTF8-language/s/mixed-UTF8-language-messagebody.txt/message$i-8bit.txt/g'  logic-messagesend-SMTP-8bit.sh

#edit smtp sh files -logic-messagesend-SMTP-base64.sh
sed -i '/Subject/s/echo/#echo/g'  logic-messagesend-SMTP-base64.sh  #change
sed -i '/Subject/a\  echo -en "subject:$subject3\\r\\n" >&3\n  echo -en "MIME-Version: 1.0\\r\\n" >&3\n  echo -en "Content-Type: text/plain; charset=$charsets\\r\\n" >&3\n  echo -en "Content-Transfer-Encoding: base64\\r\\n" >&3'  logic-messagesend-SMTP-base64.sh  #add
sed -i  '/cat mixed-UTF8-language/s/mixed-UTF8-language-messagebody.txt/message$i-base64.txt/g'  logic-messagesend-SMTP-base64.sh

#edit smtp sh files -logic-messagesend-SMTP-quoted-printable.sh
sed -i '/Subject/s/echo/#echo/g'  logic-messagesend-SMTP-quoted.sh  #change
sed -i '/Subject/a\  echo -en "subject:$subject4\\r\\n" >&3\n  echo -en "MIME-Version: 1.0\\r\\n" >&3\n  echo -en "Content-Type: text/plain; charset=$charsets\\r\\n" >&3\n  echo -en "Content-Transfer-Encoding: quoted-printable\\r\\n" >&3'  logic-messagesend-SMTP-quoted.sh  #add
sed -i  '/cat mixed-UTF8-language/s/mixed-UTF8-language-messagebody.txt/message$i-quoted.txt/g'  logic-messagesend-SMTP-quoted.sh


#edit imap sh files -logic-messagesend-IMAP-append-7bit.sh
sed -i 's/mixed-UTF8-language-messagebody/message-append$i-7bit/g'  logic-messagesend-IMAP-append-7bit.sh  #change
#edit imap sh files -logic-messagesend-IMAP-append-8bit.sh
sed -i 's/mixed-UTF8-language-messagebody/message-append$i-8bit/g'  logic-messagesend-IMAP-append-8bit.sh  #change
#edit imap sh files -logic-messagesend-IMAP-append-base64.sh
sed -i 's/mixed-UTF8-language-messagebody/message-append$i-base64/g'  logic-messagesend-IMAP-append-base64.sh  #change
#edit imap sh files -logic-messagesend-IMAP-append-quoted.sh
sed -i 's/mixed-UTF8-language-messagebody/message-append$i-quoted/g'  logic-messagesend-IMAP-append-quoted.sh  #change




#edit imap sh files