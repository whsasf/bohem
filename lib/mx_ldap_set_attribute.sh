#!/bin/bash

set -x

dn="$1"
attribute="$2"
value="$3"

cat > tmp.ldif <<- EOF
		dn: $dn
		changetype: modify
		replace: $attribute
		$attribute: $value

	EOF


ldapmodify -h $MX1_HOST_IP -p $MX1_LDAP_PORT -D $MX1_LDAP_BIND_DN -w $MX1_LDAP_BIND_PASSWORD < tmp.ldif
