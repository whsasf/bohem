
# --- dependencies ------------------------------------------------------------

# perl/sendmail-status.pl

# --- variables ---------------------------------------------------------------

declare subject="Test $(basename $0)"
#declare hdrname="x-header"
#declare hdrtext="header value"
#declare bodytext="blah"

# -----------------------------------------------------------------------------

SendTestMail()  # <hostname> <from> <to> [<subject>]
{
        local host_name="$1"
        local from="$2"
        local rcpt="$3"

	if [ "$4" != "" ]; then subject="$4"; fi

        local state="true"
        count=1        

	echo "Send a test mail from [$from] to [$rcpt]"

        while [ $state = "true" ]
        do
        	perl/sendmail-status.pl $host_name $smtp_port "$from" "$rcpt" - << ENDOFMESSAGE
From: "$from" <$from>
To: "$rcpt" <$rcpt>
Subject:$subject  
hdrname: x-header
	
Body Text
		
ENDOFMESSAGE
		if [ $? -eq 0 ]
        	then
        		state="false"
                elif [ $? != 0 ]
	        then
		        echo "SOFT ERROR: Mail could not be sent"
		        count=`expr $count + 1`
		        sleep 5
		        	if [ $count -gt 10 ]
		            	then
		                	echo "HARD ERROR - Problem - no mail after $count tries"
		                        return 1
                              	fi
              	fi
    	done
           	
       	echo "Mail sent after $count tries"
       	return 0
}


# -----------------------------------------------------------------------------

CheckInboxForMail()  # <inbox> [<grep-text>]
{
	local user="$1"
	local text="$2"
	
	if [ "$text" == "" ]; then text="Subject: $subject"; fi
	
	echo "Check if [$user] inbox contains 1 mail with [$text]"
	
	perl/popmail.pl $host_name 110 $user $pass | grep "$text"
	if [ $? != 0 ]
	then
		echo "ERROR: No Mail found [$text]"
		return 1
	fi
	
	echo "Mail found"
	return 0
}


# -----------------------------------------------------------------------------

CheckInboxForMail_MAA()  # <inbox> <grep-text> [<hostname>]
{
        local user="$1"
        local text="$2"
	local hostname="$3"

        if [ "$3" = "" ]; then hostname="$host_name"; fi
        
        local state="true"
        count=1

        echo "Check if [$user] inbox contains 1 mail with [$text]"

        while [ $state = "true" ]
        do
                #perl/popmail.pl $hostname 110 $user $pass | grep "$text"
                popmail.pl $hostname 110 $user $pass | grep "$text"
                if [ $? -eq 0 ]
		then
			state="false"
                elif [ $? != 0 ]
                then
                        echo "SOFT ERROR: No Mail found with [$text]"
                        count=`expr $count + 1`
                        sleep 5
                		if [ $count -gt 10 ]
                		then
                        		echo "HARD ERROR - Problem - no mail after $count tries"
                        		return 1
                		fi
	        fi	
                
        done

        echo "Mail found after $count tries"
        return 0
}

# -----------------------------------------------------------------------------

CheckInboxForMail_NoText()  # <inbox> <grep-text> [<hostname>]
{
        local user="$1"
        local text="$2"
	local hostname="$3"

        if [ "$3" = "" ]; then hostname="$host_name"; fi

        local state="true"
	count=1
	
	echo "First, make sure mail is there"
	while [ $state = "true" ]
	        do
	                perl/popmail.pl $hostname 110 $user $pass
	                if [ $? -eq 0 ]
	                then
	                        state="false"
	                elif [ $? != 0 ]
	                then
	                        echo "SOFT ERROR: No Mail found (yet)"
	                        count=`expr $count + 1`
	                        sleep 5
	                                if [ $count -gt 10 ]
	                                then
	                                        echo "HARD ERROR - Problem - no mail after $count tries"
	                                        return 1
	                                fi
	                fi
	
        done
	
	echo "Then, check if [$user] inbox contains 1 mail without [$text]"
        perl/popmail.pl $hostname 110 $user $pass | grep "$text"
        if [ $? -eq 0 ]
        then
                echo "Found [$text] - shouldn't have"
                return 1
        fi

        echo "Mail found without [$text] - good"
        return 0
}


# -----------------------------------------------------------------------------

CheckInboxForNoMail()  # <inbox> [<hostname>]
{
        local user="$1"
        local hostname="$2"

        if [ "$2" = "" ]; then hostname="$host_name"; fi

        echo "Check if [$user] inbox contains 0 mails"

        perl/popmail.pl $hostname 110 $user $pass

        if [ $? -eq 0 ]
        then
                echo "ERROR: A mail was found, no mail should have there"
                return 1
        fi

        echo "No Mail found -- good"
        return 0
}

# -----------------------------------------------------------------------------

WaitDelivery()
{
	local delay=3
	
	echo "Wait $delay seconds for Delivery"
	sleep $delay
}

# -----------------------------------------------------------------------------

WaitDelivery_MAA()
{
        local delay=5

        echo "Wait $delay seconds for Delivery"
        sleep $delay
}
