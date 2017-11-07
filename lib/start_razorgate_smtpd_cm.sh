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
	manager.pl $host $port $pass "RGT SERVICE START $service NODE=$node"
	echo "CM Command ($node) complete $SECONDS"
done

timeout=$((SECONDS + 120))

for rgid in `echo $rgids | tr ',' ' '`
do
	var="RG${rgid}_HOST" ; rg_host=${!var}
	echo -en "Check RG${rgid} port 25: "
	while [ $SECONDS -lt $timeout ]; do
		echo -en .
		nmap -p 25 $rg_host | grep "^25.*open" && break
		sleep 1
	done
	echo
done

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG${rgid} $service START Time taken: $SECONDS"
	exit 1
fi

echo "$service Started after $SECONDS"

check_smtp()
{
	telnet.pl $1 25 > out.txt <<- EOF
			QUIT
			EOF
	grep "ESMTP" out.txt
}

for rgid in `echo $rgids | tr ',' ' '`
do
	var="RG${rgid}_HOST" ; rg_host=${!var}

	echo -en "Check RG${rgid} port 25 is working (banner): "
	check_smtp $rg_host
	if [ $? -ne 0 ]; then
		echo "RG${rgid} $service TROUBLE STARTING smtpd - Time: $SECONDS"
		## Try again..
		check_smtp $rg_host
		if [ $? -ne 0 ]; then
			echo "RG${rgid} $service DIDN'T REALLY START Time taken: $SECONDS"
			exit 1
		fi
	fi
	echo
done

echo "RG${rgids} $service START Time taken: $SECONDS"

exit 0
