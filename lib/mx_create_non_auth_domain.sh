#!/bin/bash

### NOTE: This script does NOT use MOS.
##
## Create a domain
##
#mx_create_domain.sh <mxhost> <domain>
set -x

user=$1
host=$2
prefix=$3
port=$4
domain=$5
route=$6

echo $host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh_port=$(echo $host | cut -f 2 -d ':')
	host=$(echo $host | cut -f 1 -d ':')
else
	ssh_port=22
fi

shortHost=`ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh_port $user@$host hostname -s`

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh_port $user@$host $prefix/bin/imldapsh -D cn=root -W secret -H $shortHost -P $port  CreateDomain $domain nonauth $route

echo "TIME Domain create: $SECONDS"
exit 0
