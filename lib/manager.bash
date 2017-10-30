
# source this script to make its functions available

# Requires:
#  perl/manager.pl

#
# Function: manager()
#
# Usage:
#	manager <command> [readonly]
# Example:
#	manager "SET VerifyAuthenticOriginator 1" || exit 1
#


manager()
{
  echo "About to issue '$1' '$2' on '$host_name'"

  #perl/manager.pl $host_name $man_smtp_port $man_smtp_pass "$1" "$2"
  manager.pl $host_name $man_smtp_port $man_smtp_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi

  return 0
}

managerMAA()
{
#  echo "About to issue '$1' '$2' on '$maa_host_name'"

  #perl/manager.pl $maa_host_name $maamgmt_port $maamgmt_pass "$1" "$2"
  manager.pl $maa_host_name $maamgmt_port $maamgmt_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi
#	echo "Command completed successfully: \"$*\""
  return 0
}

managerMAARelayhost()
{
#  echo "About to issue '$1' '$2' on '$maa_relayhost1'"

  #perl/manager.pl $maa_relayhost1 $maamgmt_port $maamgmt_pass "$1" "$2"
  manager.pl $maa_relayhost1 $maamgmt_port $maamgmt_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi

  return 0
}

managerI()
{
  echo "About to issue '$1' '$2' on IMSD '$host_name'"

  #perl/manager.pl $host_name $man_ims_port $man_ims_pass "$1" "$2"
  manager.pl $host_name $man_ims_port $man_ims_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi

  return 0
}

manager2()
{
  echo "About to issue '$1' '$2' on '$host_name2'"

  #perl/manager.pl $host_name2 $man_smtp_port $man_smtp_pass "$1" "$2"
  manager.pl $host_name2 $man_smtp_port $man_smtp_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi

  return 0
}

managerR()
{
  echo "About to issue '$1' '$2' on relay '$relay_name'"

  #perl/manager.pl $relay_name $man_relay_port $man_relay_pass "$1" "$2"
  manager.pl $relay_name $man_relay_port $man_relay_pass "$1" "$2"
  if [ $? -ne 0 ]; then
        echo "Failed to '$1'"
        return 1
  fi

  return 0
}


#
# Function: MgrSession()
#
# Usage:
#	MgrSession [ -host <host> <port> <pass> ] <list-of-commands-and-expected-responses>
#   see perl/mgrSession.pl for details
# Example:
#	MgrSession "DOMAIN ADD test.com; ==OK; DOMAIN ADD test.com NEW; =ERROR"
#

MgrSession()
{
	local host=$host_name
	local port=$man_smtp_port
	local pass=$man_smtp_pass
	local cmds="$*"
	
	if [ "$1" = "-host" ]
	then
		host="$2"
		port="$3"
		pass="$4"
		shift 4
		cmds="$*"
		echo "Running a MgrSession on host[$host] port[$port]"
	else
		echo "Running a MgrSession on default host[$host] port[$port]"
	fi
	
	#perl/mgrSession.pl $host $port $pass "$cmds"
	mgrSession.pl $host $port $pass "$cmds"
}
