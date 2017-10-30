#!/bin/bash

###
### Can be used in either Couchbase or ConfigDB modes
###

if [ "$GCOV_BUILD" != "" ]; then
	## Serialise command...
	unset GCOV_BUILD
	rc=0
	for node in $(echo $2 | tr ',' ' ')
	do
		$0 $1 $node $3
		if [ $? -ne 0 ]; then
			echo "Some problem"
			rc=1
		fi
	done
	exit $rc
fi

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
			var="RG_SMTP${id}_SMTP_PORT" ; smtp_port=${!var}
			var="RG_SMTP${id}_INSTALL" ; install=${!var}
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
		ssh -o BatchMode=yes -p $port root@$host "MIRA_ROOT=$install/mira $install/mira/usr/bin/stopproc $service"
	done
else
	for node in `echo $nodes | tr ',' ' '`
	do
		manager.pl $host $port $pass "RGT SERVICE STOP $service NODE=$node"
		echo "CM Command ($node) complete $SECONDS"
	done
fi

timeout=$((SECONDS + 300))

for node in `echo $nodes | tr ',' ' '`
do
	get_host_from_node $node
	if [ "$service" == "smtp" ] || [ "$service" == "smtpd" ]
	then
		check_port=$smtp_port
	fi
	echo -en "Check RG ${node} port $check_port: "
	while [ $SECONDS -lt $timeout ]; do
		echo -en .
		ssh -o BatchMode=yes -p $port root@$host netstat -$netstat_args | awk '{ print $4 }' | grep -q -e "127.0.0.1:$check_port\>" -e "${ip}:$check_port\>" -e "0.0.0.0:$check_port\>" || break
		sleep 1
	done
	echo
done

if [ $SECONDS -ge $timeout ]; then
	echo "FAILED RG $service STOP Time taken: $SECONDS"
	exit 1
fi

echo "RG${nodes} $service STOP Time taken: $SECONDS"

exit 0
