#!/usr/bin/perl
#
# Usage: imapmail.pl <host> <port> <user> <pass> <folder> [<message>]
# 		Mail data is output to stdout.
#
# Fetch the specified message (or the OLDEST <---- Which is a bug)
#

require "$ENV{'_bohem_dir'}/lib/imap.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$USER=$ARGV[2];
$PASS=$ARGV[3];
$FOLDER=$ARGV[4];
$MSG=$ARGV[5];

my($session,$telnetResult);

print "imapmail: host[$HOST] port[$PORT] user[$USER] pass[$PASS] folder[$FOLDER] message[$MSG]\n";

$session = imap::new();
if($session == 0) {
	printf "Telnet failed\n";
	exit 1;
}
$session->setVerbose ("OFF");
$rc = $session->imap_connect ($HOST, $PORT);
if($rc != 1) {
	printf "Login failed\n";
	exit 2
}
$x = $session->get_response();
@words = split(/ /, $x);
if(@words[1] ne "OK") {
	printf "Didn't get OK for greeting\n";
	exit 10
}

$rc = $session->sendCommand ("xx LOGIN $USER $PASS");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 3
}
$x = $session->get_imap_response("xx");
if ($x !~ /.*(\n|^)xx OK.*/) {
	printf "Didn't get OK for LOGIN\n";
	exit 12
}

$rc = $session->sendCommand ("xx SELECT $FOLDER");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 3
}

$x = $session->get_imap_response("xx");
if ($x !~ /.*(\n|^)xx OK.*/) {
	printf "Didn't get OK for SELECT\n";
	exit 12
}

## BUG -- Should check if there are any messages
$NUMBER = 1; ## BUG - Should default to the newest, not oldest
$NUMBER = "$MSG" if ($MSG);

$rc = $session->sendCommand ("xx FETCH $NUMBER BODY[]");
$x = $session->get_imap_response("xx");
if ($x !~ /.*(\n|^)xx OK.*/) {
	printf "Didn't get OK for FETCH\n";
	exit 16
}

$rc = $session->sendCommand ("xx LOGOUT");
if($rc != 1) {
	printf "Got an ERROR response\n";
	exit 6
}
$x = $session->get_imap_response("xx");
if ($x !~ /.*(\n|^)xx OK.*/) {
	printf "Didn't get OK for LOGOUT\n";
	exit 15
}


$rc = $session->imap_disconnect();

exit 0;
