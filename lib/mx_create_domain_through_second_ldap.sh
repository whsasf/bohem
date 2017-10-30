#!/bin/bash

### NOTE: This script does NOT use MOS.
##
## Create a domain
##
#mx_create_domain.sh <mxhost> <domain>
set -x

mx1user=$1
mx1host=$2
mx1prefix=$3
mx2user=$4
mx2host=$5
port=$6
domain=$7

shift 7
while [ $# -gt 0 ]; do
	if [ "$1" = "--relayhost" ]; then
		relayhost=$2
		shift
	else
		echo "Don't understand option $1"
		exit 1
	fi
	shift
done

echo $mx1host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh1_port=$(echo $mx1host | cut -f 2 -d ':')
	mx1host=$(echo $mx1host | cut -f 1 -d ':')
else
	ssh1_port=22
fi

echo $mx2host | grep -q ':'
if [ $? -eq 0 ]; then
	ssh2_port=$(echo $mx2host | cut -f 2 -d ':')
	mx2host=$(echo $mx2host | cut -f 1 -d ':')
else
	ssh2_port=22
fi

ldapHost=`ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh2_port $mx2user@$mx2host hostname -s`

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -p $ssh1_port $mx1user@$mx1host $mx1prefix/bin/imldapsh -D cn=root -W secret -H $ldapHost -P $port  CreateDomain $domain local

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

	ldapmodify -h $mx2host -p $port -D $MX1_LDAP_BIND_DN -w $MX1_LDAP_BIND_PASSWORD < tmp.ldif
fi

echo "TIME Domain create: $SECONDS"
exit 0
