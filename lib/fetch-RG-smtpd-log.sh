#!/bin/bash
# Tells the RazorGate's smtpd to flush its log file, and then pulls the log file off.
# If log is empty, wait a bit and try again.

if [ "$1" != "" ]; then
	RG1_CURRENT_SMTP_LOG="$1"
elif [ "$RG1_CURRENT_SMTP_LOG" = "" ]; then
	echo "No log file specified"
	exit 1
fi

URL="https://$RG1_HOST/admin/download.html?x=system.LogSMTPDownloader&u=$RG1_ADMIN_USER&p=$RG1_PASSWORD&y=get&id=1"

echo "Downloading to \"$RG1_CURRENT_SMTP_LOG\" and \"$RG1_CURRENT_SMTP_LOG.no-localhost\""
rm -f $RG1_CURRENT_SMTP_LOG $RG1_CURRENT_SMTP_LOG.no-localhost

#-------------------------------------------------
# do it in a subroutine so we can call it twice if necessary
fetch_RG_smtpd_log ()
{
	echo Flushing the MAA smtpd log and then getting it...
	
	host=$1
	port=$2
	pass=$3
	log=$4

	manager.pl $host $port $pass "LOGGING FLUSH SMTP" || exit 1

	wget --quiet --no-check-certificate -O - "$URL" > $log
	if [ $? -ne 0 ]; then
		## Since we used the --quiet option we can't diagnose problems -- try Wget again to see if we can get the info now
		wget --no-check-certificate -O - "$URL"
		echo "Wget of log failed"
		exit 1
	fi
	grep -v " 127\.0\.0\.1" $log > $log.no-localhost
	# Ignore return from grep - we don't care if there are matches or not

}

#-------------------------------------------------

fetch_RG_smtpd_log $RG1_HOST $RG1_AAA_MGMT_PORT $RG1_PASSWORD $RG1_CURRENT_SMTP_LOG

# Check that the log is not empty, else wait a bit longer and get the log again
if [ ! -s $RG1_CURRENT_SMTP_LOG ]
then
	echo "It's empty, so wait a bit..."
	sleep 10
	fetch_RG_smtpd_log $RG1_HOST $RG1_AAA_MGMT_PORT $RG1_PASSWORD $RG1_CURRENT_SMTP_LOG
fi

if [ "$2" != "" ]; then
	URL="https://$RG2_HOST/admin/download.html?x=system.LogSMTPDownloader&u=$RG2_ADMIN_USER&p=$RG2_PASSWORD&y=get&id=1"
	RG2_CURRENT_SMTP_LOG=$2
	rm -f $RG2_CURRENT_SMTP_LOG $RG2_CURRENT_SMTP_LOG.no-localhost
	fetch_RG_smtpd_log $RG2_HOST $RG2_AAA_MGMT_PORT $RG2_PASSWORD $RG2_CURRENT_SMTP_LOG
fi
