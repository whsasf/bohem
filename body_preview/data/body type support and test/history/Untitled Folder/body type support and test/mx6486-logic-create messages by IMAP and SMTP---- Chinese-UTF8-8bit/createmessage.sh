#!/bin/bash

count=24
for ((i=1;i<=$count;i++ ))
do
  cat xx.txt  > message-append$i.txt
  cat message$i.txt >>message-append$i.txt
done
