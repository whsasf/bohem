#!/bin/bash

# added 2 new log directories - one for 5.5 and the other for 5.6

logdir55=/mira/usr/store/smtp/smtp/log
logdir56=/mira/usr/store/logs

if [ "$1" = "--get-location" ]; then

	if [ $# -ne 2 ]; then
		echo "ERROR 2 -- Syntax: Retrieve-RG-smtp-log.sh --get-location node=<node_name> " >&2
		exit 2
	fi

	manager.pl $RG1_HOST $RG1_CM_PORT $RG1_PASSWORD "RGT LOGGING FLUSH $2" >&2
	if [ $? -ne 0 ]; then
		exit 2
	fi
	sleep 3
	str=`echo $2 | cut -f2 -d '=' | tr '[:lower:]' '[:upper:]'`
	host="${str}_HOST"
	logfile=`/usr/bin/rsh -l root ${!host} "ls -1v $logdir55/smtp*log $logdir56/smtp*log | tail -1"`
	length=`/usr/bin/rsh -l root ${!host} "wc -l $logfile" | awk '{ print \$1 }'`
	echo "$2:$logfile:$length"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-smtp-log.sh --get-logfile node=<node_name>:log_file:old_length output_file" >&2
		exit 3
	fi

	node=`echo $2 | cut -f1 -d:`
	logfile=`echo $2 | cut -f2 -d:`
	length=`echo $2 | cut -f3 -d:`

	if [ "$node" = "" ] || [ "$logfile" = "" ] || [ "$length" = "" ] ; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-smtp-log.sh --get-logfile node=<node_name>:log_file:old_length output_file" >&2
		exit 3
	fi

	file=$3
	
	manager.pl $RG1_HOST $RG1_CM_PORT $RG1_PASSWORD "RGT LOGGING FLUSH $node" >&2
	if [ $? -ne 0 ]; then
		exit 2
	fi
	sleep 3
	
	str=`echo $node | cut -f2 -d '=' | tr '[:lower:]' '[:upper:]'`
    host="${str}_HOST"
	new_length=`/usr/bin/rsh -l root ${!host} "wc -l $logfile" | awk '{ print \$1 }'`
	diff_length=$((new_length - length))
	/usr/bin/rsh -l root ${!host} "cat $logfile | head -$new_length | tail -$diff_length" > $file

else
	echo "Syntax ERROR..." >&2
	exit 1
fi
