#!/usr/bin/env bash

# $Header: /home/kbreslin/cvs/bohem/lib/dd_delete.bash,v 1.1 2007-10-19 09:55:05 mlehky Exp $
# Original source is unknown!

#
#	Delete a distributed domain called "$1" on servers "$2...."
#
#

DOMAIN=$1
shift

SERVERS=$*

for SERVER in $SERVERS; do
	echo "Will delete distributed domain \"$DOMAIN\" from server: $SERVER"
done

exists="NO"
for SERVER in $SERVERS; do
	echo "Domain $DOMAIN already exists on $SERVER - deleting"
	manager.pl $SERVER $man_smtp_port $man_smtp_pass "DOMAIN DELETE $DOMAIN"
	RC=$?
	if [ $RC -ne 0 ]; then
		echo "Couldn't delete $DOMAIN from $SERVER - aborting"
		exit 1
	fi
done

first=true
for SERVER in $SERVERS; do
	if [ $first = "true" ]; then
		echo "Do the GLOBAL DOMAIN DELETE on the first server"
		manager.pl $SERVER $man_smtp_port $man_smtp_pass "GLOBAL DOMAIN DELETE $DOMAIN"
		if [ $? -ne 0 ]; then
			echo "GLOBAL DOMAIN DELETE failed"
			exit 1
		fi
		first=false
	fi
done

echo "Domain $DOMAIN deleted"

exit 0
