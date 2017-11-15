#!/bin/bash
for dir in `find . -maxdepth 1 -type d`
do 
echo $dir
if [ $dir = . ];then
  echo hello
else
	cd $dir
	flag=`ls -al |grep  "fetch-template.txt"|awk '{print $9}'`
	if  test -z "$flag"  
        then
           echo hello  
	else  
	  cp fetch-target.txt     fetch-template.txt
	  cp uidfetch-target.txt  uidfetch-template.txt  
	fi    
	cd ..
fi
done
