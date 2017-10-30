#!/bin/bash

consoleid=$1
if [ "$consoleid" = "" ]; then
	echo "Which console ?"
	exit 1
fi

rgids=$2
if [ "$rgids" = "" ]; then
	echo "Which razorgate ?"
	exit 1
fi

var="RG${consoleid}_HOST" ; host=${!var}
var="RG${consoleid}_CM_PORT" ; port=${!var}
var="RG${consoleid}_PASSWORD" ; pass=${!var}

if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
then
	service="smtp"
else
	service="smtpd"
fi

for rgid in `echo $rgids | tr ',' ' '`
do
	node="rg${rgid}"
	manager.pl $host $port $pass "RGT SERVICE STOP $service NODE=$node"
	echo "CM Command ($node) complete $SECONDS"
done

timeout=$((SECONDS + 300))

for rgid in `echo $rgids | tr ',' ' '`
do
	var="RG${rgid}_HOST" ; aaa_host=${!var}
	echo -en "Check RG${rgid} port 25: "
	while [ $SECONDS -lt $timeout ]; do
		echo -en .
		nmap -p 25 $aaa_host | grep "^25.*open" > /dev/null || break
		sleep 1
	done
	echo
done

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG${rgid} $service STOP Time taken: $SECONDS"
	exit 1
fi

echo "RG${rgids} $service STOP Time taken: $SECONDS"

exit 0
