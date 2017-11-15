#!/bin/bash
for dir in `find . -maxdepth 1 -type d`
do 
echo $dir
if [ $dir = . ];then
  echo hello
else
	cd $dir 
	#unix2dos  *messagebody*.txt
# sed -i '/rfc822/s/#echo/echo/g'  logic*.sh  
sed -i 's/10.37.2.124/172.26.202.87/g'  logic*.sh
sed -i 's/10.37.2.125/172.26.203.123/g'  logic*.sh
	cd ..
fi
done
