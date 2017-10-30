#!/bin/bash

####
####
#### This script will SSH to a remote host and run sendmail.pl to send a message from that host to a specified mail server
#### This is useful if you need to test behaviour of a server towards connections from various different source IP addresses
####

usage()
{
	cat <<- EOF
		
		  sendmail-connect-remote.sh remote-server mail-server[:port]
		
		    remote-server is a server name as understood by SSH. For example host or host.domain or user@host.domain
		    mail-server is the hostname/IP of your mail server with an optional port argument if you are not using port 25.
		    sender is the RFC2821 envelope sender
		    recipient is the RFC2821 envelope recipient
		
		    Message data is read from standard input and is expected to be compliant with RFC2822 (although this is not enforced)
		
		EOF
	exit 1
}

if [ $# -ne 2 ]; then
	usage
fi

remote_server=$1
mail_server_port=25
mail_server=$2

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


echo "Send mail from server: $remote_server"
echo "Send to mail server: $mail_server"
echo "Send to mail server port: $mail_server_port"

## This command will eat STDIN
## And the return value will be directly returned
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes $remote_server bin/sendmail-connect.pl $mail_server $mail_server_port

