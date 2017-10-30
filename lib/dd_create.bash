#!/usr/bin/env bash

# $Header: /home/kbreslin/cvs/bohem/lib/dd_create.bash,v 1.1 2007-10-19 09:55:05 mlehky Exp $
# Original source is unknown!

#
#	Create a distributed domain called "$1" on servers "$2...."
#
#	Before creating it on any server, make sure it doesn't already exist.
#	If it does, delete it first
#

TMPFILE=/tmp/createdd.$$
DOMAIN=$1
shift

SERVERS=$*

for SERVER in $SERVERS; do
	echo "Will create distributed domain \"$DOMAIN\" on server: $SERVER"
done

exists="NO"
for SERVER in $SERVERS; do
	echo "Check does domain exist on server: $SERVER"
	manager.pl $SERVER $man_smtp_port $man_smtp_pass "DOMAIN STATUS $DOMAIN"
	RC=$?
	if [ $RC -eq 0 ]; then
		echo "Domain $DOMAIN already exists on $SERVER - deleting"

		manager.pl $SERVER $man_smtp_port $man_smtp_pass "USER $DOMAIN LIST" > $TMPFILE || exit 1
		cat $TMPFILE
		a="*"
		cat $TMPFILE | grep "^* " | cut -f 1 -d '' | while [ "$a" = "*" ]; do
			read a b user
			if [ "$b" = "USER" ]; then
				echo "Delete user $user"
				manager.pl $SERVER $man_smtp_port $man_smtp_pass "USER $DOMAIN DELETE $user ERASE"
				echo "Delete user returned $?"
			elif [ "$b" != "" ]; then
				echo "Unknown type of user in domain: $a $b $user"
			fi
		done

		manager.pl $SERVER $man_smtp_port $man_smtp_pass "DOMAIN DELETE $DOMAIN"
		RC=$?
		if [ $RC -ne 0 ]; then
			echo "Couldn't delete $DOMAIN from $SERVER - aborting"
			exit 1
		fi
		exists=$SERVER
	fi
done

first=true
for SERVER in $SERVERS; do
	if [ $first = "true" ]; then
		echo "Do the GLOBAL DOMAIN ADD on the first server"
		manager.pl $SERVER $man_smtp_port $man_smtp_pass "GLOBAL DOMAIN DELETE $DOMAIN"
		sleep 1
		echo "Do the GLOBAL DOMAIN ADD on the first server"
		manager.pl $SERVER $man_smtp_port $man_smtp_pass "GLOBAL DOMAIN ADD $DOMAIN" || exit 1
		first=false
	fi
	manager.pl $SERVER $man_smtp_port $man_smtp_pass "DOMAIN ADD $DOMAIN NEW DSA=$dsaname" || exit 1
done

echo "Domain $DOMAIN added"

exit 0
