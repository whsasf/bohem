#!/bin/bash

### NOTE: This script does NOT use MOS.
##
## Create a USER
##
## mx_create_class.sh <mxuser> <mxhost> <mx-install-path> <ldap-port> <domain> <username> <password> [ OPTIONS ]
##
## Options:
##		--password-algorithm (clear|md5-po|unix|sha1|ssha1)
##		--max-msg-per-sender <space-separated-list-of-numbers>
##		--max-rcpt-per-msg <space-separated-list-of-numbers>
##		--mcafee-outbound-action Allow|Clean|Discard|Repair> (or anything)
##		--mcafee-outbound-action <Allow|Clean|Discard|Repair> (or anything)
##		--ext-service-attributes <some-string>
##
###
### mxhost must be an IP address
###

set -x

user=$1
host=$2
prefix=$3
port=$4
new_class=$5

shift 5

echo $host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh_port=$(echo $host | cut -f 2 -d ':')
	host=$(echo $host | cut -f 1 -d ':')
else
	ssh_port=22
fi

max_msg_per_sender=""
max_rcpt_per_msg=""
mcafee_outbound_action=""
mcafee_inbound_action=""
ext_service_attributes=""
maildeliveryoption="P"

while [ $# -gt 0 ]; do
	if [ "$1" = "--max-msg-per-sender" ]; then
		max_msg_per_sender=$2
		shift
	elif [ "$1" = "--max-rcpt-per-msg" ]; then
		max_rcpt_per_msg=$2
		shift
	elif [ "$1" = "--mcafee-outbound-action" ]; then
		mcafee_outbound_action=$2
		shift
	elif [ "$1" = "--mcafee-inbound-action" ]; then
		mcafee_inbound_action=$2
		shift
	elif [ "$1" = "--ext-service-attributes" ]; then
		ext_service_attributes=$2
		shift
	else
		echo "Don't understand option $1"
		exit 1
	fi
	shift
done

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh_port $user@$host $prefix/bin/imldapsh -D cn=root -W secret -H ${OWM_CONFSERV1_HOST} -P $port CreateCos $new_class
if [ $? -ne 0 ]; then
	ts=$(date +%d/%m/%Y\ %H:%M:%S)
	sleep 30
	ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh_port $user@$host $prefix/bin/imldapsh -D cn=root -W secret -H ${OWM_CONFSERV1_HOST} -P $port CreateCos $new_class
	if [ $? -eq 0 ]; then
		echo "WARNING: $ts imldapsh issues adding class $new_class in test $TC_NAME (retry ok)" >> $WORK_DIR/../warnings
	else
		echo "WARNING: $ts imldapsh issues adding class $new_class in test $TC_NAME (retry also failed)" >> $WORK_DIR/../warnings
	fi
fi

# 

rm -f tmp.ldif

if [ "$maildeliveryoption" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: maildeliveryoption
			maildeliveryoption: $maildeliveryoption

			EOF
fi

if [ "$max_msg_per_sender" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: msgcountpermailfromtoblock
			msgcountpermailfromtoblock: $max_msg_per_sender

			EOF
fi

if [ "$max_rcpt_per_msg" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: rcpttocountpermailfromtoblock
			rcpttocountpermailfromtoblock: $max_rcpt_per_msg

			EOF
fi

if [ "$mcafee_inbound_action" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: mailMcafeeInboundVirusAction
			mailMcafeeInboundVirusAction: $mcafee_inbound_action

			EOF
fi

if [ "$mcafee_outbound_action" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: mailMcafeeOutboundVirusAction
			mailMcafeeOutboundVirusAction: $mcafee_outbound_action

			EOF
fi

if [ "$ext_service_attributes" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: cn=$new_class,cn=admin root
			changetype: modify
			add: mailextensionsserviceattributes
			EOF
	for attr in $(echo $ext_service_attributes | tr ',' ' ')
	do
		echo "mailextensionsserviceattributes: $attr" >> tmp.ldif
	done
	echo "" >> tmp.ldif
fi

cat tmp.ldif

if [ -f tmp.ldif ];
then
	ldapmodify -h $MX1_HOST_IP -p $MX1_LDAP_PORT -D $MX1_LDAP_BIND_DN -w $MX1_LDAP_BIND_PASSWORD < tmp.ldif
	if [ $? -ne 0 ]; then
		ts=$(date +%d/%m/%Y\ %H:%M:%S)
		sleep 30
		ldapmodify -h $MX1_HOST_IP -p $MX1_LDAP_PORT -D $MX1_LDAP_BIND_DN -w $MX1_LDAP_BIND_PASSWORD < tmp.ldif
		if [ $? -eq 0 ]; then
			echo "WARNING: $ts ldapmodify issues adding class $new_class in test $TC_NAME (retry ok)" >> $WORK_DIR/../warnings
		else
			echo "WARNING: $ts ldapmodify issues adding class $new_class in test $TC_NAME (retry also failed)" >> $WORK_DIR/../warnings
		fi
	fi
fi

echo "TIME User create: $SECONDS"
exit 0
