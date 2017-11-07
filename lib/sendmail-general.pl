#!/usr/bin/perl
#
# Usage: sendmail-status.pl [--auth-user=<login name>]
#                           [--auth-pass=<password>]
#                           [--auth-method=(LOGIN|PLAIN)]
#			    [--msg-file=<filename>]
#			    [--smtp-host=<hostname>]
#			    [--smtp-port=<port>]
#			    [--send-count=<number>]
#			    [--subject=<subject>]
#                           [--text=<text>]
#			    <from> <to> [<another to>]
#
# 		Specify - for <filename> in --msg-file=<filename> for stdin.
#
# Connect to <host>:<port>
# Send HELO or EHLO
# Send MAIL FROM:<from>
# Send RCPT TO:<to>
# Send DATA
# Send <content of file>
# Send .
# Send QUIT

require "$ENV{'_bohem_dir'}/lib/smtp.pm";

use Getopt::Long;
use MIME::Base64;

GetOptions("auth-user=s" => \$AUTH_USER,
           "auth-pass=s" => \$AUTH_PASS,
           "auth-method=s" => \$AUTH_METHOD,
	   "esmtp!" => \$ESMTP,
	   "helo-ehlo=s" => \$HELO,
	   "msg-file=s" => \$FILEIN,
           "smtp-host=s" => \$HOST,
	   "smtp-port=i" => \$PORT,
	   "send-count=i" => \$COUNT,
	   "subject=s" => \$SUBJECT,
	   "text=s" => \$TEXT,
	   "outfile=s" => \$FILEOUT);


$FROM=$ARGV[0];
$TO=$ARGV[1];
$TO_2=$ARGV[2];

if (($FROM eq "") || ($TO eq "")) {
	printf "Usage: sendmail-general.pl  [--auth-user=<login name>]\n";
        printf "                            [--auth-pass=<password>]\n";
        printf "                            [--auth-method=<auth method>]\n";
	printf "                            [--esmtp | --noesmtp ] (use ESMTP or not)\n";
	printf "                            [--helo-ehlo=<string>\n";
        printf "                            [--msg-file=<filename>]\n";
        printf "                            [--smtp-host=<hostname>]\n";
        printf "                            [--smtp-port=<port>]\n";
	printf "			    [--send-count=<number>]\n";
        printf "                            [--subject=<subject>]\n";
        printf "                            [--text=<text>]\n";
	printf "                            [--outfile=<filename>]\n";
        printf "                            <from> <to>\n\n";
        printf "       Specify - for <filename> in --msg-file=<filename> for stdin.\n";
        exit 1;
}

# Fill in the default values for parameters
#
if ($HOST eq "") {
	$HOST="localhost";
}

if ($PORT eq "") {
	$PORT="25";
}

if ($COUNT eq "" ) {
	$COUNT="1";
}

if ($SUBJECT eq "") {
	$SUBJECT="Message subject";
}

if ($TEXT eq "") {
	$TEXT="Message text";
}

if (($AUTH_PASS != "") && ($AUTH_USER eq "")) {
	$AUTH_USER=$TO;
}

if ($ESMTP eq "" ) {
	$ESMTP="1";
}

if ($HELO eq "") {
	$HELO="sendmail.general.pl";
}

# ok open the out file if specified
#
if ($FILEOUT) {
	if (!open($RESPONSES, ">", $FILEOUT)) {
		printf "failed to open output file $FILEOUT\n";
		exit 1;
	}
}

#
# SMTP connection

my($smtpSession, $rc, $x);

$smtpSession = smtp::new();
if($smtpSession eq 0) {
	printf "telnet failed\n";
	exit 1;
}
$smtpSession->setVerbose ("ON");

$rc = $smtpSession->smtp_connect ($HOST, $PORT);
if($rc != 1) {
	printf "failed to conect to SMTP server $HOST on port $PORT\n";
	exit 2;
}
$x = $smtpSession->get_response();
$code=substr($x, 0, 3);

if ($FILEOUT) {
	print $RESPONSES "CONNECT RESPONSE $x";
}

if ($code != 220) {
	printf "SMTP STATUS: $code\n";
	exit 20;
}

# choose between ESMTP or SMTP (i.e. EHLO or HELO)
#
if ($ESMTP) {
	$rc = $smtpSession->sendCommand ("EHLO $HELO");
	if($rc != 1) {
		printf "failed to send SMTP command\n";
		exit 3;
	}
	$x = $smtpSession->get_multiline_response();
	if ($FILEOUT) {
		print $RESPONSES "EHLO RESPONSE $x";
	}

	$code=substr($x, 0, 3);
	if ($code != 250) {
        	printf "SMTP STATUS: $code\n";
        	exit 30;
	}

}
else {
	$rc = $smtpSession->sendCommand ("HELO $HELO");
	if($rc != 1) {
		printf "failed to send SMTP command\n";
		exit 3;
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "HELO RESPONSE $x";
	}

	$code=substr($x, 0, 3);
	if ($code != 250) {
        	printf "SMTP STATUS: $code\n";
        	exit 30;
	}
}

# if auth login enabled
if ($AUTH_METHOD eq "LOGIN") {
	# send AUTH LOGIN

	my $b_id= MIME::Base64::encode($AUTH_USER, "");
	my $b_pass= MIME::Base64::encode($AUTH_PASS, "");

	$rc = $smtpSession->sendCommand ("AUTH LOGIN");
	if($rc != 1) {
	  printf "Sending AUTH LOGIN failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "AUTH RESPONSE $x";
	}

	$code=substr($x, 0, 3);
	if ($code != 334) {
		printf "SMTP STATUS: $code\n";
		exit 40;
	}

	$rc = $smtpSession->sendCommand ("$b_id");
	if($rc != 1) {
	  printf "Sending AUTH LOGIN failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "AUTH RESPONSE $x";
	}
	$code=substr($x, 0, 3);
	if ($code != 334) {
		printf "SMTP STATUS: $code\n";
		exit 50;
	}

	# send password

	$rc = $smtpSession->sendCommand ("$b_pass");
	if($rc != 1) {
	  printf "Sending AUTH LOGIN password failed\n";
	  exit 5
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "AUTH RESPONSE $x";
	}
	$code=substr($x, 0, 3);
	if ($x =~ /^535.*/) {
	  printf "SMTP AUTH failed: $x\n";
	  exit 60;
	}

# else if auth plain enabled
} elsif ($AUTH_METHOD eq "PLAIN") {
	$rc = $smtpSession->sendCommand ("AUTH PLAIN");
	if($rc != 1) {
	  printf "Sending AUTH PLAIN failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "AUTH RESPONSE $x";
	}
	$code=substr($x, 0, 3);
	#if ($x ne "334 ?") {
		#printf "Bad prompt back from server ($x)";
		#exit 5;
	#}

	$auth_str = MIME::Base64::encode("\0$AUTH_USER\0$AUTH_PASS","");
	printf "AUTH=($auth_str)\n";
	$rc = $smtpSession->sendCommand($auth_str);
	if($rc != 1) {
	  printf "Sending AUTH string failed\n";
	  exit 4
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "AUTH RESPONSE $x";
	}

	$code=substr($x, 0, 3);
    @words = split(/ /, $x);
    if(@words[0] ne "235") {
        printf "Didn't get OK for PLAIN AUTH\n";
        exit 70;
    }

# allowed to not used SMTP AUTH at all however, dont specify junk either
} elsif ($AUTH_METHOD != "") {
	printf "Unsupported auth method: $AUTH_METHOD\n";
	exit 123
}

for ($i = 0; $i < $COUNT; $i++)
{
	if ($ESMTP) {
		# send MAIL FROM
		print "TO_2=$TO_2\n";
	        if ($TO_2) {
		        $rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>\r\nRCPT TO:<$TO>\r\nRCPT TO:<$TO_2>\r\nDATA");
			print "1 TO_2=$TO_2\n";
      	  	}
		else {
		        $rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>\r\nRCPT TO:<$TO>\r\nDATA");
			print "2 TO_2=$TO_2\n";
		}
		if($rc != 1) {
			printf "failed to send SMTP commands\n";
			exit 4;
		}

		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "MAIL RESPONSE $x";
		}

		$code=substr($x, 0, 3);
		if ($code != 250) {
			printf "SMTP STATUS: $code\n";
			exit 80;
		}

		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "RCPT RESPONSE $x";
		}

		$code=substr($x, 0, 3);

        	$code_2="550";
        	if ($TO_2) {
			$x_2 = $smtpSession->get_response();
			if ($FILEOUT) {
				print $RESPONSES "RCPT RESPONSE $x_2";
			}

			$code_2=substr($x_2, 0, 3);
        	}
		if (($code != 250) && ($code_2 != 250)) {
			if ($TO_2) {
				printf "SMTP STATUS: $code and $code_2\n";
			}
			else {
				printf "SMTP STATUS: $code\n";
			}
			exit 90;
		}

		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "DATA RESPONSE $x";
		}

		$code=substr($x, 0, 3);
		if ($code != 354) {
			printf "SMTP STATUS: $code\n";
			exit 100;
		}
	}

	else {
		# send MAIL FROM

		$rc = $smtpSession->sendCommand ("MAIL FROM:<$FROM>");
		if($rc != 1) {
			printf "failed to send SMTP command\n";
			exit 4;
		}
		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "MAIL RESPONSE $x";
		}

		$code=substr($x, 0, 3);

		if ($code != 250) {
			printf "SMTP STATUS: $code\n";
			exit 110;
		}

		$rc = $smtpSession->sendCommand ("RCPT TO:<$TO>");
		if($rc != 1) {
			printf "failed to send SMTP command\n";
			exit 5;
		}
		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "RCPT RESPONSE $x";
		}

		$code=substr($x, 0, 3);

        	$code_2="550"; 
        	if ($TO_2) {
			$rc = $smtpSession->sendCommand ("RCPT TO:<$TO>");
			if($rc != 1) {
				printf "failed to send SMTP command\n";
				exit 5;
			}
			$x_2 = $smtpSession->get_response();
			if ($FILEOUT) {
				print $RESPONSES "RCPT RESPONSE $x_2";
			}
		$code_2=substr($x, 0, 3);
		}


		if (($code != 250) && ($code_2 != 250)) {
			if ($TO_2) {
				printf "SMTP STATUS: $code $code_2\n";
			}
			else {
				printf "SMTP STATUS: $code\n";
			}
			exit 120;
		}
		$rc = $smtpSession->sendCommand ("DATA");
		if($rc != 1) {
			printf "failed to send SMTP command\n";
			exit 6;
		}
		$x = $smtpSession->get_response();
		if ($FILEOUT) {
			print $RESPONSES "DATA RESPONSE $x";
		}

		$code=substr($x, 0, 3);
		if ($code != 354) {
			printf "SMTP STATUS: $code\n";
			exit 130;
		}
	}

	if ($FILEIN) {
		open(FH, $FILEIN);
		while (defined($line = <FH>)) {
			chomp $line;
			if($line =~ m/^\./) {
				$line = "." .  $line;
			}
			$rc = $smtpSession->sendCommand ("$line");
			if($rc != 1) {
				printf "failed to send SMTP data\n";
				exit 7;
			}
		}
	} else {
		$rc = $smtpSession->sendCommand ("From: $FROM");
		$rc = $smtpSession->sendCommand ("To: $TO");
		$rc = $smtpSession->sendCommand ("Subject: test");
		$rc = $smtpSession->sendCommand ("");
		$rc = $smtpSession->sendCommand ("Test mail");
		if($rc != 1) {
			printf "failed to send SMTP data\n";
			exit 7;
		}
	}

	$rc = $smtpSession->sendCommand (".");
	if($rc != 1) {
		printf "failed to send SMTP command\n";
		exit 8;
	}
	$x = $smtpSession->get_response();
	if ($FILEOUT) {
		print $RESPONSES "MESSAGE RESPONSE $x";
	}

	$code=substr($x, 0, 3);
	if ($code != 250) {
		printf "SMTP STATUS: $code\n";
		exit 150;
	}
}

$rc = $smtpSession->smtp_disconnect();

# Send HELO
exit 0;
