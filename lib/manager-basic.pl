#!/usr/bin/env perl

# $Header: /home/kbreslin/cvs/bohem/lib/manager-basic.pl,v 1.1 2009-05-26 14:39:26 kbreslin Exp $
# This file borrowed from CVSROOT:qa/tools/suites/CPMS/perl/manager.pl

#
# Usage: manager.pl <host> <port> <password> <command>
#
# Sends a command to the management port.
# Doesn't check return other than OK/ERROR
#

# Open a connection
# Read the banner
# Send login
# Read OK
# Send command
# Read lines of data and OK|ERROR

require "$ENV{'_bohem_dir'}/lib/mdsTelnetBasic.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$COMMAND=$ARGV[2];

my($mdsSession,$telnetResult);

$mdsSession = mdsTelnetBasic::new();
if($mdsSession == 0) {
	print "Telnet failed\n";
	exit 2;
}
$mdsSession->setVerbose ("OFF");

$rc = $mdsSession->login ($HOST, $PORT);

if($rc != 1) {
	print "Login failed\n";
	exit 2
}
$rc = $mdsSession->sendCommand ($COMMAND);
if($rc != 1 && $rc != 2) {
	print "Got an ERROR response.\n";
	$mdsSession->logout();
	exit 1
}
if($rc == 2) {
	printf "Need to send data for this command..\n";
	open(FH,"-");
	while (defined($line = <FH>)) {
		chomp $line;
		$rc = $mdsSession->sendData ("$line");
		if($rc != 1) {
			printf "error sending data\n";
			exit 7;
		}
	}
	$rc = $mdsSession->sendCommand (".");
	if($rc != 1) {
		printf "Got an ERROR response.";
		exit 8
	}
} else {
	$x = $mdsSession->Response();
}

$rc = $mdsSession->logout();

exit 0;
