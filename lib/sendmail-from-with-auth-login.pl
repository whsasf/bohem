#!/usr/bin/perl
#
# Usage: sendmail-from-with-auth-login.pl <host> <port> <from> <id> <pass> [<method>]
#
# Returns 0 if MAIL FROM returned a 250 response, or the error code.
#
# Connect to <host>:<port>
# Send EHLO
# Send AUTH LOGIN
# Send password
# Send MAIL FROM:<from>
# Disconnect

require "$ENV{'_bohem_dir'}/lib/smtp.pm";
use MIME::Base64;

my $HOST=$ARGV[0];
my $PORT=$ARGV[1];
my $FROM=$ARGV[2];
my $ID=$ARGV[3];
my $PASS=$ARGV[4];
my $METHOD=$ARGV[5];

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

if ($METHOD eq "") {
	# send AUTH LOGIN

	my $b_id= MIME::Base64::encode($ID, "");
	my $b_pass= MIME::Base64::encode($PASS, "");

	$rc = $smtpSession->sendCommand ("AUTH LOGIN $b_id");
	if($rc != 1) {
	  print "Sending AUTH LOGIN failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();

	# send password

	$rc = $smtpSession->sendCommand ("$b_pass");
	if($rc != 1) {
	  print "Sending AUTH LOGIN password failed\n";
	  exit 5
	}
	$x = $smtpSession->get_response();
	if ($x =~ /^535.*/) {
	  print "SMTP AUTH failed: $x\n";
	  exit 6
	}
} elsif ($METHOD eq "PLAIN") {
	$rc = $smtpSession->sendCommand ("AUTH PLAIN");
	if($rc != 1) {
	  print "Sending AUTH PLAIN failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
	#if ($x ne "334 ?") {
		#printf "Bad prompt back from server ($x)";
		#exit 5;
	#}

	$auth_str = MIME::Base64::encode("\0$ID\0$PASS","");
	printf "AUTH=($auth_str)\n";
	$rc = $smtpSession->sendCommand($auth_str);
	if($rc != 1) {
	  print "Sending AUTH string failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
    @words = split(/ /, $x);
    if(@words[0] ne "235") {
        printf "Didn't get OK for PLAIN AUTH\n";
        exit 11
    }
} else {
	printf "Unsupported auth method: $METHOD\n";
	exit 123
}

# send MAIL FROM

$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>");
if($rc != 1) {
  printf "Sending MAIL FROM failed\n";
  exit 7
}
$x = $smtpSession->get_response();

$smtpSession->smtp_disconnect();

if ($x !~ /^([0-9]+)(.*)/) {
  print "MAIL FROM response seems malformed: $x\n";
  exit 8
}

if ($1 eq 250) {
  $ret = 0
} else {
  $ret = $1
}

print "MAIL FROM response code=$1, returning $ret\n";

exit $ret;
