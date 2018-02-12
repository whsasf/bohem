#!/bin/bash

### NOTE: This script does NOT use MOS.
##
## Create a domain
##
#mx_create_domain.sh <mxhost> <domain>
#set -x

mos_host=$1
mos_port=$2
domain=$3

args=""

shift 3
while [ $# -gt 0 ]; do
	if [ "$1" = "--relayhost" ]; then
		relayhost=$2
		shift
	elif [ "$1" = "--dkim-selector" ]; then
		args="$args -d mailRazorgateSelector=$2"
		shift
	elif [ "$1" = "--defaultMailbox" ]; then
		args="$args -d --defaultMailbox=$2"
		shift
	else
		echo "Don't understand option $1"
		exit 1
	fi
	shift
done

#curl -X PUT -v -d mailRazorgateRelayHost=$relayhost -d type=local $args http://$mos_host:$mos_port/mxos/domain/v2/$domain
curl -s -X PUT -v  -d type=local $args http://$mos_host:$mos_port/mxos/domain/v2/$domain

echo "TIME Domain create: $SECONDS"
exit 0
