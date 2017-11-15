#!/bin/bash
for dir in `find . -maxdepth 1 -type d`
do 
echo $dir
if [ $dir = . ];then
  echo hello
else
	cd $dir 
  echo "#!/bin/bash" > run.sh
  chmod +x *.sh
  echo "./logic-messagesend-IMAP-append-7bit.sh" >> run.sh 
  echo "./logic-messagesend-IMAP-append-8bit.sh" >> run.sh
  echo "./logic-messagesend-IMAP-append-base64.sh" >> run.sh
  echo "./logic-messagesend-IMAP-append-quoted.sh" >> run.sh   
  echo "./logic-messagesend-SMTP-7bit.sh" >> run.sh
  echo "./logic-messagesend-SMTP-8bit.sh" >> run.sh
  echo "./logic-messagesend-SMTP-base64.sh" >> run.sh
  echo "./logic-messagesend-SMTP-quoted.sh" >> run.sh
	cd ..
fi
done
