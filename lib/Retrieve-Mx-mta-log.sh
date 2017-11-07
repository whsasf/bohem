#!/bin/bash

set -x 
logdir=${MX1_INSTALL}/log
iuser=${MX1_USER}
host=${MX1_HOST_IP}
if [ "${MX1_SSH_PORT}" != "" ]
then
    port_arg="-p ${MX1_SSH_PORT}"
fi

if [ "$1" = "--get-location" ]; then
	logfile=`ssh -o BatchMode=yes ${port_arg} ${iuser}@${host} "ls -1rt $logdir/mta*log | tail -1"`
	length=`ssh -o BatchMode=yes ${port_arg} ${iuser}@${host} "wc -l $logfile" | awk '{ print \$1 }'`
	echo "$logfile:$length"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-Mx-mta-log.sh --get-logfile log_file:old_length output_file" >&2
		exit 3
	fi

	logfile=`echo $2 | cut -f1 -d:`
	length=`echo $2 | cut -f2 -d:`

	if [ "$logfile" = "" ] || [ "$length" = "" ] ; then
		echo "ERROR 3 -- Syntax: Retrieve-Mx-mta-log.sh --get-logfile log_file:old_length output_file" >&2
		exit 3
	fi

	file=$3
	
	new_length=`ssh -o BatchMode=yes ${port_arg} ${iuser}@${host} "wc -l $logfile" | awk '{ print \$1 }'`
	diff_length=$((new_length - length))
	ssh -o BatchMode=yes ${port_arg} ${iuser}@${host} "cat $logfile | head -$new_length | tail -$diff_length" > $file

else
	echo "Syntax ERROR..." >&2
	exit 1
fi
