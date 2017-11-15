#!/bin/bash
number=27
for ((i=2;i<$number;i++))
do
    

    
    cat message$i-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-7bit.txt
    
    cat message$i-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-8bit.txt
    

    
    base64  message$i-7bit.txt >message$i-base64.txt  				      #create base64 smtp messagess
    
    cat message$i-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-base64.txt
    
    recode  ../qp  < message$i-7bit.txt  >message$i-quoted.txt     #create quoted-printable smtp messages,need install recode
    #cat message$i-quoted.txt
    num=`grep "=0D" message$i-quoted.txt|wc -l`
    if [ $num -eq 0 ];then
      echo hello
    else
     # cat message$i-quoted.txt
      paste -d "" -s < message$i-quoted.txt >tttt.txt
      cp  tttt.txt  message$i-quoted.txt
      #cat message$i-quoted.txt
    fi
    
    sed -i 's/=0D/=0D=0A/g'   message$i-quoted.txt
    cat message$i-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-quoted.txt
   
   
    #unix2dos   header-7bit.txt
    #unix2dos   header-8bit.txt
    #unix2dos   header-base64.txt
    #unix2dos   header-quoted.txt
    cat  header-7bit.txt     message$i-7bit.txt > message-append$i-7bit.txt       #7bit
    cat  header-8bit.txt     message$i-8bit.txt > message-append$i-8bit.txt       #8bit
    cat  header-base64.txt   message$i-base64.txt > message-append$i-base64.txt  	#create base64 smtp messagess
    cat  header-quoted.txt   message$i-quoted.txt > message-append$i-quoted.txt   #create quoted-printable smtp messages,need install recode

    
    cat message-append$i-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append$i-7bit.txt
    cat message-append$i-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append$i-8bit.txt
    cat message-append$i-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append$i-base64.txt
    
    
    cat message-append$i-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message-append$i-quoted.txt 
    
    
    cat message$i-7bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-7bit.txt
    
    cat message$i-8bit.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-8bit.txt
    
    cat message$i-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-quoted.txt
    
    cat message$i-base64.txt | perl -pe 'chomp if eof' >tttt.txt
    cp  tttt.txt  message$i-base64.txt
    
    unix2dos  message$i-7bit.txt
    unix2dos  message$i-8bit.txt
    unix2dos   message$i-base64.txt
    unix2dos   message$i-quoted.txt
    
    unix2dos  message-append$i-7bit.txt
    unix2dos  message-append$i-8bit.txt
    unix2dos  message-append$i-base64.txt
    unix2dos  message-append$i-quoted.txt
    
done