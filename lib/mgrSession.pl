#!/usr/bin/perl
#
# Usage: mgrSession.pl <host> <port> <password> <list-of-commands-and-expected-responses>
#
# Sends multiple commands to the management port
# and verifies each response
#
# Commands and expected responses are given in one string, separated by a semi-colon character.
# expected responses start with one of the following operator:
#  =   smart match,          eg: =ERROR
#  ==  exact match,          eg: ==OK
#
# Usage Sample:
#  MgrSession "USER $domain ADD $user; =OK; USER $domain ADD $user; =ERROR"
#

require "$ENV{'_bohem_dir'}/lib/mdsTelnet.pm";

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$PASS=$ARGV[2];
$CMDS=$ARGV[3];
$RW="";

my($mdsSession);
my(@cmds, $cmd, $res);
my $isGet = 0;
my $sep= ";";

if (substr($CMDS, 0, 1) eq $sep)
{
	$sep=substr($CMDS, 1, 1);
	$CMDS=substr($CMDS, 2);
}

# -----------------------------------------------------------------------------

# match_exact
#  return true if the 1st parameter is equal to the 2nd parameter

sub match_exact
{
	my $res = shift;
	my $exp = shift;
	
	if ($res ne $exp)
	{
		print "Exact Match Failed\n";
		print " Expected: ".$exp."\n";
		print " But Got : ".$res."\n";
		return 0;
	}
	
	print "Exact Match Succeeded\n";
	return 1;
}

# match_starts_with
#  return true if the begining of the 1st parameter is equal to the 2nd parameter

sub match_starts_with
{
	my $res = shift;
	my $exp = shift;
	
	if (substr($res, 0, length($exp)) ne $exp)
	{
		print "Starts-With Match Failed\n";
		print " Expected: ".$exp."\n";
		print " But Got : ".$res."\n";
		return 0;
	}
	
	print "Starts-With Match Succeeded\n";
	return 1;
}

# match_ends_with
#  return true if the end of the 1st parameter is equal to the 2nd parameter

sub match_ends_with
{
	my $res = shift;
	my $exp = shift;
	
	if (substr($res, -length($exp)) ne $exp)
	{
		print "Ends-With Match Failed\n";
		print " Expected: ".$exp."\n";
		print " But Got : ".$res."\n";
		return 0;
	}
	
	print "Ends-With Match Succeeded\n";
	return 1;
}

# match_variable
#  parse a GET response, extract and compare the value part only

sub match_variable
{
	print "Variable Match Not Implemented\n";
	return 0;
}

# match_smart
#  if last command was a GET, try a match_variable, otherwise or
#  on failure, try a match_starts_with
#  on failure, try a match_ends_with

sub match_smart
{
	my $res = shift;
	my $exp = shift;
	
	if ($isGet and match_variable($res, $exp))
	{
		return 1;
	}
	if (match_starts_with($res, $exp))
	{
		return 1;
	}
	if (match_ends_with($res, $exp))
	{
		return 1;
	}
	
	return 0;
}

# -----------------------------------------------------------------------------

$mdsSession = mdsTelnet::new();
if($mdsSession == 0)
{
	print "Failed to Start Telnet session\n";
	exit 2;
}

$mdsSession->setVerbose("OFF");

$rc = $mdsSession->login($HOST, $PORT, $PASS, $RW);
if($rc != 1)
{
	print "Failed to Login: host[$HOST] port[$PORT] pass[$PASS] write[$RW]\n";
	exit 2
}

@cmds = split(/$sep/, $CMDS);

# --- look at every command/response in the commands array

for $cmd (@cmds)
{
	$cmd =~ s/^\s+//;	# trim leading blanks
	$cmd =~ s/\s+$//;	# trim trailing blanks
	
	if (substr($cmd, 0, 1) eq "=")
	{
		$res = $mdsSession->Response();
		chop($res);
		chop($res);
		print "RES: $res\n";
		
		if (substr($cmd, 0, 2) eq "==")
		{
			match_exact($res, substr($cmd, 2)) or exit 1;
		}
		elsif (substr($cmd, 0, 1) eq "=")
		{
			match_smart($res, substr($cmd, 1)) or exit 1;
		}
		else
		{
			print("Invalid command format: $cmd");
		}
	}
	else
	{
		$isGet = 0;
		$isGet = 1 if (uc(substr($cmd, 0, 4)) eq "GET ");
		
		print "CMD: $cmd\n";
		$rc = $mdsSession->sendCommand2($cmd);
		if($rc != 1)
		{
			print "Failed to Send Command: $cmd\n";
			exit 2;
		}
	}
}

$rc = $mdsSession->logout();
if($rc != 1)
{
	print "Failed to Logout\n";
	exit 2;
}

exit 0;
