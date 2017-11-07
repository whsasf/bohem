#!/bin/bash

set -x

get_logfile_name()
{
	local hostname=$1
	local log=$2
	local path=$3
	local port=$4
	local oldlog_file=$5

	if [ "$log" = "policy" ]; then
		ssh -o BatchMode=yes -p $port root@${hostname} "MIRA_ROOT=$path/mira/ $path/mira/usr/bin/mgr.sh -s ${hostname} -p $RG_SMTPD_MGMT_PORT get separatepolicylog" | grep "\<0\>" > /dev/null
		if [ $? -eq 0 ]; then
			log="smtp"
		fi
	fi
	if [ "$log" = "policy" ]; then
		policy_logs=`ssh -o BatchMode=yes -p $port root@${hostname} "ls $path/mira/usr/store/logs/policy-engine*log"`
		if [ "$policy_logs" = "" ]; then
			### Must be an old box
			log="smtp"
		fi
	fi

	if [ "$log" = "smtp" ]; then
		smtp_logs=`ssh -o BatchMode=yes -p $port root@${hostname} "ls $path/mira/usr/store/logs/smtp*log"`
		if [ "$smtp_logs" = "" ]; then
			filespec="$path/mira/usr/store/smtp/smtp/log/smtp*log"
		else
			filespec="$path/mira/usr/store/logs/smtp*log"
		fi
	elif [ "$log" = "policy" ]; then
		filespec="$path/mira/usr/store/logs/policy*log"
	else
		filespec="$path/mira/usr/store/logs/${log}*log"
	fi

	logfile=`ssh -o BatchMode=yes -p $port root@${hostname} "ls -1rt $filespec | tail -1"`
	if [ "$oldlog_file" != "" ] && [ "$oldlog_file" != "$logfile" ]; then
		local files=`ssh -o BatchMode=yes -p $port root@${hostname} "ls -1rt $filespec | tail -15"`
		local found=0
		logfile=""

		for l in $files
		do
			if [ "$l" = "$oldlog_file" ]; then
				found=1
			else
				if [ $found -eq 1 ]; then
					logfile="${logfile}$l "
				fi
			fi
		done

		logfile="${logfile%% }"
	fi
}

calculate_host_from_node()
{
	local _node=$1

	host="nohost.invalid"
	chost="nohost.invalid"
	path=""

	for f in `seq 1 10`
	do
		var="RG_SMTP${f}_NODE" ; n=${!var}
		if [ "$n" = "$_node" ]; then
			var="RG_SMTP${f}_HOST" ; host=${!var}
			var="RG_CONSOLE${f}_HOST" ; chost=${!var}
			var="RG_SMTP${f}_INSTALL" ; path=${!var}
			var="RG_SMTP${f}_SSH_PORT" ; port=${!var}
			break
		fi
	done
}

if [ "$1" = "--get-location" ]; then
	
	if [ $# -eq 4 ]
	then
		if [ "$4" == "--nocm" ]
		then
			nocm="true"
		else
			echo "ERROR 2 -- Syntax: Retrieve-RG-log.sh --get-location node=<node_name> <log> [--nocm]" >&2
			exit 2
		fi
	elif [ $# -ne 3 ]; then
		echo "ERROR 2 -- Syntax: Retrieve-RG-log.sh --get-location node=<node_name> <log> [--nocm]" >&2
		exit 2
	fi
	calculate_host_from_node `echo $2 | cut -f2 -d '='`

	log=$3

	if [ "$chost" = "" ] || [ "$chost" = "nohost.invalid" ] || [ "$nocm" = "true" ]
	then
		true ## Need to SSH and call mgr
	else
		if [ "$log" = "smtp" ] || [ "$log" = "policy" ]; then
			manager.pl $RG_CONSOLE1_HOST $RG_CONSOLE1_PORT $RG_CONSOLE1_PASSWORD "RGT LOGGING FLUSH $2" >&2 || exit 2
		fi
		sleep 3
	fi

	get_logfile_name ${host} $log "$path" $port

	length=`ssh -o BatchMode=yes -p $port root@${host} "wc -l \"$logfile\"" | awk '{ print \$1 }'`
	echo "$2:$logfile:$length:$log"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -eq 4 ]
	then
		if [ "$4" == "--nocm" ]
		then
			nocm="true"
		else
			echo "ERROR 3 -- Syntax: Retrieve-RG-smtp-log.sh --get-logfile node=<node_name>:log_file:old_length:<log> output_file [--nocm]" >&2
			exit 3
		fi
	elif [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-smtp-log.sh --get-logfile node=<node_name>:log_file:old_length:<log> output_file [--nocm]" >&2
		exit 3
	fi

	node=`echo $2 | cut -f1 -d:`
	old_logfile=`echo $2 | cut -f2 -d:`
	length=`echo $2 | cut -f3 -d:`
	log=`echo $2 | cut -f4 -d:`

	if [ "$node" = "" ] || [ "$log" = "" ]; then
		echo "ERROR 3 -- Syntax: Retrieve-RG-smtp-log.sh --get-old_logfile node=<node_name>:log_file:old_length:<log> output_file" >&2
		exit 3
	fi

	file=$3

	calculate_host_from_node `echo $2 | cut -f 1 -d ':' | cut -f2 -d '='`

	if [ "$chost" = "" ] || [ "$chost" = "nohost.invalid" ] || [ "$nocm" = "true" ]
	then
		true ## Need to SSH and call mgr
		ssh -o BatchMode=yes -p $port root@${host} "MIRA_ROOT=$path/mira $path/mira/usr/bin/mgr.sh -s $host -p 4200 LOGGING FLUSH SMTP"
		ssh -o BatchMode=yes -p $port root@${host} "MIRA_ROOT=$path/mira $path/mira/usr/bin/mgr.sh -s $host -p 4235 LOGGING FLUSH COUNTERS"
		ssh -o BatchMode=yes -p $port root@${host} "MIRA_ROOT=$path/mira $path/mira/usr/bin/mgr.sh -s $host -p 4237 LOGGING FLUSH SOPHOSAS"
	else
		manager.pl $RG_CONSOLE1_HOST $RG_CONSOLE1_PORT $RG_CONSOLE1_PASSWORD "RGT LOGGING FLUSH $node" >&2 || exit 2
		sleep 3
	fi

	get_logfile_name ${host} $log "$path" $port "$old_logfile"

	if [ "$old_logfile" != "$logfile" ]; then
		new_length=`ssh -o BatchMode=yes -p $port root@${host} "wc -l $old_logfile" | awk '{ print \$1 }'`
		diff_length=$((new_length - length))
		ssh -o BatchMode=yes -p $port root@${host} "cat $old_logfile | head -$new_length | tail -$diff_length" > $file
		for l in $logfile
		do
			new_length2=`ssh -o BatchMode=yes -p $port root@${host} "wc -l $l" | awk '{ print \$1 }'`
			ssh -o BatchMode=yes -p $port root@${host} "cat $l | head -$new_length2" >> $file
		done
	else
		new_length=`ssh -o BatchMode=yes -p $port root@${host} "wc -l $old_logfile" | awk '{ print \$1 }'`
		diff_length=$((new_length - length))
		ssh -o BatchMode=yes -p $port root@${host} "cat $old_logfile | head -$new_length | tail -$diff_length" > $file
	fi
else
	echo "Syntax ERROR..." >&2
	exit 1
fi
