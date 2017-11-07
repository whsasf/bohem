#!/bin/bash

### NOTE: This script does NOT use MOS.
##
set -x

user=$1
host=$2
prefix=$3
port=$4
class=$5

shift 5

echo $host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh_port=$(echo $host | cut -f 2 -d ':')
	host=$(echo $host | cut -f 1 -d ':')
else
	ssh_port=22
fi

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh_port $user@$host $prefix/bin/imldapsh -D cn=root -W secret -H ${OWM_CONFSERV1_HOST} -P $port DeleteCos $class

echo "TIME Class delete: $SECONDS"
exit 0
