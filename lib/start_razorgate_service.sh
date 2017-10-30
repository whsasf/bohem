#!/bin/bash

###
### Can be used in either Couchbase or ConfigDB modes
###

consoleid=$1
if [ "$consoleid" = "" ]; then
	echo "Which console ?"
	exit 1
fi

nodes=$2
if [ "$nodes" = "" ]; then
	echo "Which razorgate nodes ?"
	exit 1
fi

service=$3
if [ "$service" = "" ]; then
	echo "Which service ?"
	exit 1
fi

get_host_from_node()
{
	node=$1
	host=nohost.invalid

	for id in `seq 1 10`
	do
		var="RG_SMTP${id}_NODE" ; n=${!var}
		if [ "$n" = "$node" ]; then
			var="RG_SMTP${id}_HOST" ; host=${!var}
			var="RG_SMTP${id}_HOST_IP" ; ip=${!var}
			var="RG_SMTP${id}_SSH_PORT" ; port=${!var}
			var="RG_SMTP${id}_INSTALL" ; install=${!var}
			if [ "$service" == "smtpd" ] || [ "$service" == "smtp" ]
			then
				var="RG_SMTP${id}_SMTP_PORT" ; check_port=${!var}
			fi
			break
		fi
	done
}

netstat_args=plnt

if [ "$service" == "smtpd" ] || [ "$service" == "smtp" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="smtp"
	fi
	check_port=${RG_SMTP1_SMTP_PORT}
elif [ "$service" == "countersd" ] || [ "$service" == "counters" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="counters"
	fi
	check_port=4236
elif [ "$service" == "kas" ]
then
	check_port=9003
elif [ "$service" == "kav" ]
then
	check_port=7776
elif [ "$service" == "ctasd" ] || [ "$service" == "cyrenas" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="cyrenas"
	fi
	check_port=8088
elif [ "$service" == "sophosd" ] || [ "$service" == "sophosas" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="sophosas"
	fi
	check_port=4238
elif [ "$service" == "sophosav" ] || [ "$service" == "savdid" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="sophosav"
	fi
	check_port=4010
elif [ "$service" == "ctipd" ] || [ "$service" == "cyrenip" ]
then
	if [ $(echo $RG_VERSION | cut -f 1-3 -d \. | tr -d \.) -ge 58018 ]
	then
		service="cyrenip"
	fi
	check_port=5353
	netstat_args=plnu
elif [ "$service" == "vadeas" ]
then
	check_port=4241
fi

var="RG_CONSOLE${consoleid}_HOST" ; host=${!var}
var="RG_CONSOLE${consoleid}_PORT" ; port=${!var}
var="RG_CONSOLE${consoleid}_PASSWORD" ; pass=${!var}
var="RG_SMTP${consoleid}_HOST" ; shost=${!var}

if [ "$host" = "" ] || [ "$host" = "nohost.invalid" ]
then
	### There is no cluster management, try the direct approach
	for node in `echo $nodes | tr ',' ' '`
	do
		get_host_from_node $node
		ssh -o BatchMode=yes -p $port root@$host "MIRA_ROOT=$install/mira $install/mira/usr/bin/startproc $service"
	done
else
	for node in `echo $nodes | tr ',' ' '`
	do
		manager.pl $host $port $pass "RGT SERVICE START $service NODE=$node"
		echo "CM Command ($node) complete $SECONDS"
	done
fi

timeout=$((SECONDS + 120))

for node in `echo $nodes | tr ',' ' '`
do
	get_host_from_node $node
	echo -en "Check RG ${node} check_port $check_port: "
	while [ $SECONDS -lt $timeout ]; do
		echo -en .
		#nmap -p $check_port $host | grep "^$check_port.*open" && break
		ssh -o BatchMode=yes -p $port root@$host netstat -$netstat_args | awk '{ print $4 }' | grep -q -e "127.0.0.1:$check_port\>" -e "${ip}:$check_port\>" -e "0.0.0.0:$check_port\>" && break
		sleep 1
	done
	echo
done

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG${node} $service START Time taken: $SECONDS"
	exit 1
fi

echo "Service [${service}] Started after $SECONDS"

check_service()
{
	rc=0
	if [ "$service" == "smtp" ] || [ "$service" == "smtpd" ]
	then
		telnet.pl $1 $check_port > out.txt <<- EOF
				QUIT
				EOF
		grep "ESMTP" out.txt
		rc=$?
	fi
	return $rc
}

### This is added just in case the port is open, but the service is not ready to accept connections.
### Really I'm not sure if this is even possible, once the server calls listen() and eventually calls accept(), this should not be needed.
sleep 2

for node in `echo $nodes | tr ',' ' '`
do
	get_host_from_node $node

	echo -en "Check RG ${node} port $check_port is working (banner): "
	check_service $host
	if [ $? -ne 0 ]; then
		echo "RG ${node} $service TROUBLE STARTING $service - Time: $SECONDS"
		## Try again..
		check_service $host
		if [ $? -ne 0 ]; then
			echo "RG ${node} $service DIDN'T REALLY START Time taken: $SECONDS"
			exit 1
		fi
	fi
	echo
done

echo "RG${nodes} $service START Time taken: $SECONDS"

exit 0
