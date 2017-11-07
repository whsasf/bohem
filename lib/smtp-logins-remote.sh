#!/bin/bash

####
####
#### This script will SSH to a remote host and run smtp-logins to perform a login from that host to a specified mail server
#### This is useful if you need to test behaviour of a server towards connections from various different source IP addresses
####

usage()
{
	cat <<- EOF
		
		smtp-logins-remote.sh login_option remote-server mail-server mail-server-smtp-port user password
		
		remote-server is a server name as understood by SSH. For example host or host.domain or user@host.domain
		mail-server is the hostname/IP of your mail server with an optional port argument if you are not using port 25.
		user is the RFC2821 envelope sender
		passowrd is the password for the user 
		EOF
	exit 1
}

if [ $# -ne 6 ]; then
	usage
fi

login_option=$1
remote_server=$2
mail_server=$3
mail_server_port=$4
user=$5
password=$6

ipv6check=$(echo "$mail_server" | cut -f 2 -d ']')
if [ "$ipv6check" = "$mail_server" ]; then
	### No IPv6 in use
	port=$(echo "$mail_server" | cut -f 2 -d ':')
	if [ "$port" != "$mail_server" ]; then
		mail_server_port=$port
		mail_server=$(echo "$mail_server" | cut -f 1 -d ':')
	fi
else
	### IPv6 in use
	port=$(echo "$ipv6check" | cut -f 2 -d ':')
	if [ "$port" != "" ]; then
		mail_server_port=$port
		mail_server=$(echo "$mail_server" | cut -f 1 -d ']')
		mail_server="$mail_server]"
	fi
fi


echo "User login from server: $remote_server"
echo "User login to server: $mail_server"
echo "user login to mail server port: $mail_server_port"

## This command will eat STDIN
## And the return value will be directly returned
ssh -o StrictHostKeyChecking=no -o BatchMode=yes $remote_server bin/smtp-logins $login_option $mail_server $mail_server_port $user $password

