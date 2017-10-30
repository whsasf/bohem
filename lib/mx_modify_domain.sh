#!/bin/bash

### NOTE: This script does NOT use MOS.
##
## Modify a domain
##
#mx_modify_domain.sh <mxhost> <domain>
set -x

user=$1
host=$2
prefix=$3
port=$4
domain=$5

echo $host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh_port=$(echo $host | cut -f 2 -d ':')
	host=$(echo $host | cut -f 1 -d ':')
else
	ssh_port=22
fi
### Note that ssh_port is not actually needed in this script.

shift 5
while [ $# -gt 0 ]; do
	if [ "$1" = "--relayhost" ]; then
		relayhost=$2
		shift
	elif [ "$1" = "--defaultmailbox" ]; then
		defaultmailbox=$2
		shift
	else
		echo "Don't understand option $1"
		exit 1
	fi
	shift
done

for f in $(echo $domain | tr '.' ' ')
do
	if [ "$domain_dn" = "" ]; then
		domain_dn="dc=$f"
	else
		domain_dn="$domain_dn,dc=$f"
	fi
done

rm -f tmp.ldif
if [ "$relayhost" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: $domain_dn
			changetype: modify
			add: mailrazorgaterelayhost
			mailrazorgaterelayhost: $relayhost
			EOF
fi

if [ "$defaultmailbox" != "" ] ; then
	cat >> tmp.ldif <<- EOF
			dn: $domain_dn
			changetype: modify
			add: mailwildcardaccount
			mailwildcardaccount: $defaultmailbox
			EOF
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
			echo "WARNING: $ts ldapmodify issues modifying domain $domain in test $TC_NAME (retry ok)" >> $WORK_DIR/../warnings
		else
			echo "WARNING: $ts ldapmodify issues modifying domain $domain in test $TC_NAME (retry also failed)" >> $WORK_DIR/../warnings
		fi
	fi
fi

echo "TIME Domain modify: $SECONDS"
exit 0

