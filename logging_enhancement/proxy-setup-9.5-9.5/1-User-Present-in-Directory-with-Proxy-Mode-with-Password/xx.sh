#!/bin/bash
exec 3<>/dev/tcp/172.26.202.233/10110
echo -en "user procu1\r\n" >&3
#sleep 1
echo -en "pass p\r\n" >&3
echo -en "list\r\n" >&3
echo -en "retr 1\r\n" >&3
echo -en "retr 3\r\n" >&3
echo -en "quit\r\n" >&3
cat <&3 >pop-temp.log
exec 3>&-

cat pop-temp.log
