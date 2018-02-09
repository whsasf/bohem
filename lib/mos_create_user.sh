#!/bin/bash

### NOTE: This script DOES use MOS.
##
## Create a USER
##
## mos_create_user.sh <mos_host> <mos_port> <user> <password> [<options>]
##
## Options:
##              --maillogin <mailloginname>
##              --alternate-address <address1>[,<address2[,...]]
##              --password-algorithm (clear|md5-po|unix|sha1|ssha1)
##              --max-msg-per-sender <space-separated-list-of-numbers>
##              --max-rcpt-per-msg <space-separated-list-of-numbers>
##              --mcafee-outbound-action Allow|Clean|Discard|Repair> (or anything)
##              --mcafee-outbound-action <Allow|Clean|Discard|Repair> (or anything)
##              --ext-service-attributes <some-string>
##              --hmac-password <hmac-string>
##
###
###

#set -x

mos_host=$1
mos_port=$2
email=$3
password=$4

shift 4

echo "Shifted 7 - $1"
pass_algorithm="clear"
convert_opt=""
max_msg_per_sender=""
max_rcpt_per_msg=""
mcafee_outbound_action=""
mcafee_inbound_action=""
ext_service_attributes=""
class="default"
junkmail=""
useralias=""
hmacpassword=""
mxversion=""
alt_address=""
user_status="A"

args=""

while [ $# -gt 0 ]; do
        if [ "$1" = "--class-of-service" ]; then
                class=$2
                shift
        elif [ "$1" = "--junk-mail-action" ]; then
                junkmail=$2
                args="$args -d junkmailAction=$2"
                shift
        elif [ "$1" = "--user-status" ]; then
                user_status=$2
                args="$args -d status=$2"
                shift
        elif [ "$1" = "--alternate-address" ]; then
                useralias=$2
                shift
        else
                echo "Don't understand option $1"
                exit 1
        fi
        shift
done

aliases=""
if [ "$useralias" != "" ]; then
        for addr in $(echo "$useralias" | tr ',' ' ')
        do
                aliases="${aliases}emailAlias=$addr&"
        done
        aliases=${aliases%?} #Cut away last &
fi

curl -X PUT -v -d email=$email -d password=$password -d cosId=$class $args http://$mos_host:$mos_port/mxos/mailbox/v2/$email

if [ "$useralias" != "" ]; then
        curl -X PUT -v -d email=$email -d password=$password -d cosId=$class -d $aliases http://$mos_host:$mos_port/mxos/mailbox/v2/$email/base/emailAliases
fi

echo "TIME User create: $SECONDS"
exit 0

