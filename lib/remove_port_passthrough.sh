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

## PREROUTING
pr_num=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L PREROUTING -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\" | cut -f 1 -d :")
pr_num="$(echo "$pr_num" |tr '\n' ' ' | rev)"
for n in $pr_num
do
	ssh -o BatchMode=yes -p 22 root@$host "iptables -D PREROUTING $n -t nat"
done

res=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L PREROUTING -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\"")
if [ "$res" != "" ]
then
        echo "PREROUTING rule not removed successfully."
        exit 1
fi



# OUTPUT
o_num=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L OUTPUT -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\" | cut -f 1 -d :")
o_num="$(echo "$o_num" |tr '\n' ' ' | rev)"
for n in $o_num
do
	ssh -o BatchMode=yes -p 22 root@$host "iptables -D OUTPUT $n -t nat"
done

res=$(ssh -o BatchMode=yes -p 22 root@$host "iptables -L OUTPUT -n -v -t nat | tail -n +3 | grep -n \"dpt:$from_port to:$ip:$to_port\"")
if [ "$res" != "" ]
then
        echo "OUTPUT rule not removed successfully."
        exit 1
fi

