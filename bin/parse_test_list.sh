#!/bin/bash
while read line
do 
	grep "#" $line
     if [ $? -ne 0 ]
     then
     		parse_and_execute $line 
     fi
done < $1