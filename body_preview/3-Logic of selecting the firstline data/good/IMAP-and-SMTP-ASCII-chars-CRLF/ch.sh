#!/bin/bash
number=27
for ((i=2;i<$number;i++))
do

cp   message$i-7bit.txt  message$i-quoted.txt
cat  header-quoted.txt   message$i-quoted.txt > message-append$i-quoted.txt
cat message-append$i-quoted.txt | perl -pe 'chomp if eof' >tttt.txt
cp  tttt.txt message-append$i-quoted.txt
unix2dos  message-append$i-quoted.txt
done