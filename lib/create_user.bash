#!/usr/bin/env bash

# $Header: /home/kbreslin/cvs/bohem/lib/create_user.bash,v 1.1 2007-10-19 09:55:05 mlehky Exp $
# Original source is unknown!

# This script tries to create a domain and user
#  If the domain already exists, it will be deleted first.
#
# Usage:
#	create_user.bash <local> <domain> [ <extra options for user add> ]
#
#

user_name=$1
domain_name=$2
USEROPTIONS=$3

TMPFILE=/tmp/create_user.$$

# Check for domain
#  Delete it
# Create domain
# Create user

# Check for domain
manager.pl $host_name $man_smtp_port $man_smtp_pass "DOMAIN VERIFY $domain_name" > $TMPFILE
if [ $? -ne 0 ]
then
	echo "Domain verify failed"
	rm $TMPFILE
	exit 1
fi
cat $TMPFILE | grep "^* TRUE" >/dev/null 2>&1
if [ $? -eq 0 ]
then
	# Delete it
	echo "domain already exists - deleting"
	manager.pl $host_name $man_smtp_port $man_smtp_pass "DOMAIN DELETE $domain_name"
	if [ $? -ne 0 ]
	then
		echo "Domain delete failed - script will probably fail now"
	fi
fi
	
# Create domain

echo "Creating domain"
manager.pl $host_name $man_smtp_port $man_smtp_pass "DOMAIN ADD $domain_name NEW"
if [ $? -ne 0 ]
then
	echo "DOMAIN ADD failed"
	exit 1
fi

# Add a user
# Create user
echo "Creating user"
manager.pl $host_name $man_smtp_port $man_smtp_pass "USER $domain_name ADD $user_name NEW MAILBOX=${mailbox_path}/$domain_name/$user_name $USEROPTIONS"
if [ $? -ne 0 ]
then
	echo "USER ADD failed"
	exit 1
fi

rm $TMPFILE

exit 0

