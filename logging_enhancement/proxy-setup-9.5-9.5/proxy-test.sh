#!/bin/bash
#DEFINE TEST CASES
t1="1-User-Present-in-Directory-with-Proxy-Mode-with-Password"
t2="2-User-Present-in-Directory-with-Proxy-Mode-with-wrong-Password"
t3="3-User-Present-in-Directory-with-Proxy-Mode-without-Password"
t4="4-User-Present-in-Directory-with-Proxy-Mode-with-diff-Password"
t5="5-User-not-Present-in-Directory"

chmod -R +x *.sh
num=5

echo -e  "-------------------------------------Test Process-------------------------------------\n\n"		
echo -e  "-------------------------------------Test Process-------------------------------------\n\n">all-summary.log

echo -en "\n" >>all-summary.log

for (( i=1;i<=$num;i++ ))
do
#print test scope name

temp=t`echo $i`
echo -e "================${!temp} Testing===============\n"
echo    "================${!temp} Testing===============" >>all-summary.log 
cd ${!temp}
echo -e "Testing in normal proxy situations for IMAP,POP and SMTP :\n\n"
echo -e "Testing in normal proxy situations for IMAP,POP and SMTP :\n\n" >> ../all-summary.log
bash proxy.sh
echo -e "Testing in proxy with TLS situations for IMAP,POP and SMTP :\n\n"
echo -e "Testing in proxy with TLS situations for IMAP,POP and SMTP :\n\n" >> ../all-summary.log
bash proxy-TLS.sh
echo -e "Testing in proxy with XCLP situations for IMAP,POP and SMTP :\n\n"
echo -e "Testing in proxy with XCLP situations for IMAP,POP and SMTP :\n\n" >> ../all-summary.log
bash proxy-XCLP.sh
echo -e "Testing in proxy with TLS and XCLP situations for IMAP,POP and SMTP :\n\n"
echo -e "Testing in proxy with TLS and XCLP situations for IMAP,POP and SMTP :\n\n" >> ../all-summary.log
bash proxy-TLS-XCLP.sh
cd ..
done

echo -e "\n\n"
echo -e "\n\n"  >>all-summary.log

echo -e "====================Test Results=============================\n\n"
cat all-summary.log

# Test summary
