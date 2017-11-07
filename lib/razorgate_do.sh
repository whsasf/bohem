#!/bin/bash

cmd=$1
if [ "$cmd" = "" ]; then
    echo "Do what? [start|stop]"
    exit 1
fi

nodes=$2
if [ "$nodes" = "" ]; then
    echo "Which razorgate nodes ?"
    exit 1
fi

if [ "$3" == "--nocm" ]
then
    nocm="true"
fi

if [ "$GCOV_BUILD" != "" ]; then
	## Serialise command...
	unset GCOV_BUILD
	rc=0
	for node in $(echo $nodes | tr ',' ' ')
	do
		$0 $cmd $node
		if [ $? -ne 0 ]; then
			echo "Some problem with $cmd of $node"
			rc=1
		fi
	done
	exit $rc
fi

get_host_from_node()
{
    node=$1
    host=nohost.invalid

    for id in `seq 1 10`
    do
        var="RG_SMTP${id}_NODE" ; n=${!var}
        if [ "$n" = "${node}" ]; then
            var="RG_SMTP${id}_HOST" ; host=${!var}
            var="RG_SMTP${id}_HOST_IP" ; ip=${!var}
            var="RG_SMTP${id}_SSH_PORT" ; port=${!var}
            var="RG_SMTP${id}_SMTP_PORT" ; smtp_port=${!var}
            var="RG_SMTP${id}_INSTALL"; mira_root="${!var}/mira"
            break
        fi
    done
}

wait_for_rg_start()
{
    #### Wait for services to start.

    begin=$SECONDS
    echo "ip:$ip"
    while [ $((SECONDS - begin)) -lt 240 ]
    do
        sleep 1

        if [ "$nocm" != "true" ]
        then
            nmap -p 7210 $ip | grep "^7210.*open" || continue
            nmap -p 9999 $ip | grep "^9999.*open" || continue
        fi
        nmap -p $smtp_port $ip | grep "^${smtp_port}.*open" || continue
        nmap -p 4237 $ip | grep "^4237.*open" || continue

        services_started="true"
        break
    done

    if [ "$services_started" != "true" ]
    then
        echo "FAILED RG $cmd Time taken: $SECONDS"
        exit 1
    fi

    services_started=""
}

wait_for_rg_stop()
{
    #### Wait for services to stop.

    begin=$SECONDS
    while [ $((SECONDS - begin)) -lt 240 ]
    do
        sleep 1

        if [ "$nocm" != "true" ]
        then
            nmap -p 7210 $ip | grep "^7210.*open" && continue
            nmap -p 9999 $ip | grep "^9999.*open" && continue
        fi
        nmap -p $smtp_port $ip | grep "^${smtp_port}.*open" && continue
        nmap -p 4237 $ip | grep "^4237.*open" && continue

        services_stopped="true"
        break
    done

    if [ "$services_stopped" != "true" ]
    then
        echo "FAILED RG $cmd Time taken: $SECONDS"
        exit 1
    fi

    services_stopped=""
}

for node in `echo $nodes | tr ',' ' '`
do
    get_host_from_node $node
    ssh -o BatchMode=yes -p $port root@$host "export MIRA_ROOT=$mira_root; export JAVA_HOME=/usr/local/jdk1.7.0_21/; $mira_root/etc/init.d/razorgate $cmd"
done

if [ "$cmd" == "start" -o "$cmd" == "stop" ]
then
    for node in `echo $nodes | tr ',' ' '`
    do
        get_host_from_node $node
        if [ "$cmd" == "start" ]
        then
            wait_for_rg_start
        else
            wait_for_rg_stop
        fi
    done
fi

echo "RG ${nodes} $cmd Time taken: $SECONDS"

exit 0

