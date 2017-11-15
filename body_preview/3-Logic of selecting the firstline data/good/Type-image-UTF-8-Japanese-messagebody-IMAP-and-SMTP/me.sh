#!/bin/bash
for dir in `find . -maxdepth 1 -type d`
do 
echo $dir
if [ $dir = . ];then
  echo hello
else
	cd $dir 
	#unix2dos  *messagebody*.txt
	cp fetch-template.txt    fetch-template-base64.txt
	cp fetch-template.txt    fetch-template-quoted.txt
	cp uidfetch-template.txt    uidfetch-template-base64.txt
	cp uidfetch-template.txt    uidfetch-template-quoted.txt
	sed -i 's/template/template-base64/g'     *base64.sh
	sed -i 's/template/template-quoted/g'     *quoted.sh    
	cd ..
fi
done
