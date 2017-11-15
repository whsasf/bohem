#!/bin/bash
for dir in `find . -maxdepth 1 -type d`
do 
echo $dir
if [ $dir = "." ];then
  echo hello
else
	cd $dir
	flag=`ls -al |grep  "fetch-template.txt"|awk '{print $9}'`
	echo $flag
	if  test -z "$flag"
	 then  
	  echo hello  
	else  
	  uex fetch-template.txt
	  uex uidfetch-template.txt  
	fi    
	cd ..
fi
done
