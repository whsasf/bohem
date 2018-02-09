#!/bin/bash

### NOTE: This script DOES use MOS.
##
#set -x

mos_host=$1
mos_port=$2
email=$3

shift 3

curl -s -X DELETE http://$mos_host:$mos_port/mxos/mailbox/v2/$email

echo "TIME User delete: $SECONDS"
exit 0
