#!/bin/bash

id=$1
if [ "$id" = "" ]; then
	echo "Which razorgate ?"
	exit 1
fi

var="RG${id}_HOST" ; host=${!var}
var="RG${id}_AAA_MGMT_PORT" ; port=${!var}
var="RG${id}_PASSWORD" ; pass=${!var}

manager.pl $host $port $pass "SYSTEM SERVICES smtpd START"
echo "AAA Command complete $SECONDS"

timeout=$((SECONDS + 60))
while [ $SECONDS -lt $timeout ]; do
	echo -en .
	nmap -p 25 $host | grep "^25.*open" && break
	sleep 1
done
echo

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG${id} smtpd START Time taken: $SECONDS"
	exit 1
fi

echo "SMTPD Started after $SECONDS"

manager.pl $host $port $pass "INFO" | grep "UNIX"
if [ $? -ne 0 ]; then
	echo "RG${rgid} smtpd TROUBLE STARTING smtpd - Time: $SECONDS"
	## Try again..
	manager.pl $host $port $pass "INFO" | grep "UNIX"
	if [ $? -ne 0 ]; then
		echo "RG${id} smtpd DIDN'T REALLY START Time taken: $SECONDS"
		exit 1
	fi
fi


echo "RG${id} smtpd START Time taken: $SECONDS"

exit 0
