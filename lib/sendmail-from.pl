#!/usr/bin/perl
#
# Usage: sendmail-from.pl <host> <port> <from>
#
# Returns 100 plus the first digit of the SMTP code from the FROM
#     (or number <100 for error)

# Connect to <host>:<port>
# Send EHLO
# Send MAIL FROM:<from>
# Disconnect

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

my $HOST=$ARGV[0];
my $PORT=$ARGV[1];
my $FROM=$ARGV[2];

my $smtpSession;

print "Establish SMTP session using ID='$ID' MAILFROM='$FROM'\n";

# initiate session

$smtpSession = smtp::new();
if($smtpSession == 0) {
	print "Telnet failed\n";
	exit 1;
}
$smtpSession->setVerbose ("ON");
$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	print "Login failed\n";
	exit 2
}
$x = $smtpSession->get_response();

# send EHLO

$rc = $smtpSession->sendCommand ("EHLO foo.foo");
if($rc != 1) {
	print "Got an ERROR response from EHLO\n";
	exit 3
}
$x = $smtpSession->get_multiline_response();
$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>");
if($rc != 1) {
	$x = $smtpSession->get_response(); ######
	print "Sending MAIL FROM failed\n";
	exit 4
}
$x = $smtpSession->get_response();

$rc = $smtpSession->smtp_disconnect();

exit 0;
