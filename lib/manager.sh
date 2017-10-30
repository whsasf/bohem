#!/bin/bash

dir=`dirname $0`

get_mosmgr()
{
    MOSMGR=`which mosfsmanager.sh 2>&1`
    if [ ! $? -eq 0 ]; then
        if [ -f /usr/local/mosfsmanager/mosfsmanager.sh ]; then
            MOSMGR=/usr/local/mosfsmanager/mosfsmanager.sh
        else
            MOSMGR=$dir/mosfsmanager.sh
        fi
    else
        MOSMGR=mosfsmanager.sh
    fi
     
}

get_manager_pl()
{
    MGRPL=`which manager.pl 2>&1`
    if [ ! $? -eq 0 ]; then
        MGRPL=$dir/manager.pl
    else
        MGRPL=manager.pl
    fi
}

if [ "$MOS_ENV" = "YES" ]; then

    # Resolve actual hostname to use

    if [ "$1" = "use.as.placeholder" ]; then

        # Looks like a command for MOS

        # Skip host and port parameters

        shift
        shift

        if [ "$MOS_PORT" = "" ] ;then
            port=8081
        else
            port=$MOS_PORT
        fi

        get_mosmgr

#        echo "$MOSMGR $MOS_HOST $port $1 \"$2\" $3"
        $MOSMGR $MOS_HOST $port $1 "$2" $3

        exit $?
    fi
fi

# It seems to be a genuine telnet command

get_manager_pl

#echo "$MGRPL $1 $2 $3 \"$4\" $5"
$MGRPL $1 $2 $3 "$4" $5
exit $?

