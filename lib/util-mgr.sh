
# --- dependencies ------------------------------------------------------------

source $(which manager.bash)
#source util/manager.bash

# -----------------------------------------------------------------------------

CreateGlobalGateway()  # <domain> [<user1>...]
{
        local gateway=$1; shift

#Need todo global gateway delete        echo "Silently destroying any pre-existing gateway [$gateway]"
#        DestroyDomain $gateway $*

        echo "Creating Global Gateway on MS [$gateway]"
        manager "GLOBAL GATEWAY ADD $gateway $host_name" || return 1

        return 0
}

# -----------------------------------------------------------------------------
# CreateDomain - create a local domain and users
# silently destroy any pre-existing domain first

CreateDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        echo "Silently destroying any pre-existing domain [$domain]"
        MaybeDestroyDomain $domain $*

        echo "Creating local domain [$domain]"
        manager "DOMAIN ADD $domain NEW" || return 1

        while [ "$1" != "" ]
        do
                user=$1; shift
                echo "Creating user [$user] in local domain [$domain]"
                manager "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}$domain/$user" || return 1
                #manager "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}/$domain/$user" || return 1
        done

        return 0
}

# -----------------------------------------------------------------------------
# CreateDomain_MAA - create a local domain and and sets options on $maa_host_name
# silently destroy any pre-existing domain first

CreateDomain_MAA()  # <domain>
{
        local domain=$1; shift
        local cmd="$*"


        echo "Silently destroying any pre-existing domain [$domain]"
        MaybeDestroyDomain_MAA $domain

        echo "Creating domain [$domain]"
        managerMAA "DOMAIN ADD $domain NEW $cmd" || return 1


        return 0
}

# -----------------------------------------------------------------------------
# CreateDistDomain - create a distributed domain and users
# silently destroy any pre-existing domain first

CreateDistDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        echo "Silently destroying any pre-existing domain [$domain]"
        MaybeDestroyDistDomain $domain $*

        echo "Creating distributed domain [$domain]"
        manager "GLOBAL DOMAIN ADD $domain" || exit 1
        manager "DOMAIN ADD $domain NEW DSA=$dsaname" || exit 1
              

        while [ "$1" != "" ]
        do
                user=$1; shift
                echo "Creating user [$user] in distributed domain [$domain]"
                manager "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}$domain/$user" || return 1
                #manager "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}/$domain/$user" || return 1
        done

        return 0
}

# -----------------------------------------------------------------------------
# CreateDistDomain_Host2 - create a distributed domain and users on 2nd host
# silently destroy any pre-existing domain first

CreateDistDomain_Host2()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        echo "Silently destroying any pre-existing domain [$domain]"
        #MaybeDestroyDistDomain_Host2 $domain $*

        echo "Creating distributed domain [$domain]"
        manager2 "DOMAIN ADD $domain NEW DSA=$dsaname" || exit 1
              

        while [ "$1" != "" ]
        do
                user=$1; shift
                echo "Creating user [$user] in distributed domain [$domain]"
                manager2 "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}$domain/$user" || return 1
                #manager2 "USER $domain ADD $user NEW CPASS=$pass MAILBOX=${mailbox_path}/$domain/$user" || return 1
        done

        return 0
}

# -----------------------------------------------------------------------------
# CreateDistDomain_MAA - create a distributed domain on MAA

CreateDistDomain_MAA()  # <domain> [<user1>...]
{
        local domain=$1; shift

        echo "Creating distributed domain [$domain]"
        managerMAA "DOMAIN ADD $domain NEW DSA=$dsaname $cmd" || exit 1
              
        return 0
}

# -----------------------------------------------------------------------------
# DeleteDomain - delete a local domain and users

DeleteDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE" || return 1
        done

        manager "DOMAIN DELETE $domain" || return 1

        return 0
}

# -----------------------------------------------------------------------------
# DeleteDomain_MAA - delete a domain and users on $maa_host_name

DeleteDomain_MAA()  # <domain> [<user1>...]
{
        local domain=$1

        managerMAA "DOMAIN DELETE $domain" || return 1

        return 0
}

# -----------------------------------------------------------------------------
# DeleteDistDomain - delete a distributed domain and users

DeleteDistDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE" || return 1
        done

        manager "DOMAIN DELETE $domain" || return 1
  ###      manager "GLOBAL DOMAIN DELETE $domain"# >> /dev/null
	
	# Note: I don't want to return 1 on above command because this 
	# may or maynot pass, depends on the number of hostservers
	 
        return 0
}

# -----------------------------------------------------------------------------
# DeleteDistDomain_Host2 - delete a distributed domain and users on 2nd host

DeleteDistDomain_Host2()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager2 "USER $domain DELETE $user ERASE" || return 1
        done

        manager2 "DOMAIN DELETE $domain" || return 1
	manager2 "GLOBAL DOMAIN DELETE $domain" >> /dev/null	

	# Note: I don't want to return 1 on above command because this 
        # may or maynot pass, depends on the number of hostservers
        
        return 0
}

# -----------------------------------------------------------------------------
# DestroyDomain - silently destroy a local domain

MaybeDestroyDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

	manager "DOMAIN VERIFY $domain" | grep "* TRUE " || return

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE" >> /dev/null
        done

        manager "DOMAIN DELETE $domain" >> /dev/null

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDomain_MAA - silently destroy a local domain on $maa_host_name

MaybeDestroyDomain_MAA()  # <domain> [<user1>...]
{
        local domain=$1

	managerMAA "DOMAIN SHOW $domain" || return

        managerMAA "DOMAIN DELETE $domain" || return 1 

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDistDomain - silently destroy a distributed domain

MaybeDestroyDistDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

	manager "DOMAIN VERIFY $domain" | grep "* TRUE " || return

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE"
        done

        manager "DOMAIN DELETE $domain"
        ###manager "GLOBAL DOMAIN DELETE $domain"

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDistDomain_Host2 - silently destroy a distributed domain on 2nd host

MaybeDestroyDistDomain_Host2()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

	manager2 "DOMAIN VERIFY $domain" | grep "* TRUE " || return

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager2 "USER $domain DELETE $user ERASE"
        done

        manager2 "DOMAIN DELETE $domain"
	manager2 "GLOBAL DOMAIN DELETE $domain"
        
        return 0
}
# -----------------------------------------------------------------------------
# DestroyDomain - silently destroy a local domain

DestroyDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE" >> /dev/null
        done

        manager "DOMAIN DELETE $domain" >> /dev/null

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDomain_MAA - silently destroy a local domain on $maa_host_name

DestroyDomain_MAA()  # <domain> [<user1>...]
{
        local domain=$1

        managerMAA "DOMAIN DELETE $domain" >> /dev/null

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDistDomain - silently destroy a distributed domain

DestroyDistDomain()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager "USER $domain DELETE $user ERASE"
        done

        manager "DOMAIN DELETE $domain"
        ###manager "GLOBAL DOMAIN DELETE $domain"

        return 0
}

# -----------------------------------------------------------------------------
# DestroyDistDomain_Host2 - silently destroy a distributed domain on 2nd host

DestroyDistDomain_Host2()  # <domain> [<user1>...]
{
        local domain=$1; shift
        local user

        while [ "$1" != "" ]
        do
                user=$1; shift
                manager2 "USER $domain DELETE $user ERASE"
        done

        manager2 "DOMAIN DELETE $domain" 
	manager2 "GLOBAL DOMAIN DELETE $domain" 
        
        return 0
}

# -----------------------------------------------------------------------------
# wait long enough for MS to reload the registry settings

WaitReconfig()
{
        echo "Wait $reconfig_timer_sleep seconds for Registry Reconfig"
        sleep $reconfig_timer_sleep
}

# -----------------------------------------------------------------------------
# Searches recursively for a string - not quite working - almost though

RecursiveGrep() # <target> <grep-text>
{
        local target="$1"
        local greptext="$2"

        echo "Check if [$greptext] is in [$target]"
        X=`ssh -o BatchMode=yes root@$host_name find $target "\*" -exec grep -l "${greptext}" \{\} \\\;`
        echo "$X"
        grep "$greptext" "$X"

        if [ $? != 0 ]
        then
                echo "ERROR: Should have found [$greptext]"
                return 1
        fi

        echo "Great - found [$greptext]"
        return 0
}


# -----------------------------------------------------------------------------
# Checks to see if $grep-text is there

RemoteGrep() # <grep-text> <target> [<hostname>]
{
        local greptext="$1"
        local target="$2"
        local hostname="$3"
        
        if [ "$3" = "" ]; then hostname="$host_name"; fi

        echo "Check if [$greptext] is in [$target]"
        ssh -o BatchMode=yes root@$hostname grep $greptext $target
        if [ $? != 0 ]
        then
                echo "ERROR: Should have found [$greptext]"
                return 1
        fi

        echo "Great - found [$greptext]"
        return 0
}

# -----------------------------------------------------------------------------
# Checks to see if $grep-text is not there

RemoteGrep_NotFound() # <grep-text> <target> [<hostname>]
{
        local greptext="$1"
        local target="$2"
        local hostname="$3"
        
        if [ "$3" = "" ]; then hostname="$host_name"; fi

        echo "Check if [$greptext] is in [$target]"
        ssh -o BatchMode=yes root@$hostname grep $greptext $target
        if [ $? -eq 0 ]
        then
                echo "ERROR: Should not have found [$greptext]"
                return 1
        fi

        echo "Great - didn't find [$greptext]"
        return 0
}

# -----------------------------------------------------------------------------
# Checks to see if Server is running

Wait_For_Restart_MAA()
{
        local state="true"
        count=1

        echo "Make sure MAA box is restarted and ready for action"

        while [ $state = "true" ]
        do
                managerMAA "domain list" 
		if [ $? -eq 0 ]
                then
                        state="false"
                elif [ $? != 0 ]
                then
                        echo "SOFT ERROR: Server not ready - try again"
                        count=`expr $count + 1`
                        sleep 5
                                if [ $count -gt 10 ]
                                then
                                        echo "HARD ERROR - Problem - server not started after $count tries"
                                        return 1
                                fi
                fi

        done

        echo "Seems to be restarted after $count times - should be ready to go"
        sleep 1
        return 0
}

# -----------------------------------------------------------------------------

SecureCopy_MAA()   # <sourcefile> <target>
{
	local sourcefile="$1"
	local target="$2"
	
	local state="true"
        count=1
        
        echo "Copy $sourcefile to $target"
        
        while [ $state = "true" ]
        do
        	scp -i cproot-3.0 -o Port=2222 root@[$maa_host_name]:$sourcefile $target
		if [ $? -eq 0 ]
		then
			state="false"
		elif [ $? != 0 ]
		then
			echo "SOFT ERROR: Can't copy $sourcefile to $target"
		        count=`expr $count + 1`
                        sleep 1
                        	if [ $count -gt 3 ]
			        then
					echo "HARD ERROR - Couldn't copy - restart sever"
                                	return 1
                                fi
                fi
    	done
    	
    	echo "Copied $sourcefile to $target after $count tries"
    	
    	return 0
}
