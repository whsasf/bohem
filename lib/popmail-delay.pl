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
$DELAY=$ARGV[4];
$MSG=$ARGV[5];

my($smtpSession,$telnetResult);

print "popmail: host[$HOST] port[$PORT] user[$USER] pass[$PASS]\n";

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
if(@words[0] ne "+OK") {
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
if(@words[0] ne "+OK") {
	printf "Didn't get OK for USER\n";
	exit 11
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
	exit 12
}
$rc = $smtpSession->sendCommand ("STAT");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 16
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] ne "+OK") {
	printf "Didn't get OK for STAT\n";
	exit 14
}

$NUMBER=@words[1];
if ($NUMBER == 0) {
	printf "Mailbox empty\n";
	exit 13
}
$NUMBER = "$MSG" if ($MSG);

sleep "$DELAY" if ($DELAY);

$rc = $smtpSession->sendCommand ("RETR $NUMBER");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 5
}
$x = $smtpSession->get_response();
@words = split(/ /, $x);
if(@words[0] ne "+OK") {
	printf "Didn't get OK for RETR\n";
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
if(@words[0] ne "+OK") {
	printf "Didn't get OK for QUIT\n";
	exit 15
}


$rc = $smtpSession->smtp_disconnect();

exit 0;
