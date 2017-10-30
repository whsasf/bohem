#!/usr/bin/perl
#
# Usage: sendmail-from.pl <host> <port> <from> <to> ...
#
# Returns 100 plus the first digit of the SMTP code from the FROM
#     (or number <100 for error)
#
# Connect to <host>:<port>
# Send HELO
# Send MAIL FROM:<from>
# Count how many RCPT TO:<> commands are allowed.
# Disconnect

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$FROM=$ARGV[2];

my($smtpSession,$telnetResult);

$smtpSession = smtp::new();
if($smtpSession == 0) {
	print "Telnet failed\n";
	exit 1;
}
$smtpSession->setVerbose ("ON");
$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	printf "Login failed\n";
	exit 2
}
$x = $smtpSession->get_response();
$rc = $smtpSession->sendCommand ("HELO freaker");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 3
}
$x = $smtpSession->get_response();
$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>");
if($rc != 1) {
	printf "Sending FROM failed\n";
	exit 4
}
$x = $smtpSession->get_response();
$good = 0;
for($i=3;$i<=$#ARGV;$i++) {
	$rc = $smtpSession->sendCommand ("RCPT TO:<$ARGV[$i]>");
	if($rc != 1) {
		printf "Sending RCPT failed\n";
	}
	$x = $smtpSession->get_response();
	@words = split(//, $x);
	if(@words[0] == "2") {
		$good++;
	} else {
		printf "RCPT $ARGV[$i] Not accepted\n";
		## Return the number that did work.
	}
}

printf "All done\n";

## All RCPTs were accepted.
exit (100+$good);

