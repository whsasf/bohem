#!/bin/sh

host=$1
if [ "$host" = "" ]; then
        echo "Which host?"
        exit 1
fi

ip=$2
if [ "$ip" = "" ]; then
        echo "Which IP?"
        exit 1
fi

from_port=$3
if [ "$from_port" = "" ]; then
        echo "From which port?"
        exit 1
fi

to_port=$4
if [ "$to_port" = "" ]; then
        echo "To which port?"
        exit 1
fi

ssh -o BatchMode=yes -p 22 root@$host "iptables -t nat -A PREROUTING -p tcp -d $ip --dport $from_port --jump DNAT --to-destination $ip:$to_port"
res=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L PREROUTING -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\"")
if [ "$res" == "" ]
then
	echo "PREROUTING rule not added successfully."
	exit 1
fi

ssh -o BatchMode=yes -p 22 root@$host "iptables -t nat -A OUTPUT -p tcp -d $ip --dport $from_port --jump DNAT --to-destination $ip:$to_port"
res=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L OUTPUT -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\"")
if [ "$res" == "" ]
then
	echo "OUTPUT rule not added successfully."
	exit 1
fi


