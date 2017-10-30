#!/usr/bin/perl
#
# Usage: sendmail.pl <host> <port> <from> <to> [<another-to>] .......
# 		Mail data is expected on stdin.
#
# Connect to <host>:<port>
# Send HELO
# Send MAIL FROM:<from>
# Send RCPT TO:<to>
# Send DATA
# Send <whatever comes in on stdin>
# Send .
# Send QUIT

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$FROM=$ARGV[2];
$TO=$ARGV[3];

my($smtpSession,$telnetResult);

$smtpSession = smtp::new();
if($smtpSession == 0) {
	print "Telnet failed";
	exit 1;
}
$smtpSession->setVerbose ("OFF");
$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	printf "Login failed";
	exit 2
}
$x = $smtpSession->get_response();
$rc = $smtpSession->sendCommand ("HELO freaker");
if($rc != 1) {
	printf "Got an ERROR response";
	exit 3
}
$x = $smtpSession->get_response();
$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>");
if($rc != 1) {
	printf "Got an ERROR response";
	exit 4
}
$x = $smtpSession->get_response();
$arg=3;
while($TO ne "") {
	$rc = $smtpSession->sendCommand ("RCPT TO:<$TO>");
	if($rc != 1) {
		printf "Got an ERROR response";
		exit 5
	}
	$x = $smtpSession->get_response();
	$arg = $arg + 1;
	$TO=$ARGV[$arg];
}
$rc = $smtpSession->sendCommand ("DATA");
if($rc != 1) {
	printf "Got an ERROR response";
	exit 6
}
$x = $smtpSession->get_response();
open(FH,"-");
while (defined($line = <FH>)) {
	chomp $line;
        if($line =~ m/^\./) {
                $line = "." .  $line;
        }
	$rc = $smtpSession->sendCommand ("$line");
	if($rc != 1) {
		printf "error sending data\n";
		exit 7;
	}
}

$rc = $smtpSession->sendCommand (".");
if($rc != 1) {
	printf "Got an ERROR response";
	exit 8
}
$x = $smtpSession->get_response();

$rc = $smtpSession->smtp_disconnect();

exit 0;
