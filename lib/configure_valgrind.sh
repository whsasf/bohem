#!/bin/bash

set -x

if [ $# -lt 4 ]; then
	echo "ERROR: usage: $0 <console-id> <rg-host-id>[,<rg-host-id>...] <module> <state>"
	exit 1
fi

### Only if your RazorGate was configured to use Valgrind in the first place...
### Also, only if you explicitly set ALLOW_VALGRIND_DISABLE to "yes"

if [ "$(echo $ALLOW_VALGRIND_DISABLE | tr [:upper:] [:lower:])" != "yes" ]; then
	echo "Not permitted to disable valgrind"
	exit 4
fi

if [ "$RUNNING_WITH_VALGRIND" != "Yes" ]; then
	echo "Valgrind isn't even active.."
	exit 5
fi

console_id=$1
nodes=$2
module=$3
state=$4

root_dir="$WORK_DIR/../"

off_notice="WARNING: Valgrind was deactivated during test run, and never reactivated"

get_host_from_node()
{
	node=$1
	host=nohost.invalid

	for id in `seq 1 10`
	do
		var="RG_SMTP${id}_NODE" ; n=${!var}
		if [ "$n" = "$node" ]; then
			var="RG_SMTP${id}_HOST" ; host=${!var}
			var="RG_SMTP${id}_HOST_IP" ; ip=${!var}
			var="RG_SMTP${id}_SSH_PORT" ; port=${!var}
			var="RG_SMTP${id}_INSTALL" ; dir=${!var}
			break
		fi
	done
}

update_notice()
{
	state=$1
	if [ "$state" = "on" ]; then
		## Do we think it is off ?
		grep -v "$off_notice" $root_dir/warnings > $root_dir/warnings.new
		test -s $root_dir/warnings.new && mv $root_dir/warnings.new $root_dir/warnings || rm $root_dir/warnings.new $root_dir/warnings
	elif [ "$state" = "off" ]; then
		echo "$off_notice" >> $root_dir/warnings
		date >> $root_dir/valgrind_deactivated
		x=$(wc -l $root_dir/valgrind_deactivated | awk '{ print $1 }')
		if [ $x -eq 1 ]; then
			echo "Valgrind detection has been deactivated for 1 test." > $root_dir/notices
		else
			sed -i "s/Valgrind detection has been deactivated.*/Valgrind detection has been deactivated for $x tests./" $root_dir/notices
		fi
	fi
}

if [ "$module" = "smtpd" ] || [ "$module" = "countersd" ]
then
	if [ "$state" = "on" ]
	then
		for node in $(echo $nodes | tr ',' ' ')
		do
			get_host_from_node $node
			ssh -o BatchMode=yes -p $port root@$host "rm -f $dir/mira/var/tmp/suppress_debugger-$module"
		done
		update_notice on
	elif [ "$state" = "off" ]
	then
		for node in $(echo $nodes | tr ',' ' ')
		do
			get_host_from_node $node
			ssh -o BatchMode=yes -p $port root@$host "touch $dir/mira/var/tmp/suppress_debugger-$module"
		done
		update_notice off
	else
		echo "ERROR: Unknown state \"$state\""
		exit 3
	fi
	stop_razorgate_service.sh $console_id $nodes $module
	start_razorgate_service.sh $console_id $nodes $module
	exit 0
else
	echo "ERROR: Unknown module \"$module\""
	exit 2
fi

exit 1
	
