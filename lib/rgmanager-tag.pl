#!/usr/bin/perl
#
# Usage: rgmanager.pl <host> <port> <password> <command>
# This scipt is used for testing valid/invalid command tag on RazorGate system port.
# Sends a command to the management port.
# Doesn't check return other than OK/ERROR
#

# Open a connection
# Read the banner
# Send login
# Read OK
# Send command
# Read lines of data and OK|ERROR

# Used to create the object and return a reference to it
# usage:
#         $myObj = mdsTelnet::new();
#
package mdsTelnet;

use Socket;
use Socket6;

$HOST=$ARGV[0];
$PORT=$ARGV[1];
$PASSWORD=$ARGV[2];
$COMMAND=$ARGV[3];
$RW=$ARGV[4];
$TAG;
sub new
{
    my $obj = 
    {
        connected =>                    0,
        verbose =>                      1, # TODO 0 
        show_response =>                0,
        check_if_connected =>           1,
        mdsResponse =>                  "",
        socket =>                       0,
        host =>                         "",
    };
    
    bless $obj, 'mdsTelnet';                    #return the reference to this object
    return $obj;
}


#Used when the object is being destroyed
#Just logs out of the MDS Telnet server if it is not already done

sub DESTROY
{
    my $obj = shift;                            #get the object reference

    logout() if ($obj->{connected} == 1);
}

#logs out of the MDS telnet server
#usage:         $myObj->logout ()

sub logout
{
    my $obj = shift;                            #get the object reference
    local (*F);

    if ($obj->{connected} == 0)                 #check that we are connected
    {
        print "Not Connected...\n";
        return 0;
    }

    $obj->{check_if_connected} = 0;
    $obj->sendCommand2("aa logout") || ((print "\nLogout failed.") && (return 0));                  #send the logout command
    $obj->{check_if_connected} = 1;
    $obj->{connected} = 0;                      #no longer connected
    *F = $obj->{socket};
    close (F) || ( (print "Can't close socket...\n") && (return 0) );   #close the socket

    return 1;
}


# logs into the MDS telnet server
# usage:         login (host, port, password, write)

sub login
{
    my ($obj, $remote, $port, $password, $write) = @_;
    my ($iaddr, $paddr, $proto, $line);
    my $ret;
    local (*S);

    # setup defaults
    #
    $remote = "localhost" if (!$remote);
    $port = 4240 if (!$port);
	$write = "write" if (!$write);
    
    $obj->{host} = "$remote:$port";             #store the name of the host that we are connected to
    
    if ($obj->{connected} == 1)                 #check if we are already connected
    {
        print "\nAlready Connected...\n";
        return 0;
    }

    #create the socket and connect to it
    #
	if ( index($remote, "[") == 0 && index($remote, "]") == (length($remote)-1) ) {
	    $remote = substr $remote, 1, -1;
    }
 	my @res = getaddrinfo($remote, $port, AF_UNSPEC, SOCK_STREAM);
	my $family = -1;
	my ($family, $socktype, $proto, $saddr, $canonname, @res) = @res;
	my ($host, $port) = getnameinfo($saddr, NI_NUMERICHOST | NI_NUMERICSERV);	
	my $proto = getprotobyname('tcp');
   	socket(S, $family, SOCK_STREAM, $proto) || ( (print "Can't Create Socket...") && (return 0) );
   	connect(S, $saddr) || ( (print "Can't Connect to Socket [$remote:$port]...") && (return 0) );
   	select(S); $| = 1; select(STDOUT);          # make sure auto flush is on for the socket

    # now login
    #
    $obj->{check_if_connected} = 0;
    $obj->{socket} = *S;

	# check if we login readonly
	if (lc($write) eq "readonly") {
		$write="";
	}
    $ret = $obj->sendCommand("aa login administrator $password");
    $obj->{check_if_connected} = 1;

    if ($ret == 0)
    {
        print "Login failed.\n";
        return $ret;
    }

    $obj->{connected} = 1;

    return $ret;
}


# sends a command to the MDS telnet server
# usage:         $myObj->sendCommand ("command...")
#

sub sendData
{
    my ($command);
    my $obj = shift;                           #get the object reference
    local (*F);

    # make sure that we are connected
    #
    if ( ($obj->{connected} == 0) && ($obj->{check_if_connected} == 1) )
    {
        print "Not Connected...\n";
        return 0;
    }

    # construct the command and send it
    #
    $command = "$_[0]\n";
    *F = $obj->{socket};
    print F $command;
    $obj->showmsg("\nSending data (to $obj->{host}): $command");
	return 1;

}

sub sendCommand
{
    my ($ret, $command);
    my $obj = shift;                           #get the object reference
    local (*F);

    # make sure that we are connected
    #
    if ( ($obj->{connected} == 0) && ($obj->{check_if_connected} == 1) )
    {
        print "Not Connected...\n";
        return 0;
    }

    # construct the command and send it
    #
	$command = "$_[0]\n";
	print "$command\n";
    my $ind = index($command, ' ');
    $TAG = substr $command, 0, $ind;
    *F = $obj->{socket};
    print F $command;
    $obj->showmsg("\nSending (to $obj->{host}): $command");
	# get and check the response
    #
    $ret = $obj->get_response();
    $obj->{mdsResponse} = $ret;                #store the response

    if (($ret =~ /.*\n$TAG OK/) || ($ret =~ /^$TAG OK/))
    {
        $obj->showResponse("Command (\"$_[0]\") to \"$obj->{host}\" completed successfully.\n");
        return 1;
    }
	elsif (($ret =~ /.*\n$TAG NO/) || ($ret =~ /^$TAG NO/) || ($ret =~/NO/) || ($ret =~ /.*\nNO/))
	{
		$obj->showResponse("Command (\"$_[0]\") to \"$obj->{host}\" failed: \n");
		print "$ret";
		return 0;
	}
    else
    {
        if ($ret =~ /^\+.*/)
        {
            $obj->showResponse("Command (\"$_[0]\") to \"$obj->{host}\" half-completed successfully. -- Reading from stdin\n");
            return 2;
        }
        else 
        {
            $obj->showResponse("Command (\"$_[0]\") to \"$obj->{host}\" failed: \n");
			print "$ret";
            return 0;
        }
    }
    return 0;
}

sub sendCommand2
{
    my ($ret, $command);
    my $obj = shift;                           #get the object reference
    local (*F);

    # make sure that we are connected
    #
    if ( ($obj->{connected} == 0) && ($obj->{check_if_connected} == 1) )
    {
        print "Not Connected...\n";
        return 0;
    }

    # construct the command and send it
    #
    $command = "$_[0]\n";
    *F = $obj->{socket};
    print F $command;
    $obj->showmsg("\nSending (to $obj->{host}): $command");

    # get and check the response
    #
    $ret = $obj->get_response();
    $obj->{mdsResponse} = $ret;                #store the response

    return 1;
}


#receives a response from the MDS Telnet server
#usage:         $myObj->get_response()

sub get_response
{
    my $obj = shift;                                            #get the object reference
    my ($line, $buffer);
    local (*F);

    $buffer = "";
    *F = $obj->{socket};

    while ($line = <F>)                                         #read from the socket
    {
        $buffer = "$buffer$line";
        $obj->showmsg("Received: $line");
        print ("$line") if ($line =~ /^\* /);
        last if ( ($line =~ /^$TAG OK.*/) || ($line =~ /^$TAG NO.*/) || ($line =~ /^* NO Invalid tag/) || ($line =~ /^\+ */) );
    }
    return $buffer;
}


#returns the last response from MDS telnet server
#usage:         $myObj->Response()

sub Response
{
    my $obj = shift;                                            #get the object reference

    return $obj->{mdsResponse};                                 #return the last stored response
}


#sets verbose reporting level
#usage:         $myObj->setVerbose("on"|"off")

sub setVerbose
{
    my $obj = shift;                                            #get the object reference

    ($_[0] =~ /on/i) ? ($obj->{verbose} = 1) : ($obj->{verbose} = 0);
    return 1;
}

#sets normal reporting level
#usage:         $myObj->setResponse("on"|"off")

sub setResponse
{
    my $obj = shift;                                            #get the object reference

    ($_[0] =~ /on/i) ? ($obj->{show_response} = 1) : ($obj->{show_response} = 0);

    return 1;
}


#prints a verbose message to the screen
#usage:         $myObj->showmsg("message...")

sub showmsg
{
    my $obj = shift;                                            #get the object reference

    print ("$_[0]") if ($obj->{verbose} == 1);
}


#prints a normal message to the screen
#usage:         $myObj->showResponse("message...")

sub showResponse
{
    my $obj = shift;                                            #get the object reference

    print ("$_[0]") if ($obj->{show_response} == 1);
}


my($mdsSession,$telnetResult);

$mdsSession = mdsTelnet::new();
if($mdsSession == 0) {
	print "Telnet failed\n";
	exit 2;
}
$mdsSession->setVerbose ("ON");

$rc = $mdsSession->login ($HOST, $PORT, "$PASSWORD", "$RW");

if($rc != 1) {
	print "Login failed\n";
	exit 2
}
$rc = $mdsSession->sendCommand ($COMMAND);

if($rc != 1 && $rc != 2) {
	print "Got an ERROR response 1243\n";
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
		printf "Got an ERROR response 2341";
		exit 8
	}
} else {
	$x = $mdsSession->Response();
}
#printf "About to logout\n";
$rc = $mdsSession->logout();

exit 0;
