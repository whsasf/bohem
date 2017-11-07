#!/bin/bash

### NOTE: This script DOES use MOS.
##
## Create a class
##
#mx_create_domain.sh <mxhost> <domain>
set -x

mos_host=$1
mos_port=$2
cos=$3

args=""

shift 3
while [ $# -gt 0 ]; do
	if [ "$1" = "--junk-mail-action" ]; then
		args="$args -d junkmailAction=$2"
		shift
	else
		echo "Don't understand option $1"
		exit 1
	fi
	shift
done

curl -X PUT -v -d cosId=$cos $args  http://$mos_host:$mos_port/mxos/cos/v2/$cos

echo "TIME Class create: $SECONDS"
exit 0
