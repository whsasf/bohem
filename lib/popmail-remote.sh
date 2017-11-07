#!/bin/bash

####
####
#### This script will SSH to a remote host and run sendmail.pl to send a message from that host to a specified mail server
#### This is useful if you need to test behaviour of a server towards connections from various different source IP addresses
####

usage()
{
	cat <<- EOF
		
		  popmail-remote.sh remote-server pop-server pop-server-port username password message
		
		    remote-server is a server name as understood by SSH. For example host or host.domain or user@host.domain
		
		EOF
	exit 1
}

local_ip_args=""

if [ "$1" = "-localip" ]; then
	local_ip_args="-localip $2"
	shift
	shift
fi

remote_server=$1
pop_server=$2
pop_server_port=$3
user=$4
password=$5
message=$6


ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes $remote_server bin/popmail.pl $local_ip_args $pop_server $pop_server_port $user $password $message

