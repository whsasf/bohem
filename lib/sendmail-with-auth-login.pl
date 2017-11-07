#!/usr/bin/perl
#
# Usage: sendmail-with-auth-login.pl <host> <id> <pass> <port> <from> [<another-to>] .......
#
# Connect to <host>:<port>
# Send EHLO
# Send AUTH PLAIN
# Send <base64-encoded \0id\0pass>
# Send MAIL FROM:<from>
# Send RCPT TO:<to>
# etc...
# Send DATA
# Send <whatever comes in on stdin>
# Send .
# Send QUIT

package smtp;

use Getopt::Long;
use Socket;
use Socket6;
use MIME::Base64;

GetOptions("deliverby=s" => \$DELIVER_BY,
           "xclp=s" => \$XCLP,
           "localip=s" => \$LOCALIP,
           "size=s" => \$SIZE);

my $HOST=$ARGV[0];
my $PORT=$ARGV[1];
my $ID=$ARGV[2];
my $PASS=$ARGV[3];
my $FROM=$ARGV[4];
my $TO=$ARGV[5];

my $smtpSession;


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

    print "Disconnect socket\n";

    if ($obj->{connected} == 0)                 #check that we are connected
    {
        print "Disconnect: Not Connected...\n";
        return 0;
    }

    $obj->{check_if_connected} = 0;
    $obj->sendCommand("quit") || ((print "\nLogout failed.") && (return 0));                  #send the logout command
    $obj->{check_if_connected} = 1;
    $obj->{connected} = 0;                      #no longer connected
    *F = $obj->{socket};
    close (F) || ( (print "Can't close socket...\n") && (return 0) );   #close the socket

    return 1;
}


sub smtp_close
{
    my $obj = shift;                            #get the object reference
    local (*F);

    print "Close socket\n";

    if ($obj->{connected} == 0)                 #check that we are connected
    {
        print "Close: Not Connected...\n";
        return 0;
    }

    $obj->{check_if_connected} = 1;
    $obj->{connected} = 0;                      #no longer connected
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
    $port = 4240 if (!$port);

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
    if (index($LOCALIP, ":") != -1)
    {
        bind(S, pack_sockaddr_in6(0, inet_pton(AF_INET6, $LOCALIP)));
    }
    elsif ($LOCALIP ne "")
    {
        bind(S, pack_sockaddr_in(0, inet_aton($LOCALIP)));
    }
    connect(S, $saddr) || ( (print "Can't Connect to Socket [$remote:$port]...") && (return 0) );
    select(S); $| = 1; select(STDOUT);          # make sure auto flush is on for the socket

    $obj->{check_if_connected} = 0;
    $obj->{socket} = *S;

    $obj->{connected} = 1;

    return 1;
}


# sends a command to the MDS telnet server
# usage:         $myObj->sendCommand ("command...")
#

sub sendCommand
{
    my ($ret, $command);
    my $obj = shift;                           #get the object reference
    local (*F);

    # make sure that we are connected
    #
    if ( ($obj->{connected} == 0) && ($obj->{check_if_connected} == 1) )
    {
        print "Send: Not Connected...\n";
        return 0;
    }

    # construct the command and send it
    #
    $command = "$_[0]\n";
    *F = $obj->{socket};
    print F $command;
    $obj->showmsg("Sending (to $obj->{host}): $command");
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

    $line = <F>;                                         #read from the socket
    $obj->showmsg("Received: $line");

    if  ( $line eq "" )
    {
        $obj->smtp_close()
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

    while ($line = <F>)                                         #read from the socket
    {
        $buffer = "$buffer$line";
        $obj->showmsg("Received: $line");
        last if ( ($line !~ /^\d\d\d-.*/) );
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

1;

print "Establish SMTP session using ID='$ID'\n";

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

$domain = substr $FROM, index($FROM, '@')+1;
if ($domain eq "") {
    $domain="localhost";
}
$rc = $smtpSession->sendCommand ("EHLO $domain");
if($rc != 1) {
  print "Got an ERROR response from EHLO\n";
  exit 3
}
$x = $smtpSession->get_multiline_response();

if ($XCLP ne "") {
    $rc = $smtpSession->sendCommand ("XCLP $XCLP");
    if($rc != 1) {
        printf "Got an ERROR response for XCLP\n";
        exit 3
    }
    $x = $smtpSession->get_response();
}

# always use PLAIN
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

# send MAIL FROM

$extra = "";

if ($DELIVER_BY ne "") {
	$extra = $extra . " BY=$DELIVER_BY";
}

if ($SIZE ne "") {
	$extra = $extra . " SIZE=$SIZE";
}

$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>$extra");
if($rc != 1) {
  printf "Sending MAIL FROM failed\n";
  exit 7
}
$x = $smtpSession->get_response();
$arg=5;
while($TO ne "") {
	$rc = $smtpSession->sendCommand ("RCPT TO:<$TO>");
	if($rc != 1) {
		print "Got an ERROR response";
		exit 5
	}
	$x = $smtpSession->get_response();
	$arg = $arg + 1;
	$TO=$ARGV[$arg];
}
$rc = $smtpSession->sendCommand ("DATA");
if($rc != 1) {
	print "Got an ERROR response";
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
		print "error sending data\n";
		exit 7;
	}
}

$rc = $smtpSession->sendCommand (".");
if($rc != 1) {
	print "Got an ERROR response";
	exit 8
}
$x = $smtpSession->get_response();

$rc = $smtpSession->smtp_disconnect();

exit 0;
