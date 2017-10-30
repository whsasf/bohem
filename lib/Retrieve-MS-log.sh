#!/bin/bash

if [ "$1" = "--get-location" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 2 -- Syntax: Retrieve-MS-log.sh --get-location <node_name> <module>" >&2
		echo "                       module is one of \"smtp\" \"ims\""
		exit 2
	fi

	id=$2
	module=$3
	
	var=CPMS${id}_HOST; host=${!var}
	case "$module" in
		"smtp")
			var=CPMS${id}_SMTP_MGMT_PORT ; port=${!var}
			logvar="LogDir"
                        flushkeyword="SMTP"
			;;
		"ims")
			var=CPMS${id}_IMS_MGMT_PORT ; port=${!var}
			logvar="LogDirectory"
                        flushkeyword="MS"
			;;

                "loginproxy")
                        var=CPMS${id}_LOGINPROXY_MGMT_PORT ; port=${!var}
                        logvar="LogDirectory"
                        flushkeyword=""
                        ;;
                "ldapconn")
                        var=CPMS${id}_LDAPCONN_MGMT_PORT ; port=${!var}
                        logvar="LogDir"
                        flushkeyword="LDAPCONN"
                        ;;
                "listexpander")
                        var=CPMS${id}_LISTEXPANDER_MGMT_PORT ; port=${!var}
                        logvar="LogDir"
                        flushkeyword="LISTEXPANDER"
                        ;;
		*)
			echo "$0: module [$module] unknown" >&2
			exit 1
			;;
	esac
	var=CPMS${id}_PASSWORD; pass=${!var}

	logdir=`manager.pl $host $port $pass "GET $logvar" | cut -f 2 -d \'`
	logfile=`ssh -o BatchMode=yes root@$host ls -1v $logdir/$module-*log | tail -1`
	len=`ssh -o BatchMode=yes root@$host wc -l $logfile | awk '{ print $1 }'`
	echo "$id:$module:$logfile:$len"

elif [ "$1" = "--get-logfile" ]; then

	if [ $# -ne 3 ]; then
		echo "ERROR 3 -- Syntax: Retrieve-MS-log.sh --get-logfile <instance-number>:$module:<log_file>:<old_length> <output_file>" >&2
		exit 3
	fi

	id=`echo $2 | cut -f1 -d:`
	module=`echo $2 | cut -f2 -d:`
	logfile=`echo $2 | cut -f3 -d:`
	len=`echo $2 | cut -f4 -d:`
	file=$3

        var=CPMS${id}_HOST; host=${!var}
        case "$module" in
                "smtp")
                        var=CPMS${id}_SMTP_MGMT_PORT ; port=${!var}
                        logvar="LogDir"
                        flushkeyword="SMTP"
                        ;;
                "ims")
                        var=CPMS${id}_IMS_MGMT_PORT ; port=${!var}
                        logvar="LogDirectory"
                        flushkeyword="MS"
                        ;;
                "loginproxy")
                        var=CPMS${id}_LOGINPROXY_MGMT_PORT ; port=${!var}
                        logvar="LogDirectory"
                        flushkeyword=""
                        ;;
                "ldapconn")
                        var=CPMS${id}_LDAPCONN_MGMT_PORT ; port=${!var}
                        logvar="LogDir"
                        flushkeyword="LDAPCONN"
                        ;;
                "listexpander")
                        var=CPMS${id}_LISTEXPANDER_MGMT_PORT ; port=${!var}
                        logvar="LogDir"
                        flushkeyword="LISTEXPANDER"
                        ;;
                *)
                        echo "$0: module [$module] unknown" >&2
                        exit 1
                        ;;
        esac
        var=CPMS${id}_PASSWORD; pass=${!var}

	manager.pl $host $port $pass "LOGGING FLUSH $flushkeyword"
	logdir=`manager.pl $host $port $pass "GET $logvar" | cut -f 2 -d \'`
	logfile2=`ssh -o BatchMode=yes root@$host ls -1v $logdir/$module-*log | tail -1`
	if [ "$logfile2" != "$logfile" ]; then
		## crap, log rotated...
		newlen=`ssh -o BatchMode=yes root@$host wc -l $logfile | awk '{ print $1 }'`
		diff=$((newlen - len))
		newlen2=`ssh -o BatchMode=yes root@$host wc -l $logfile2 | awk '{ print $1 }'`
		ssh -o BatchMode=yes root@$host "cat $logfile | head -$newlen | tail -$diff ; cat $logfile2 | head -$newlen2" > $file
	else
		newlen=`ssh -o BatchMode=yes root@$host wc -l $logfile | awk '{ print $1 }'`
		diff=$((newlen - len))
		ssh -o BatchMode=yes root@$host "cat $logfile | head -$newlen | tail -$diff" > $file
	fi
else
	echo "ERROR 1 -- Syntax:"
	echo " Retrieve-MS-log.sh --get-location <node_name> <module>" >&2
	echo " Retrieve-MS-log.sh --get-logfile <instance-number>:<module>:<log_file>:<old_length> <output_file>" >&2
	echo "                       module is one of \"smtp\" \"ims\""
	exit 1
fi

