#!/bin/bash

id=$1
if [ "$id" = "" ]; then
	echo "Which razorgate ?"
	exit 1
fi

var="RG${id}_HOST" ; host=${!var}
var="RG${id}_AAA_MGMT_PORT" ; port=${!var}
var="RG${id}_PASSWORD" ; pass=${!var}

manager.pl $host $port $pass "SYSTEM SERVICES smtpd STOP"
echo "AAA Command complete $SECONDS"

timeout=$((SECONDS + 300))
while [ $SECONDS -lt $timeout ]; do
	echo -en .
	nmap -p 25 $host | grep "^25.*open" > /dev/null || break
	sleep 1
done
echo

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG${id} smtpd STOP Time taken: $SECONDS"
	exit 1
fi

echo "RG${id} smtpd STOP Time taken: $SECONDS"

exit 0
