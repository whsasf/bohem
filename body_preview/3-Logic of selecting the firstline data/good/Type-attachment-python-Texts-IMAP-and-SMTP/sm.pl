#!/usr/bin/perl
eval 'exec perl -w -S $0 ${1+"$@"}' # -*- perl -*-
    if 0;

##############################################################################

=head1 NAME

sm.pl - send messages, optionally make them older

=head1 SYNOPSIS

sm.pl [options ...] [filenames ...]

=head1 DESCRIPTION

sm.pl delivers one or messages to a recipient via IMAP or SMTP.
After delivery, it may modify the arrival-time and/or access time of
the message, thereby aging it.

=head1 OPTIONS

=over 4

=item -h, -help

Print usage message and exit.

=item -F B<sender>, -from B<sender>

Sender address used in SMTP "mail from" command.
Ignored if -folder option is given.
Default: <user@host>,
where user is caller's user name
and host is the current host name.

=item -u B<arg>, -user B<arg>

Recipient user name.  Default: tmpusr7001

=item -u2 B<arg>, -user2 B<arg>

Second SMTP recipient user name.  Default: none

=item -u3 B<arg>, -user3 B<arg>

Third SMTP recipient user name.  Default: none

=item -p B<arg>, -pass B<arg>

IMAP password.  Default: value of -user argument (+ "_pw" if user prefix is "tmpusr").

=item -f B<path>, -folder B<path>

Destination folder.  Default: "inbox".
Forces use of IMAP to deliver message instead of SMTP.

=item -k B<keywords>, -keys B<keywords>

IMAP message flags and keywords.  Default: none.
Forces use of IMAP to deliver message instead of SMTP.

=item -H B<header>, -header B<header>

Header line, added before first line of each input file.
Spaces between the header name and header value may be omitted,
to avoid the need for quoting the argument (see example below).
Argument may be used multiple times.

=item -c B<count>, -count B<count>

Number of times to send each message.

=item -s B<size>, -size B<size>

Maximum message size.  Messages larger than B<size> will be truncated.
B<size> is normally expressed in bytes, but may be followed by a
suffix to indicate a different unit of measurement.
Available suffixes are:

  B  bytes (default)
  K  kilobytes, i.e. 1024 bytes
  M  megabytes, i.e. 1024 kilobytes
  L  lines

The maximum size is kind of loose for two reasons.
First,
sm.pl will not truncate the message headers
or break within message lines.
Second,
the MTA will add Return-Path, Received, and Message-ID headers,
thereby extending the message size.

=item -as B<num>, -ageSecs B<num>

=item -am B<num>, -ageMins B<num>

=item -ah B<num>, -ageHours B<num>

=item -ad B<num>, -ageDays  B<num>

=item -aw B<num>, -ageWeeks B<num>

Amount by which messages should have their arrival-time decreased.
Default for all: 0.

=item -rs B<num>, -retrSecs B<num>

=item -rm B<num>, -retrMins B<num>

=item -rh B<num>, -retrHours B<num>

=item -rd B<num>, -retrDays  B<num>

=item -rw B<num>, -retrWeeks B<num>

Amount by which messages should have their last-access-time decreased.
Default for all: 0.

=item -fs B<num>, -firstSecs B<num>

=item -fm B<num>, -firstMins B<num>

=item -fh B<num>, -firstHours B<num>

=item -fd B<num>, -firstDays  B<num>

=item -fw B<num>, -firstWeeks B<num>

Amount by which messages should have their first-access-time decreased.
Default for all: 0.

=item -es B<num>, -expirSecs B<num>

=item -em B<num>, -expirMins B<num>

=item -eh B<num>, -expirHours B<num>

=item -ed B<num>, -expirDays  B<num>

=item -ew B<num>, -expirWeeks B<num>

Time after which message should expire.
Uses first value of configuration key /<host>/mta/msgExpirationHeader.
Default for all: 0.

=item -O, -oracle

Tell program that to use direct SQL to age messages,
rather than config keys, which can be slow.
This will only work if
(1) the MSS backend uses the new IOT Oracle schema; and
(2) no other process delivers a new message while
this program is running.

=item -aa

Tell program to use the anti-abuse MTA (aamta) instead of the
normal MTA when delivering messages via SMTP.

=item -d, -debug

Display conversations with IMAP or SMTP server and sqlplus.

=item -x

Exit on warning, not just on error.

=back

=head1 EXAMPLES

To send a message via IMAP to user tmpusr7001,
password tmpusr7001_pw, deposit the message in the folder voice,
age it by 10 days, and set last access time to 5 hours ago,
use the following command:

  % sm.pl -user tmpusr7001 -folder voice \
    -ageDays 10 -retrHours 5 msg.txt

Here is the same example using short forms of the arguments:

  % sm.pl -u tmpusr7001 -f voice -ad 10 -rh 5 msg.txt

To send a message via IMAP to the inbox of tmpusr7001
and set the user-defined message flags "foo" and "bar",
and the system flag \seen, use the following command:

  % sm.pl -u tmpusr7001 -k foo,bar,seen msg.txt

The program recognizes system flags (\answered, \deleted,
\draft, \flagged, \recent, and \seen) and ensures that they
have \ prefixes, and that user-defined flags do not.

Use the -H option to add type and priority headers.
The space between the colon at the end of the header name
and the beginning of the header value may be omitted
so that simple header values need not be quoted to the shell.

  % sm.pl -u tmpusr7001 -H X-Type:mail -H X-Prio:normal msg.txt

To send a message of a particular size, use the -s option.
For example, to send a 50 kilobyte message, use the following command:

  % sm.pl -u tmpusr7001 -s 50k really-big-message-file

To test expiration headers, use the -expirXXX options.  For example,
to expire a message in one year plus one minute, use the following
command:

  % sm.pl -u tmpusr7001 -ed 365 -em 1 msg.txt

=head1 ENVIRONMENT

sm.pl requires that the following environment variables be set:

=over 4

=item INTERMAIL

Home directory for InterMail, used to locate the imconfget executable.

=back

=head1 COPYRIGHT

Copyright 2002-2004 Openwave Systems, Inc. All Rights Reserved.

The copyright to the computer software herein is the property of Openwave
Systems, Inc.  The software may be used and/or copied only with the written
permission of Openwave Systems, Inc. or in accordance with the terms and
conditions stipulated in the agreement/contract under which the software has
been supplied.

=cut

##############################################################################

use FileHandle;
use Getopt::Long;
use IPC::Open2;
use Socket;

use strict;

############################################################
#
# Process command line.

# Get program name (file part).
(my $prog = $0) =~ s/.*\///;

# Set version information.
my $vers = "$prog 1.1 25 Feb 2002";

my $debugging;
my $sender = '<' . $ENV{USER} . '@' . strip(`hostname`) . '>';
my $user;
my $user2;
my $user3;
my $pass;
my $folder;
my $flags;
my @headers;
my $count        = 1;
my $msgsize;
my $ageSeconds   = 0;
my $ageMinutes   = 0;
my $ageHours     = 0;
my $ageDays      = 0;
my $ageWeeks     = 0;
my $retrSeconds  = 0;
my $retrMinutes  = 0;
my $retrHours    = 0;
my $retrDays     = 0;
my $retrWeeks    = 0;
my $firstSeconds = 0;
my $firstMinutes = 0;
my $firstHours   = 0;
my $firstDays    = 0;
my $firstWeeks   = 0;
my $expirSeconds = 0;
my $expirMinutes = 0;
my $expirHours   = 0;
my $expirDays    = 0;
my $expirWeeks   = 0;
my $usingOracle;
my $exitOnWarning;
my $mtaName = 'mta';

# Process ARGV.
Getopt::Long::config('no_ignore_case');
&GetOptions(
  '-h|help'           => sub { system("perldoc -t $prog | cat"); exit 0; },
  '-v|version'        => sub { print "$prog 1.1 25 Feb 2002\n"; exit 0; },
  '-d|debug'          => \$debugging,
  '-x'                => \$exitOnWarning,
  '-F|from=s'         => \$sender,
  '-u|user=s'         => \$user,
  '-u2|user2=s'       => \$user2,
  '-u3|user3=s'       => \$user3,
  '-p|pass=s'         => \$pass,
  '-f|folder=s'       => \$folder,
  '-k|keys=s'         => \$flags,
  '-H|header=s'       => \@headers,
  '-c|count=n'        => \$count,
  '-s|size=s'         => \$msgsize,
  '-as|ageSecs=n'     => \$ageSeconds,
  '-am|ageMins=n'     => \$ageMinutes,
  '-ah|ageHours=n'    => \$ageHours,
  '-ad|ageDays=n'     => \$ageDays,
  '-aw|ageWeeks=n'    => \$ageWeeks,
  '-rs|retrSecs=n'    => \$retrSeconds,
  '-rm|retrMins=n'    => \$retrMinutes,
  '-rh|retrHours=n'   => \$retrHours,
  '-rd|retrDays=n'    => \$retrDays,
  '-rw|retrWeeks=n'   => \$retrWeeks,
  '-fs|firstSecs=n'   => \$firstSeconds,
  '-fm|firstMins=n'   => \$firstMinutes,
  '-fh|firstHours=n'  => \$firstHours,
  '-fd|firstDays=n'   => \$firstDays,
  '-fw|firstWeeks=n'  => \$firstWeeks,
  '-es|expirSecs=n'   => \$expirSeconds,
  '-em|expirMins=n'   => \$expirMinutes,
  '-eh|expirHours=n'  => \$expirHours,
  '-ed|expirDays=n'   => \$expirDays,
  '-ew|expirWeeks=n'  => \$expirWeeks,
  '-O|oracle'         => \$usingOracle,
  '-aa'               => sub { $mtaName = 'aamta'; },
) || die "See \"$prog -help\" for more information.\n";

# Check -size argument.
my $maxLines = 0;
my $maxBytes = 0;
if ($msgsize) {
    if ($msgsize !~ /^\d+[BbKkMmLl]?$/) {
	print STDERR "Invalid -size value: $msgsize\n";
	die "See \"$prog -help\" for more information.\n";
    }
    $msgsize =~ s/^(\d+)(.)?$/$1$2/;
    my $size = $1;
    my $unit = lc $2 || 'b';
    if ($unit eq 'b') {
	$maxBytes = $size;
    }
    elsif ($unit eq 'k') {
	$maxBytes = $size * 1024;
    }
    elsif ($unit eq 'm') {
	$maxBytes = $size * 1024 * 1024;
    }
    elsif ($unit eq 'l') {
	$maxLines = $size;
    }
}

# Use Oracle if possible.
if (!$usingOracle && getConfig('mss', 'databaseType', 'unknown') eq 'Oracle') {
    $usingOracle = 1;
}

# Use SMTP unless -folder or -keys has been specified.
my $usesmtp;
if (!$folder && !$flags) {
    $usesmtp = 1;
}

# Determine host and port.
my $host = strip(`hostname`);
my $port = ($usesmtp)
		? getConfig($mtaName, 'SMTPPort')
		: getConfig('imapserv', 'imap4Port');

# Check for uninitialized options.
if (!$user)   { $user = 'tmpusr7001'; }
if (!$pass)   { $pass = $user; $pass = $pass . "_pw" if ($pass =~ /^tmpusr/); }
if (!$folder) { $folder = "inbox"; }

# Convert ageXXX into seconds, days.
my $ageSecs  = 0;
   $ageSecs += $ageSeconds;
   $ageSecs += $ageMinutes * 60;
   $ageSecs += $ageHours * 3600;
   $ageSecs += $ageDays  * 3600 * 24;
   $ageSecs += $ageWeeks * 3600 * 24 * 7;
   $ageDays  = $ageSecs / (3600 * 24 * 1.0);

# Convert retrXXX into seconds, days.
my $retrSecs  = 0;
   $retrSecs += $retrSeconds;
   $retrSecs += $retrMinutes * 60;
   $retrSecs += $retrHours * 3600;
   $retrSecs += $retrDays  * 3600 * 24;
   $retrSecs += $retrWeeks * 3600 * 24 * 7;
   $retrDays  = $retrSecs / (3600 * 24 * 1.0);

# Convert firstXXX into seconds, days.
my $firstSecs  = 0;
   $firstSecs += $firstSeconds;
   $firstSecs += $firstMinutes * 60;
   $firstSecs += $firstHours * 3600;
   $firstSecs += $firstDays  * 3600 * 24;
   $firstSecs += $firstWeeks * 3600 * 24 * 7;
   $firstDays  = $firstSecs / (3600 * 24 * 1.0);

# Convert expirXXX into seconds.
my $expirSecs  = 0;
   $expirSecs += $expirSeconds;
   $expirSecs += $expirMinutes * 60;
   $expirSecs += $expirHours * 3600;
   $expirSecs += $expirDays  * 3600 * 24;
   $expirSecs += $expirWeeks * 3600 * 24 * 7;

# Create expiration header.
my $expirHdr;
if ($expirSecs != 0) {
    my $head = getConfig('mta', 'msgExpirationHeader');
    unless ($head) {
	error("Cannot expire message(s).\nConfig key \"msgExpirationHeader\" is not set");
    }
    my @when = gmtime(time() + $expirSecs);
    my $when = sprintf('%02d/%02d/%02d %02d:%02d:%02d GMT',
		$when[4]+1,
		$when[3],
		$when[5]+1900,
		$when[2],
		$when[1],
		$when[0]);
    $expirHdr = $head . ': ' . $when . "\n";
}

# Fixup keywords -- make sure system flags
# have \ in front, others do not.
if ($flags) {
    $flags =~ s/^\(|\)$//g;
    my @flagarray = split(/[\s,]+/, $flags);
    foreach (@flagarray) {
	$_ =~ s/^\\+//;
	$_ =~ s/^(answered|deleted|draft|flagged|recent|seen)$/\\$1/i;
    }
    $flags = '(' . join(' ', @flagarray) . ')';
}

############################################################
#
# Process remaining arguments, or stdin.

my $oldTestAccount;
my $oldAgeSeconds;
my $oldRetrSeconds;
my $oldFirstSeconds;

unless ($ageSecs <= 0 && $retrSecs <= 0 && $firstSecs <= 0) {
    if ($usingOracle) {
	InitOracle();
    } else {
	$oldTestAccount  = getConfig('mss', 'testAccount');
	$oldAgeSeconds   = getConfig('mss', 'testQuotaAgeSeconds');
	$oldRetrSeconds  = getConfig('mss', 'testQuotaRetrSeconds');
	$oldFirstSeconds = getConfig('mss', 'testQuotaFirstReadSeconds');

	my $address = $user;
	if ($address !~ /@/) {
	    my $domain = getConfig($mtaName, 'defaultDomain');
	    $address = $user . '@' . $domain;
	}
	my $mailbox = getMailbox($address);

	setConfig('mss', 'testAccount', $mailbox);
	setConfig('mss', 'testAccountEnabled', 'true');
	if (defined($ageSecs) && $ageSecs > 0) {
	    setConfig('mss', 'testQuotaAgeSeconds', $ageSecs);
	}
	if (defined($retrSecs) && $retrSecs > 0) {
	    setConfig('mss', 'testQuotaRetrSeconds', $retrSecs);
	}
	if (defined($firstSecs) && $firstSecs > 0) {
	    setConfig('mss', 'testQuotaFirstReadSeconds', $firstSecs);
	}
    }
}

my $filename;
my $mbox;

FILE:
while (@ARGV > 0) {
    $filename = shift(@ARGV);
    if (-d $filename) {
	warn("'$filename' is a directory.  Skipping...");
    	next FILE;
    }
    if (-B $filename) {
	warn("'$filename' is a binary file.  Skipping...");
    	next FILE;
    }
    for (my $i = 0; $i < $count; ++$i) {
	if (!open(IN, $filename)) {
	    error("cannot open file '$filename'.");
	}
	$mbox = process($filename, \*IN);
	close(IN);
    }
}
if (!$filename) {
    $mbox = process("<stdin>", \*STDIN);
}

unless ($ageSecs <= 0 && $retrSecs <= 0 && $firstSecs <= 0) {
    if ($usingOracle) {
	# Try to flush message store to make sure that MSS sees updated
	# values.

	if (-e "$ENV{INTERMAIL}/bin/immssinvlist") {
	    # NOTE: immsscall flush command enhancement came with addition
	    # of immssinvlist command; therefore if immssinvlist exists,
	    # then immsscall flush command will probably work.

	    system("immsscall $host flush $mbox");
	} elsif (-e "$ENV{INTERMAIL}/bin/immssdescms") {
	    # NOTE: if we wait long enough, the destination mailbox will
	    # be flushed when the next mailbox operation occurs on another
	    # mailbox.  The only other mailbox we can be sure exists is
	    # the admin mailbox.

	    my $idleFlush = getConfig('mss', 'idleFlushTimeoutSecs', 10);
	    my $admin = getConfig('mss', 'adminMessageStoreName', 'admin');
	    sleep $idleFlush;
	    system("immssdescms -h $host -i $admin > /dev/null");
	}
    } else {
	setConfig('mss', 'testAccount', $oldTestAccount);
	setConfig('mss', 'testQuotaAgeSeconds', $oldAgeSeconds);
	setConfig('mss', 'testQuotaRetrSeconds', $oldRetrSeconds);
	setConfig('mss', 'testQuotaFirstReadSeconds', $oldFirstSeconds);
    }
}

exit 0;


############################################################
#
# Connect to front end processor and deliver message.

sub process
{
    my $filename = shift;
    my $filehandle = shift;
    my $bytes = 0;
    my $lines = 0;
    my $line;
    my @mesg;
    my $mbox;

    ## read file into @mesg, compute $bytes, $lines
    foreach $line (@headers) {
	if ($line =~ /^[^:]*:\S/) {
	    $line =~ s/:/: /;
	}
	$line .= "\n";
	push(@mesg, $line);
	$bytes += length($line);
	$lines += 1;
    }
    if ($expirHdr) {
	push(@mesg, $expirHdr);
	$bytes += length($expirHdr);
	$lines += 1;
    }
    while (defined($_ = <$filehandle>)) {
	push(@mesg, $_);
    	$bytes += length($_);
	$lines += 1;
	last if ($maxBytes > 0 && $bytes >= $maxBytes);
	last if ($maxLines > 0 && $lines >= $maxLines);
    }

    ## deliver mail
    if ($usesmtp) {
	appendSMTP(@mesg);
    } else {
	appendIMAP($bytes, @mesg);
    }

    ## if no aging, then we're done
    if ($ageSecs <= 0 && $retrSecs <= 0 && $firstSecs <= 0) {
	return;
    }

    ## if we use config key aging, then we're done
    if (! $usingOracle) {
	return;
    }

    my $sql;
    my $results;
    my @results;

    ## Which schema are we using?
    @results = RunQuery(<<EOF);
		    SELECT count(*)
		      FROM user_objects
		     WHERE object_name = 'IM_FOLDERMESSAGE'
		       AND NOT EXISTS (SELECT 1
					 FROM user_views
					WHERE view_name = 'MX_USE_IOT_SCHEMA');
EOF

    my $useLegacy = shift(@results);

    if ($useLegacy) {
	debug("Using Oracle legacy V5 schema.\n");

	@results = RunQuery(<<EOF);
		SELECT msNum, folderNum, messageNum
		  FROM IM_FolderMessage
		 WHERE messageNum = (SELECT MAX(messageNum)
				       FROM IM_FolderMessage);
EOF

	my $msNum      = shift(@results);
	my $folderNum  = shift(@results);
	my $messageNum = shift(@results);

	debug("msNum      = $msNum.\n");
	debug("folderNum  = $folderNum.\n");
	debug("messageNum = $messageNum.\n");

	unless ($msNum =~ /^\d+$/
	     && $folderNum =~ /^\d+$/
	     && $messageNum =~ /^\d+$/) {
	    error("Invalid results from IM_FolderMessage"
		. " ($msNum, $folderNum, $messageNum)");
	}

	# Get mailbox name so we can return it.
	@results = RunQuery(<<EOF);
		SELECT msName
		  FROM IM_MessageStore
		 WHERE msNum = $msNum;
EOF

	$mbox = shift(@results);
	debug("msName     = $mbox.\n");

	## update IM_Message.arrivalDate
	if ($ageSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE IM_Message
		   SET arrivalDate = (arrivalDate - $ageDays),
		       arrivalSeconds = (arrivalSeconds - $ageSecs)
		 WHERE messageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE IM_Folder
		   SET msgArrivalDateLowerBound =
			(SELECT NVL(MIN(NVL(m.arrivalDate,SYSDATE)),SYSDATE)
			   FROM IM_FolderMessage fm,
				IM_Message m
			  WHERE fm.folderNum  = $folderNum
			    AND fm.messageNum = m.messageNum)
		 WHERE folderNum = $folderNum;
EOF

	    @results = RunQuery(<<EOF);
		    SELECT COUNT(*)
		      FROM User_Tab_Columns
		     WHERE table_name  = 'IM_FOLDERMESSAGE'
		       AND column_name = 'MSGMAILBOXARRIVALSECONDS';
EOF

	    my $hasColumn = shift(@results);
	    debug("hasColumn  = $hasColumn.\n");

	    unless ($hasColumn =~ /^\d+$/) {
		error("Invalid results from User_Tab_Columns ($hasColumn)");
	    }

	    if ($hasColumn) {
		RunQuery(<<EOF);
		    UPDATE IM_FolderMessage
		       SET msgMailboxArrivalSeconds =
			   msgMailboxArrivalSeconds - $ageSecs
		     WHERE folderNum  = $folderNum
		       AND messageNum = $messageNum;
EOF
	    }
	}

	## update IM_FolderMessage.timeLastAccessed
	if ($retrSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE IM_FolderMessage
		   SET timeLastAccessed = SYSDATE - $retrDays
		 WHERE folderNum  = $folderNum
		   AND messageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE IM_Folder
		   SET msgTimeLastAccessedLowerBound = (
			SELECT NVL(MIN(DECODE(timeLastAccessed,
					NULL,
					SYSDATE,
					TO_DATE('05/05/5555','MM/DD/YYYY'),
					SYSDATE,
					timeLastAccessed)),SYSDATE)
			  FROM IM_FolderMessage fm
			 WHERE folderNum = $folderNum)
		 WHERE folderNum = $folderNum;
EOF
	}

	## update IM_FolderMessage.firstAccessTime
	if ($firstSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE IM_FolderMessage
		   SET firstAccessTime = SYSDATE - $firstDays
		 WHERE folderNum  = $folderNum
		   AND messageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE IM_Folder
		   SET msgTimeFirstAccessedLowerBound = (
			SELECT NVL(MIN(DECODE(firstAccessTime,
					NULL,
					SYSDATE,
					TO_DATE('05/05/5555','MM/DD/YYYY'),
					SYSDATE,
					firstAccessTime)),SYSDATE)
			  FROM IM_FolderMessage fm
			 WHERE folderNum = $folderNum)
		 WHERE folderNum = $folderNum;
EOF
	}
    } else {
	debug("Using Oracle IOT schema.\n");

	## Get key values.
	@results = RunQuery(<<EOF);
		SELECT hashedBoxId, boxId, relativeFolderNum, mboxMessageNum
		  FROM MX_MboxMsgs_View
		 WHERE msg_arrivalDate = (SELECT MAX(msg_arrivalDate)
					    FROM MX_MboxMsgs_View);
EOF

	my $hashedBoxId = shift(@results);
	my $boxId       = shift(@results);
	my $folderNum   = shift(@results);
	my $messageNum  = shift(@results);

	$mbox = $boxId;

	debug("hashedBoxId = $hashedBoxId.\n");
	debug("boxId       = $boxId.\n");
	debug("folderNum   = $folderNum.\n");
	debug("messageNum  = $messageNum.\n");

	unless ($boxId =~ /^\d+$/
	     && $folderNum =~ /^\d+$/
	     && $messageNum =~ /^\d+$/) {
	    error("Invalid results from MX_MboxMsgs_View"
		. " ($boxId, $folderNum, $messageNum)")
	}

	## Update arrival date.
	if ($ageSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE MX_MboxMsgs_View
		   SET msg_arrivalDate = (msg_arrivalDate - $ageDays),
		       msg_arrivalSeconds = (msg_arrivalSeconds - $ageSecs),
		       fm_mailboxArrivalSeconds =
					(fm_mailboxArrivalSeconds - $ageSecs)
		 WHERE hashedBoxId = '$hashedBoxId'
		   AND boxId = '$boxId'
		   AND relativeFolderNum = $folderNum
		   AND mboxMessageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE Mx_Folder_View
		   SET fldr_msgArrivalDateLowerBound =
			(SELECT NVL(MIN(NVL(msg_arrivalDate,SYSDATE)),SYSDATE)
			   FROM MX_MboxMsgs_View
			  WHERE hashedBoxId = '$hashedBoxId'
			    AND boxId = '$boxId'
			    AND relativeFolderNum = $folderNum)
		 WHERE boxId = '$boxId'
		   AND relativeFolderNum = $folderNum;
EOF
	}

	## Update retrieval date.
	if ($retrSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE MX_MboxMsgs_View
		   SET fm_timeLastAccessed = SYSDATE - $retrDays
		 WHERE hashedBoxId = '$hashedBoxId'
		   AND boxId = '$boxId'
		   AND relativeFolderNum = $folderNum
		   AND mboxMessageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE Mx_Folder_View
		   SET msgTimeLastAccessedLowerBound = (
			SELECT NVL(MIN(DECODE(fm_timeLastAccessed,
				      NULL,
				      SYSDATE,
				      TO_DATE('05/05/5555','MM/DD/YYYY'),
				      SYSDATE,
				      fm_timeLastAccessed)),SYSDATE)
			  FROM MX_MboxMsgs_View
			 WHERE hashedBoxId = '$hashedBoxId'
			   AND boxId = '$boxId'
			   AND relativeFolderNum = $folderNum)
		 WHERE boxId = '$boxId'
		   AND relativeFolderNum = $folderNum;
EOF

	}

	## Update first-access date.
	if ($firstSecs > 0) {
	    RunQuery(<<EOF);
		UPDATE MX_MboxMsgs_View
		   SET fm_timeFirstAccessed = SYSDATE - $retrDays
		 WHERE hashedBoxId = '$hashedBoxId'
		   AND boxId = '$boxId'
		   AND relativeFolderNum = $folderNum
		   AND mboxMessageNum = $messageNum;
EOF

	    RunQuery(<<EOF);
		UPDATE Mx_Folder_View
		   SET msgTimeFirstAccessedLowerBound = (
			SELECT NVL(MIN(DECODE(fm_timeFirstAccessed,
				      NULL,
				      SYSDATE,
				      TO_DATE('05/05/5555','MM/DD/YYYY'),
				      SYSDATE,
				      fm_timeFirstAccessed)),SYSDATE)
			  FROM MX_MboxMsgs_View
			 WHERE hashedBoxId = '$hashedBoxId'
			   AND boxId = '$boxId'
			   AND relativeFolderNum = $folderNum)
		 WHERE boxId = '$boxId'
		   AND relativeFolderNum = $folderNum;
EOF
	}
    }

    return $mbox;
}



############################################################
#
# Connect to SMTP and append message.

sub appendSMTP
{
    openSMTP($host, $port);
    sendSMTP("mail from: $sender");
    sendSMTP("rcpt to: <$user>");
    sendSMTP("rcpt to: <$user2>") if ($user2);
    sendSMTP("rcpt to: <$user3>") if ($user3);
    sendSMTP("data");
    dumpSMTP(@_);
    sendSMTP("quit");
    shutSMTP();
}



############################################################
#
# Connect to IMAP and append message.

sub appendIMAP
{
    my $size = shift;

    openIMAP($host, $port);
    sendIMAP("a1", "login $user $pass");
    unless ($folder eq "inbox") {
	my @folders = listIMAP("L1");
	my @matches = grep { $_ eq $folder } @folders;
	sendIMAP("L2", "create \"$folder\"") unless (@matches);
    }
    #;;; sendIMAP("a3", "select \"$folder\"");
    if ($flags) {
	sendIMAP("a4", "append \"$folder\" $flags {$size}", 1);
    } else {
	sendIMAP("a4", "append \"$folder\" {$size}", 1);
    }
    dumpIMAP(@_);
    sendIMAP("a5", "logout");
    shutIMAP();
}


############################################################
#
# SMTP connection routines

sub openSMTP
{
    my $host = shift;
    my $port = shift;

    socket(SMTP, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
    my $inet_addr = inet_aton($host)
    	or die "couldn't convert $host to an internet address\n";

    my $port_addr = sockaddr_in($port, $inet_addr);
    connect(SMTP, $port_addr)
    	or die "couldn't connect to $host:$port\n";

    # set autoflushing on socket handle
    my $old = select(SMTP);
    $| = 1;
    select($old);

    readSMTP("connect");
}

sub shutSMTP
{
    close(SMTP);
}

sub sendSMTP
{
    my $str = shift;
    
    debug("$str\n");
    print SMTP "$str\r\n";

    readSMTP($str);
}

sub readSMTP
{
    my $cmd = shift;
    my $str = <SMTP>;
    if (defined($str)) {
	debug("$str");
	if ($str =~ /^[45]/) {
	    error("SMTP error.\nClient: $cmd\nServer: $str");
	}
    } else {
	debug("EOF\n");
	error("SMTP error.\nClient: $cmd\nServer: EOF\n");
    }
}

sub dumpSMTP
{
    my $line;
    while ($line = shift) {
	debug("$line");
    	print SMTP "$line";
    }
    debug("\n");
    print SMTP "\r\n";
    debug(".\n");
    print SMTP ".\r\n";
}

############################################################
#
# IMAP connection routines

sub openIMAP
{
    my $host = shift;
    my $port = shift;

    socket(IMAP, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
    my $inet_addr = inet_aton($host)
    	or die "couldn't convert $host to an internet address\n";

    my $port_addr = sockaddr_in($port, $inet_addr);
    connect(IMAP, $port_addr)
    	or die "couldn't connect to $host:$port\n";

    # set autoflushing on socket handle
    my $old = select(IMAP);
    $| = 1;
    select($old);

    $_ = <IMAP>;
    debug("$_");
}

sub shutIMAP
{
    close(IMAP);
}

# Used with sendIMAP below.
my %cmds;

sub sendIMAP
{
    my $tag = shift;
    my $cmd = shift;
    my $opt = shift;
    my $str = "";

    debug("$tag $cmd\n");
    print IMAP "$tag $cmd\n";

    $cmds{$tag} = $cmd;

    if ($opt) {
    	$str = <IMAP>;
	if (defined($str)) {
	    debug("$str");
	} else {
	    debug("EOF\n");
	}
    } else {
	while (defined($_ = <IMAP>)) {
	    debug("$_");
	    $str = $str . $_;

	    my @resp_arr = split(' ');
	    my $resp_tag = $resp_arr[0];
	    my $resp_flg = $resp_arr[1];
	    my $resp_cmd = $cmds{$resp_tag};

	    next if (!$resp_cmd);

	    if ($resp_flg eq 'NO') {
		warn("IMAP error.\nClient: $resp_tag $resp_cmd\nServer: $str");
	    }

	    if ($resp_flg eq 'BAD') {
		error("IMAP error.\nClient: $resp_tag $resp_cmd\nServer: $str");
	    }

	    last if ($resp_tag eq $tag);
	}
    }

    return $str;
}

sub listIMAP
{
    my $tag = shift;
    my $cmd = 'list "" *';
    my $str = "";

    debug("$tag $cmd\n");
    print IMAP "$tag $cmd\n";

    $cmds{$tag} = $cmd;

    my @results;

    while (defined($_ = <IMAP>)) {
	debug("$_");
	$str = $str . $_;

	my @resp_arr = split(' ');
	my $resp_tag = $resp_arr[0];
	my $resp_flg = $resp_arr[1];
	my $resp_cmd = $cmds{$resp_tag};

	if ($resp_tag eq '*' && $resp_flg eq 'LIST') {
	    my $result = $resp_arr[4];
	    $result =~ s/"//g;
	    push(@results, $result);
	}

	next if (!$resp_cmd);

	if ($resp_flg eq 'NO') {
	    warn("IMAP error.\nClient: $resp_tag $resp_cmd\nServer: $str");
	}

	if ($resp_flg eq 'BAD') {
	    error("IMAP error.\nClient: $resp_tag $resp_cmd\nServer: $str");
	}

	last if ($resp_tag eq $tag);
    }

    return @results;
}

sub dumpIMAP
{
    my $line;
    while ($line = shift) {
	debug("$line");
    	print IMAP "$line";
    }
}

############################################################
#
# Oracle routines

my $sqlpass;
my $sqlplus;

# Initialize support for Oracle.
sub InitOracle
{
    my $oraUserPassword = getConfig('mss', 'oracleUserPassword');
    my $oraConnection   = getConfig('mss', 'oracleConnection');

    $sqlpass = $oraUserPassword . '@' . $oraConnection;
    $sqlplus = $ENV{ORACLE_HOME} . "/bin/sqlplus";
}

# Run SQL script query and return result(s).
sub RunQuery
{
    my $query = shift;
    my $parms = shift;

    my $script = '/tmp/' . $$ . '_.sql';
    my @results;

    # Write script to temporary file.
    if (!open(SCRIPT, ">$script")) {
	error("Cannot create $script");
    }
    print SCRIPT <<EOF;
set feedback off
set heading off
set numwidth 20
set verify off
EOF
    print SCRIPT "$query\n";
    print SCRIPT <<EOF;
quit;
EOF
    close(SCRIPT);
    debug("--------------------------------------------------\n");
    debug("QUERY:\n");
    debug($query);

    # Execute script and capture results.
    if ($parms) {
	if (!open(SQL, "$sqlplus -s $sqlpass \@$script '$parms'|")) {
	    error("Cannot run $sqlplus");
	}
    } else {
	if (!open(SQL, "$sqlplus -s $sqlpass \@$script|")) {
	    error("Cannot run $sqlplus");
	}
    }
    debug("--------------------------------------------------\n");
    debug("RESULT:\n");
    my $result;
    while (defined($result = <SQL>)) {
	debug($result);
	next if ($result =~ /^\s*\n?$/);
	chomp($result);
	error($result) if ($result =~ /^ORA-[0-9]+:/);
	foreach my $field (split(' ', $result)) {
	    push(@results, $field eq "NULL" ? undef : $field);
	}
    }
    close(SQL);

    # Delete script file.
    unlink $script;

    # Return all results or first,
    # depending on context.
    return wantarray ? @results : $results[0];
}

############################################################
#
# Utility routines

sub getMailbox
{
    my $address = shift;
    my $result = strip(`imboxget $address | awk -F= '{print \$NF;}'`);
    $result =~ s/^Cannottranslate.*$//;
    return $result;
}

# Fetch a config value with "imconfget".
#	-- (stolen from immovemsgfiles)
sub getConfig
{
    my ($module, $key, $dflt) = @_;
    my $imconfget = "$ENV{INTERMAIL}/bin/imconfget";

    my $args = "-m $module $key";
    if (defined($dflt)) {
	$args .= " -d $dflt";
    }

    if (!open(IMCONFGET, "sh -c '$imconfget $args 2>/dev/null' |")) {
	error("Cannot run '$imconfget'");
    }
    my $keyvalue =<IMCONFGET>;
    close(IMCONFGET);

    if (defined($keyvalue)) {
	$keyvalue =~ s/^.*NOT FOUND.*$//;
	$keyvalue =~ s/\n//g;
    }

    return $keyvalue;
}

# Set a config value with "imconfcontrol".
sub setConfig
{
    my $imconfcontrol = "$ENV{INTERMAIL}/bin/imconfcontrol";
    my $args = "";

    my $module = shift;

    my $host = strip(`hostname`);

    my $key;
    while (defined($key = shift)) {
	my $value = shift;
	$args .= (defined($value))
	    ? " -key /$host/$module/$key=$value"
	    : " -key /$host/$module/$key"
	    ;
    }

    debug('imconfcontrol -install' . $args . "\n");
    system($imconfcontrol . ' -install' . $args . ' | egrep -v "(^Reporting:|trivially)"');
}

# Print message only if debugging.
sub debug()
{
    if ($debugging) {
	my $msg = shift;
	print STDOUT "$msg";
    }
}

# Print error message but live to fight the good fight.
sub warn()
{
    my $msg = shift;
    if ($! > 0) {
    	$msg = sprintf("%s (%s)", $msg, $!);
    }
    print STDERR "$prog: $msg\n";
    exit 1 if ($exitOnWarning);
}

# Print error message and die.
sub error()
{
    my $msg = shift;
    warn($msg);
    exit 99;
}

# Strip whitespace and trailing newline.
sub strip
{
    my $s = shift;
    if (defined($s)) {
	$s =~ s/\s//g;
	$s =~ s/\n$//;
    }
    return $s;
}
