#!/usr/bin/perl
#
# Usage: popmail.pl <host> <port> <user> <pass> 
# 		Mail data is output to stdout.
#
# Pop the most recent message..
#
# Connect to <host>:<port>
# Send USER <user>
# Send PASS <pass>
# Send RETR <number>
# Send <cat to stdout>
# Send QUIT

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$USER=$ARGV[2];
$PASS=$ARGV[3];

my($smtpSession,$telnetResult);

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
$rc = $smtpSession->sendCommand ("USER $USER");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 3
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] != "+OK") {
	printf "Didn't get OK for USER\n";
}

$rc = $smtpSession->sendCommand ("PASS $PASS");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 4
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] ne "+OK") {
	printf "Didn't get OK for PASS\n";
	exit 10
}

$rc = $smtpSession->smtp_disconnect();

exit 0;
