#!/bin/bash
number=27
#for ((i=1;i<$number;i++))
#do
    

    
    cat message1-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-7bit.txt
    
    cat message1-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-8bit.txt
    

    
    base64  message1-7bit.txt >message1-base64.txt  				      #create base64 smtp messagess
    
    cat message1-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-base64.txt
    
    recode  ../qp  < message1-7bit.txt  >message1-quoted.txt     #create quoted-printable smtp messages,need install recode
    #cat message1-quoted.txt
   # num=`grep "=0D" message1-quoted.txt|wc -l`
   # if [ $num -eq 0 ];then
   #   echo hello
   # else
     # cat message1-quoted.txt
   #paste -d "" -s < message1-quoted.txt >tttt.txt
   #cp  tttt.txt  message1-quoted.txt
      #cat message1-quoted.txt
   # fi
    
    sed -i 's/=0D//g'  message1-quoted.txt
    cat message1-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-quoted.txt
   
    #cat message1-quoted.txt | perl -pe 'chop if eof' >tttt.txt
    #cp  tttt.txt  message1-quoted.txt
    
    #unix2dos   header-7bit.txt
    #unix2dos   header-8bit.txt
    #unix2dos   header-base64.txt
    #unix2dos   header-quoted.txt
    cat  header-7bit.txt     message1-7bit.txt > message-append1-7bit.txt       #7bit
    cat  header-8bit.txt     message1-8bit.txt > message-append1-8bit.txt       #8bit
    cat  header-base64.txt   message1-base64.txt > message-append1-base64.txt  	#create base64 smtp messagess
    cat  header-quoted.txt   message1-quoted.txt > message-append1-quoted.txt   #create quoted-printable smtp messages,need install recode

    
    cat message-append1-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append1-7bit.txt
    cat message-append1-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append1-8bit.txt
    cat message-append1-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append1-base64.txt
    
    
    cat message-append1-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append1-quoted.txt 
    
    
    cat message1-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-7bit.txt
    
    cat message1-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-8bit.txt
    
    cat message1-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-quoted.txt
    
    cat message1-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message1-base64.txt
    
    unix2dos  message1-7bit.txt
    unix2dos  message1-8bit.txt
    unix2dos   message1-base64.txt
    unix2dos   message1-quoted.txt
    
    unix2dos  message-append1-7bit.txt
    unix2dos  message-append1-8bit.txt
    unix2dos  message-append1-base64.txt
    unix2dos  message-append1-quoted.txt
    
#done