#!/bin/bash

count=25
for ((i=1;i<=$count;i++ ))
do
  cat header.txt  > message-append$i.txt
  cat message$i.txt >>message-append$i.txt
done
