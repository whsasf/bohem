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

package smtp;

use Socket;
use Socket6;

$HOST=$ARGV[0];
$PORT=$ARGV[1];

# Used to create the object and return a reference to it
# usage:
#         $myObj = smtp::new();
#

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
    
    bless $obj, 'smtp';                    #return the reference to this object
    return $obj;
}


#Used when the object is being destroyed
#Just logs out of the MDS Telnet server if it is not already done

sub DESTROY
{
    my $obj = shift;                            #get the object reference

    smtp_disconnect() if ($obj->{connected} == 1);
}

#logs out of the MDS telnet server
#usage:         $myObj->logout ()

sub smtp_disconnect
{
    my $obj = shift;                            #get the object reference
    local (*F);

    *F = $obj->{socket};
    close (F) || ( (print "Can't close socket...\n") && (return 0) );   #close the socket

    return 1;
}


# logs into the MDS telnet server
# usage:         login (host, port, password, "write")

sub smtp_connect
{
    my ($obj, $remote, $port, $password, $write) = @_;
    my ($iaddr, $paddr, $proto, $line);
    my $ret;
    local (*S);

    # setup defaults
    #
    $remote = "localhost" if (!$remote);
    $port = 25 if (!$port);

    $obj->{host} = "$remote:$port";             #store the name of the host that we are connected to
    
    if ($obj->{connected} == 1)                 #check if we are already connected
    {
        print "Already Connected...\n";
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

    $obj->{check_if_connected} = 0;
    $obj->{socket} = *S;

    $obj->{connected} = 1;

    return 1;
}


sub sendData
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
    $command = "$_[0]\r\n";
    *F = $obj->{socket};
    print F $command;
    $obj->showmsg("Sending data (to $obj->{host}): $command");
	$obj->get_multiline_response();
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

    if (defined($line = <F>)) {                                         #read from the socket
        $obj->showmsg("Received: $line");
    } else {
        printf "ERROR on read\n";
        exit 12;
    }
    return $line;
}


#receives a multi-line response from the server
#usage:         $myObj->get_multiline_response()

sub get_multiline_response
{
    my $obj = shift;                                            #get the object reference
    my ($line, $buffer);
    local (*F);

    $buffer = "";
    *F = $obj->{socket};

    while (1)
    {
        if (defined($line = <F>))
        {
            $buffer = "$buffer$line";
            $obj->showmsg("Received: $line");
            last if ( ($line !~ /^\d\d\d-.*/) );
        } else {
            print "ERROR on read\n";
            exit 12
        }
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


#prints a verbose message to the screen
#usage:         $myObj->showmsg("message...")

sub showmsg
{
    my $obj = shift;                                            #get the object reference

    print ("$_[0]") if ($obj->{verbose} == 1);
}


my($smtpSession,$telnetResult);

$smtpSession = smtp::new();
if($smtpSession == 0) {
	print "Telnet failed";
	exit 1;
}
$smtpSession->setVerbose ("ON");
$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	printf "Connect failed\n";
	exit 2
}

$smtpSession->get_multiline_response();

open(FH,"-");
while (defined($line = <FH>)) {
	chomp $line;
	$rc = $smtpSession->sendData ("$line");
	if($rc != 1) {
		printf "error sending data\n";
		exit 7;
	}
}


exit 0;
