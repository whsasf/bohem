#!/bin/bash

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# (1)enable this key before testing : /*/common/enableXFIRSTLINE: [true]
# (2)create xx1@openwave.com and xx2@openwave.com  and make sure using xx1 and xx2  can connect to IMAP and POP
# (3)let testmaiche can ssh ro FEP servers without inputting passwords
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#clear all-summary.log

allsumfile=all-summary.log
if [ -f "$allsumfile" ]
then
	cat /dev/null >$allsumfile
fi

t1="ASCII-CRLF testing"
t2="ASCII-LF   testing"
t3="Chinese-UTF8-CRLF    Testing"
t4="Chinese-UTF8-LF      Testing"
t5="Chinese-GBK-CRLF     Testing"
t6="Chinese-GBK-LF       Testing"
t7="Japanese-UTF8-CRLF   Testing"
t8="Japanese-UTF8-LF     Testing"
t9="Japanese-EUC-JP-CRLF Testing"
t10="Japanese-EUC-JP-LF   Testing"
t11="Japanese-Shift_JIS-CRLF Testing"
t12="Japanese-Shift_JIS-LF   Testing"
t13="Japanese-GBK-CRLF  Testing"
t14="Japanese-GBK-LF    Testing"
t15="Arabic-UTF8-CRLF   Testing"
t16="Arabic-UTF8-LF     Testing"
t17="Arabic-ISO-8859-6-CRLF  Testing"
t18="Arabic-ISO-8859-6-LF    Testing"
t19="IMAP-and-SMTP-mixed-UTF-8-language Testing"
t20="Type-symbols-UTF8-IMAP-and-SMTP   Testing"
t21="Type-char-Emoji-IMAP-and-SMTP     Testing"
t22="Type-char-Emoji-UTF-8-text-IMAP-and-SMTP  Testing"
t23="Type-image-Emoji-IMAP-and-SMTP  Testing"
t24="Type-image-Emoji-UTF-8-text-IMAP-and-SMTP Testing"
t25="Type-pure-image-messagebody-IMAP-and-SMTP Testing"
t26="Type-image-alternate-text-IMAP-and-SMTP   Testing"
t27="Type-image-UTF-8-Arabic-messagebody-IMAP-and-SMTP  Testing"
t28="Type-image-UTF-8-Chinese-messagebody-IMAP-and-SMTP Testing"
t29="Type-image-UTF-8-English-message-body-IMAP-and-SMTP Testing"
t30="Type-image-UTF-8-Japanese-messagebody-IMAP-and-SMTP  Testing"
t31="Type-image-UTF-8-mixed-texts-messagebody-IMAP-and-SMTP Testing"
t32="Type-C-content-in-body-IMAP-SMTP  Testing"
t33="Type-C-content-with-normal-texts-IMAP-SMTP  Testing"
t34="Type-html-content-IMAP-SMTP Testing"
t35="Type-html-content-with-texts-IMAP-SMTP  Testing"
t36="Type-virus-code-IMAP-and-SMTP  Testing"
t37="Type-virus-code-with-texts-IMAP-and-SMTP  Testing"
t38="Type-blac-bg-with-no-texts-IMAP-and-SMTP  Testing"
t39="Type-black-bg-with-huge-fonts-IMAP-andSMTP Testing"
t40="Type-pure-hyperlink-IMAP-and-SMTP  Testing"
t41="Type-black-bg-with-mixed-style-texts-IMAP-and-SMTP  Testing"
t42="Type-black-bg-with-texts-IMAP-and-SMTP  Testing"
t43="Type-HTML-contents-IMAP-and-SMTP  Testing"
t44="Type-hyperlink-with-mixed-texts-IMAP-and-SMTP Testing"
t45="Type-HTML-contents-with-mixed-texts-IMAP-and-SMTP  Testing"
t46="Type-attachment-pure-audio-IMAP-SMTP  Testing"
t47="Type-attachment-pure-image-IMAP-SMTP  Testing"
t48="Type-attachment-pure-pdf-IMAP-and-SMTP  Testing"
t49="Type-attachment-pure-tar-IMAP-and-SMTP  Testing"
t50="Type-attachment-pure-txt-IMAP-and-SMTP Testing"
t51="Type-attachment-pure-video-IMAP-SMTP  Testing"
t52="Type-attachment-audio-texts-IMAP-SMTP Testing"
t53="Type-attachment-images-with-texts-IMAP-SMTP Testing"
t54="Type-attachment-pdf-texts-IMAP-and-SMTP  Testing"
t55="Type-attachment-pure-virus-IMAP-and-SMTP Testing"
t56="Type-attachment-python-IMAP-and-SMTP Testing"
t57="Type-attachment-python-Texts-IMAP-and-SMTP Testing"
t58="Type-attachment-tar-with-text-IMAP-and-SMTP Testing"
t59="Type-attachment-txt-with-text-content-IMAP-and-SMTP Testing"
t60="Type-attachment-video-with-texts-IMAP-SMTP  Testing"
t61="Type-attachment-virus-with-texts-IMAP-SMTP  Testing"
#t62=
#t63=


  







echo -e  "-------------------------------------Test Summary-------------------------------------\n\n">all-summary.log


echo -e  "--------------------------------Text/plain--------------------------------\n\n"
echo -e  "--------------------------------Text/plain--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t1-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t1-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-ASCII-chars-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t1-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t1-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-ASCII-chars-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd  ..


printf "%-60s" "--------------------$t2-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t2-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-ASCII-chars-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t2-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t2-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-ASCII-chars-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t3-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t3-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-UTF8-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t3-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t3-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-UTF8-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t4-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t4-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-UTF8-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t4-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t4-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-UTF8-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t5-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t5-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-GBK-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t5-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t5-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-GBK-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t6-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t6-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-GBK-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t6-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t6-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Chinese-GBK-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t7-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t7-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-UTF8-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t7-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t7-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-UTF8-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t8-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t8-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-UTF8-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t8-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t8-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-UTF8-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t9-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t9-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-EUC-JP-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t9-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t9-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-EUC-JP-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t10-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t10-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-EUC-JP-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t10-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t10-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-EUC-JP-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t11-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t11-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-Shift_JIS-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t11-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t11-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-Shift_JIS-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t12-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t12-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-Shift_JIS-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t12-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t12-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-Shift_JIS-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t13-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t13-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-GBK-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t13-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t13-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-GBK-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..






printf "%-60s" "--------------------$t14-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t14-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-GBK-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t14-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t14-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Japanese-GBK-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..







printf "%-60s" "--------------------$t15-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t15-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-UTF8-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t15-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t15-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-UTF8-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t16-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t16-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-UTF8-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t16-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t16-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-UTF8-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t17-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t17-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-ISO-8859-6-CRLF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t17-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t17-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-ISO-8859-6-CRLF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t18-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t18-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-ISO-8859-6-LF
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t18-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t18-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-Arabic-ISO-8859-6-LF
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t19-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t19-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-mixed-UTF-8-language
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t19-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t19-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd IMAP-and-SMTP-mixed-UTF-8-language
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



echo -e  "--------------------------------type-symbols--------------------------------\n\n"
echo -e  "--------------------------------type-symbols--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t20-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t20-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd type-symbols-UTF8-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t20-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t20-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd type-symbols-UTF8-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


echo -e  "--------------------------------type-emoji--------------------------------\n\n"
echo -e  "--------------------------------type-emoji--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t21-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t21-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-char-Emoji-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t21-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t21-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-char-Emoji-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t22-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t22-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-char-Emoji-UTF-8-text-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t22-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t22-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-char-Emoji-UTF-8-text-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t23-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t23-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-Emoji-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t23-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t23-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-Emoji-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t24-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t24-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-Emoji-UTF-8-text-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t24-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t24-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-Emoji-UTF-8-text-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



echo -e  "--------------------------------type-image--------------------------------\n\n"
echo -e  "--------------------------------type-image--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t25-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t25-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-pure-image-messagebody-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t25-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t25-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-pure-image-messagebody-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t26-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t26-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-alternate-text-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t26-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t26-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-alternate-text-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t27-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t27-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Arabic-messagebody-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t27-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t27-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Arabic-messagebody-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t28-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t28-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Chinese-messagebody-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t28-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t28-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Chinese-messagebody-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t29-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t29-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-English-message-body-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t29-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t29-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-English-message-body-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t30-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t30-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Japanese-messagebody-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t30-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t30-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-Japanese-messagebody-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t31-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t31-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-mixed-texts-messagebody-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t31-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t31-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-image-UTF-8-mixed-texts-messagebody-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



echo -e  "--------------------------------type-Source code--------------------------------\n\n"
echo -e  "--------------------------------type-Source code--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t32-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t32-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-C-content-in-body-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t32-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t32-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-C-content-in-body-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t33-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t33-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-C-content-with-normal-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t33-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t33-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-C-content-with-normal-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t34-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t34-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-html-content-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t34-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t34-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-html-content-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..





printf "%-60s" "--------------------$t35-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t35-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-html-content-with-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t35-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t35-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-html-content-with-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t36-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t36-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-virus-code-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t36-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t36-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-virus-code-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t37-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t37-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-virus-code-with-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t37-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t37-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-virus-code-with-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



echo -e  "--------------------------------type-Style formats--------------------------------\n\n"
echo -e  "--------------------------------type-Style formats--------------------------------\n\n">>all-summary.log



printf "%-60s" "--------------------$t38-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t38-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-blac-bg-with-no-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t38-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t38-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-blac-bg-with-no-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t39-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t39-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-black-bg-with-huge-fonts-IMAP-andSMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t39-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t39-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-black-bg-with-huge-fonts-IMAP-andSMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t40-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t40-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-pure-hyperlink-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t40-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t40-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-pure-hyperlink-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t41-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t41-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-black-bg-with-mixed-style-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t41-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t41-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-black-bg-with-mixed-style-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t42-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t42-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-black-bg-with-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t42-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t42-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-black-bg-with-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t43-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t43-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-HTML-contents-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t43-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t43-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-HTML-contents-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t44-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t44-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-hyperlink-with-mixed-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t44-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t44-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-hyperlink-with-mixed-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t45-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t45-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-HTML-contents-with-mixed-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t45-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t45-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-HTML-contents-with-mixed-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..





echo -e  "--------------------------------type-Attachments--------------------------------\n\n"
echo -e  "--------------------------------type-Attachments--------------------------------\n\n">>all-summary.log


printf "%-60s" "--------------------$t46-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t46-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-audio-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t46-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t46-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-audio-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t47-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t47-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-image-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t47-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t47-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-image-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t48-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t48-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-pdf-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t48-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t48-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-pdf-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..





printf "%-60s" "--------------------$t49-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t49-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-tar-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t49-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t49-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-tar-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t50-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t50-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-txt-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t50-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t50-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-txt-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..





printf "%-60s" "--------------------$t51-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t51-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-video-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t51-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t51-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-video-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t52-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t52-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-audio-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t52-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t52-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-audio-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t53-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t53-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-images-with-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t53-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t53-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-images-with-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t54-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t54-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pdf-texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t54-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t54-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pdf-texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t55-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t55-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-pure-virus-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t55-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t55-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-pure-virus-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t56-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t56-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-python-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t56-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t56-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-python-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t57-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t57-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-python-Texts-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t57-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t57-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-python-Texts-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t58-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t58-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-tar-with-text-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t58-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t58-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-tar-with-text-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..




printf "%-60s" "--------------------$t59-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t59-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-txt-with-text-content-IMAP-and-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t59-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t59-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-txt-with-text-content-IMAP-and-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



printf "%-60s" "--------------------$t60-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t60-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-video-with-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t60-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t60-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-video-with-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..


printf "%-60s" "--------------------$t61-IMAP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t61-IMAP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd Type-attachment-virus-with-texts-IMAP-SMTP
bash logic-messagesend-IMAP-append-7bit.sh
bash logic-messagesend-IMAP-append-8bit.sh
bash logic-messagesend-IMAP-append-base64.sh
bash logic-messagesend-IMAP-append-quoted.sh

cd ..


printf "%-60s" "--------------------$t61-SMTP--------------------" 
echo -en "\n"
printf "%-60s" "--------------------$t61-SMTP--------------------" >>all-summary.log
echo -en "\n" >>all-summary.log
cd  Type-attachment-virus-with-texts-IMAP-SMTP
bash logic-messagesend-SMTP-7bit.sh
bash logic-messagesend-SMTP-8bit.sh
bash logic-messagesend-SMTP-base64.sh
bash logic-messagesend-SMTP-quoted.sh

cd ..



echo -e "\n\n"
echo -e "\n\n" >>all-summary.log

cat all-summary.log