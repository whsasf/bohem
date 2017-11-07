#!/bin/bash



if [ "$1" = "--get-location" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 2 -- Syntax: Retrieve-RG-audit-log.sh --get-location node=<node_name> log_dir/log_name" >&2
		exit 2
	fi

  logdfile=$3
	str=`echo $2 | cut -f2 -d '=' | tr '[:lower:]' '[:upper:]'`
	host="${str}_HOST"
	length=`/usr/bin/rsh -l root ${!host} "wc -l $logdfile" | awk '{ print \$1 }'`
	echo "$2:$logdfile:$length"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-audit-log.sh --get-logfile node=<node_name>:log_file:old_length output_file" >&2
		exit 3
	fi

	node=`echo $2 | cut -f1 -d:`
	logfile=`echo $2 | cut -f2 -d:`
	length=`echo $2 | cut -f3 -d:`

	if [ "$node" = "" ] || [ "$logfile" = "" ] || [ "$length" = "" ] ; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-audit-log.sh --get-logfile node=<node_name>:log_file:old_length output_file" >&2
		exit 3
	fi

	file=$3
	
	str=`echo $node | cut -f2 -d '=' | tr '[:lower:]' '[:upper:]'`
    host="${str}_HOST"
	new_length=`/usr/bin/rsh -l root ${!host} "wc -l $logfile" | awk '{ print \$1 }'`
	diff_length=$((new_length - length))
	/usr/bin/rsh -l root ${!host} "cat $logfile | head -$new_length | tail -$diff_length" > $file

else
	echo "Syntax ERROR..." >&2
	exit 1
fi
