#!/usr/bin/perl
#
# Usage: pop-cap.pl <host> <port> 
#
# Pop the server capabilities
#
# Connect to <host>:<port>
# Send CAPA
# Send <cat to stdout>
# Send QUIT

require "$ENV{'_bohem_dir'}/lib/smtp.pm";


$HOST=$ARGV[0];
$PORT=$ARGV[1];

my($smtpSession,$telnetResult);

print "pop-cap: host[$HOST] port[$PORT] \n";

$smtpSession = smtp::new();
if($smtpSession == 0) {
	printf "Telnet failed\n";
	exit 1;
}
$smtpSession->setVerbose ("OFF");
$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	printf "Login failed\n";
	exit 2
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] != "+OK") {
	printf "Didn't get OK for greeting\n";
	exit 10
}



$rc = $smtpSession->sendCommand ("CAPA");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 5
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] != "+OK") {
	printf "Didn't get OK for CAPA\n";
	exit 14
}

$x = $smtpSession->get_response();
$dot = 0;
while($dot == 0) {
	if($x eq ".\r\n") {
		$dot = 1;
	} else {
		printf "$x";
		$x = $smtpSession->get_response();
	}
}
$rc = $smtpSession->sendCommand ("QUIT");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 6
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] != "+OK") {
	printf "Didn't get OK for QUIT\n";
	exit 15
}


$rc = $smtpSession->smtp_disconnect();

exit 0;
