#!/usr/bin/perl
#
# Usage: sendmail-connect.pl <host> <port>
#
# Returns ??????

# Connect to <host>:<port>
# Disconnect

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

my $HOST=$ARGV[0];
my $PORT=$ARGV[1];

my $smtpSession;

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

$rc = $smtpSession->smtp_disconnect();

exit 0;
