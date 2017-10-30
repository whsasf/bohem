#!/bin/bash

if [ "$1" = "--get-location" ]; then

	if [ $# -ne 2 ]; then
		echo "ERROR 2 -- Syntax: Retrieve-syslog.sh --get-location <node_name>" >&2
		exit 2
	fi

	if [ `uname` = "Linux" ]; then
		logfile="/var/log/maillog"
	else
		logfile="/var/log/syslog"
	fi

	id=$2
	var=CPMS${id}_HOST; host=${!var}

	len=`ssh -o BatchMode=yes root@$host wc -l $logfile | awk '{ print $1 }'`
	echo "$id:$logfile:$len"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-syslog.sh --get-logfile <instance_number>:<log_file>:<old_length> <output_file>" >&2
		exit 3
	fi

	id=`echo $2 | cut -f1 -d:`
	logfile=`echo $2 | cut -f2 -d:`
	len=`echo $2 | cut -f3 -d:`
	file=$3

	if [ `uname` = "Linux" ]; then
		logfile="/var/log/maillog"
	else
		logfile="/var/log/syslog"
	fi

	# wait a sec... give system some extra time
	sleep 1

	var=CPMS${id}_HOST; host=${!var}
echo "get-logfile: id=$id host=$host"
	newlen=`ssh -o BatchMode=yes root@$host wc -l $logfile | awk '{ print $1 }'`
	diff=$((newlen - len))
	ssh -o BatchMode=yes root@$host "cat $logfile | head -$newlen | tail -$diff" > $file
else
	echo "ERROR 1 -- Syntax:"
	echo " Retrieve-MS-log.sh --get-location <node_name> <module>" >&2
	echo " Retrieve-MS-log.sh --get-logfile <instance-number>:<module>:<log_file>:<old_length> <output_file>" >&2
	echo "                       module is one of \"smtp\" \"ims\""
	exit 1
fi

