#!/bin/bash

#functions list:

#function create_headerfiles()
#function end_time_tc()
#function imsanity_version()
#function prints()
#function set_color()
#function start_time_tc()
#function summary()
#function summary_imsanity()
#function clearfeplog ()
#function clearcore ()
#function GatherMXinfo()
#function printtestsuit()
#function welcome()


#get MXinfo
function GatherMXinfo(){
      set_color "6"
			echo "Gathering information required to run this Sanity tool."
			echo "Please wait....."
			echo
		  site_clust=$(cat $INTERMAIL/config/config.db | grep clusterName|grep -v imboxmaint | cut -d "/" -f2)
			Site=$(cat $INTERMAIL/config/config.db | grep clusterName|grep -v imboxmaint | cut -d "/" -f2 | cut -d "-" -f1)
		  Cluster=$(cat $INTERMAIL/config/config.db | grep clusterName|grep -v imboxmaint | cut -d "/" -f2 | cut -d "-" -f2)
		  Nginx=$(cat $INTERMAIL/config/config.db | grep -i messageStoreHosts | cut -d "[" -f2 | cut -d "]" -f1)
			MTAHostscounts=$(cat $INTERMAIL/config/config.db | grep -i mta_run|wc -l)
			MTAHosts=$(cat $INTERMAIL/config/config.db | grep -i mta_run | grep -i on |  cut -d "/" -f2)
			
			SMTPPort=$(cat $INTERMAIL/config/config.db | grep -i smtpport | grep -v ssl | grep -v outbound | cut -d "[" -f2 | cut -d "]" -f1|head -1 | tail -1)
			POPHost=$(cat $INTERMAIL/config/config.db | grep -i popserv_run | grep -i on |  cut -d "/" -f2 | tail -1)
			POPPort=$(cat $INTERMAIL/config/config.db | grep -i pop3port | grep -v ssl | cut -d "[" -f2 | cut -d "]" -f1 | head -1)
			IMAPHost=$(cat $INTERMAIL/config/config.db | grep -i imapserv_run | grep -i on | cut -d "/" -f2)
			IMAPPort=$(cat $INTERMAIL/config/config.db | grep -i imap4port | grep -v ssl | grep -v improxy | cut -d "[" -f2 | cut -d "]" -f1 | head -1)
			BackendType=$(imconfget hostInfo | cut -d "=" -f2 | cut -d ":" -f1)
			BackendCluster=$(imconfget hostInfo | cut -d "=" -f2 | cut -d ":" -f2)
			BackendPort=$(imconfget hostInfo | cut -d "=" -f2 | cut -d ":" -f3)
			RMEPort=$(cat $INTERMAIL/config/config.db | grep -i extrmeport| cut -d "[" -f2 | cut -d "]" -f1)
			extHost=$(cat $INTERMAIL/config/config.db | grep -i extserv_run | grep -i on | cut -d "/" -f2)
			#mxoshost_port=`imconfget mxOsServiceHost |grep default |awk '{print $2}'`
			#mxoshost=`imconfget mxOsServiceHost |grep default |awk '{print $2}'|awk -F ":" '{print $1}'`
			mxoshost=$(imconfget -server mxos|awk '{print $1}')
			mxosport=`imconfget mxOsServiceHost |grep default |awk '{print $2}'|awk -F ":" '{print $2}'`
			mxoshost_port=${mxoshost}:${mxosport}
			default_domain=$(imconfget -fullpath /*/imdirserv/defaultDomain |head -1)
			echo "=====================================MX INFO======================================"
			echo "|Site              ==> "$Site        
			echo "|MSS Cluster       ==> "$Cluster
			echo "|Nginx Host        ==> "$Nginx
			echo "|DB Used           ==> "$BackendType
			echo "|DB Cluster/Host   ==> "$BackendCluster
			echo "|DB Port           ==> "$BackendPort
			echo "|Default_Domain    ==> "${default_domain}
			echo > $summarylog
			echo "====================================MX INFO=======================================" >> $summarylog
			echo "|Site              ==> "$Site   >> $summarylog
			echo "|MSS Cluster       ==> "$Cluster >> $summarylog
			echo "|Nginx Host        ==> "$Nginx >> $summarylog
			echo "|DB Used           ==> "$BackendType >> $summarylog
			echo "|DB Cluster/Host   ==> "$BackendCluster >> $summarylog
			echo "|DB Port           ==> "$BackendPort >> $summarylog
			echo "|Default_Domain    ==> "${default_domain}  >> $summarylog
			#get mss info
			msshosts=`imconfget -fullpath /*/common/groupDefinition  |head -2|tail -1|awk -F : '{print $2}'`
			number2=`echo $msshosts|wc -w`
			#echo "########## number2=$number2" >>debug.log
			for (( i=1;i<=$number2;i++ ))
			do
			temp=`echo $msshosts|cut -d " " -f $i`
			echo "|MSS-$i             ==> "$temp
			echo "|MSS-$i             ==> "$temp >> $summarylog
			done
			for ((i=1;i<=${MTAHostscounts};i++))
			do
			  temp=$(echo $MTAHosts|cut -d " " -f $i)
				echo "|MTA Server-$i      ==> "$temp" Port ==> "$SMTPPort
				echo "|MTA Server-$i      ==> "$temp" Port ==> "$SMTPPort  >>$summarylog
			done
			MTAHost=$(echo $MTAHosts|cut -d " " -f 1)
			echo "|POP Server        ==> "$POPHost" Port ==> "$POPPort
			echo "|IMAP Server       ==> "$IMAPHost" Port ==> "$IMAPPort
			echo "|MXOS Server       ==> "$mxoshost" Port ==> "$mxosport
			echo "==================================MX INFO ends====================================="
			echo
			echo "|POP Server        ==> "$POPHost" Port ==> "$POPPort >> $summarylog
			echo "|IMAP Server       ==> "$IMAPHost" Port ==> "$IMAPPort >> $summarylog
			echo "|MXOS Server       ==> "$mxoshost" Port ==> "$mxosport >> $summarylog
			echo "===================================MX INFO ends====================================" >> $summarylog
}

function create_headerfiles(){
	echo "FROM:monkey1 <test2@${default_domain}>" > header1.tmp
	echo "TO:dog2 <test1@${default_domain}>" >> header1.tmp
	echo "Subject:test2 to test1" >> header1.tmp
	echo "This is messages from user test2 to test1.">> header1.tmp
	echo "FROM:cat0 <root@${default_domain}>" > header2.tmp
	echo "TO:6rabbit45 <test1@${default_domain}>" >> header2.tmp
	echo "Subject:root to test1" >> header2.tmp
	echo "This is messages from user root to test1.">> header2.tmp
	echo "FROM:23haha <abc@${default_domain}>" > header3.tmp
#	echo "TO:test1@${default_domain}" >> header3.tmp
#	echo "Subject:abc to test1" >> header3.tmp
	echo "This is messages from user abc to test1.">> header3.tmp
}
function end_time_tc() {
	
	t=$1
	arg1=$1
	interval_time_end_tc=$(date +\%s)
	echo "Test case $arg1 end at $interval_time_end_tc" >> Alltestcasestimetxt
	interval_time_total_tc=$(expr $interval_time_end_tc - $interval_time_start_tc)
	total_min_tc=60		
	interval_time_total_min_tc=$(echo "scale=2; $interval_time_total_tc / $total_min_tc" | bc)
	echo "===================================================================" >> $Alltestcasestimetxt
	echo "Time taken by test case $arg1 is $interval_time_total_min_tc Min" >> $Alltestcasestimetxt
	echo "===================================================================" >> $Alltestcasestimetxt
}
 
function imsanity_version() {
imsanity_version="5.0"
	set_color "6"
	echo "=======================================================================" 
	echo "IMSANITY TOOL VERSION $imsanity_version STARTED AT ====> "$starttime
	echo "======================================================================="
	set_color "0"
	interval_time_start=$(date +\%s)		
}
# It is used to print the output #
function prints() {
	string_to_print=$1
	test_case_name=$2
	colour=$3
	time=$(date '+%H:%M:%S')
			
	if [ "$colour"  == "1" ] 
	then
	set_color "1"
	elif [ "$colour"  == "2" ] 
	then
	set_color "2"
	elif [ "$colour"  == "3" ] 
	then
	set_color "3"
	elif [ "$colour"  == "4" ] 
	then
	set_color "4"
	elif [ "$colour"  == "5" ] 
	then
	set_color "5"
	elif [ "$colour"  == "6" ] 
	then
	set_color "6"
	else
	set_color "0"
	fi

	echo "$time [$test_case_name]: $string_to_print" 
	echo "$time [$test_case_name]: $string_to_print" >> debug.log
	set_color "0"
}
#!/bin/bash
function set_color(){
	color=$1
	if [ "$color" == "0" ]
	then
	tput sgr0 # Text reset
	fi
	if [ "$color" == "1" ]
	then
	tput setaf 1 # Red
	fi
	if [ "$color" == "2" ]
	then
	tput setaf 2 # green
	fi
	if [ "$color" == "3" ]
	then
	tput setaf 3 # yellow
	fi
	if [ "$color" == "4" ]
	then
	tput setaf 4 # blue
	fi
	if [ "$color" == "5" ]
	then
	tput setaf 5 # pink
	fi
	if [ "$color" == "6" ]
	then
	tput setaf 6 # light blue
	fi
}
# It tells about what time the test case started and finished executing #
function start_time_tc() {	
			
	#t=$1
	arg1=$(basename $(pwd))
	interval_time_start_tc=$(date +\%s) 
	echo " " >> $Alltestcasestimetxt
	echo " " >> $Alltestcasestimetxt
	echo "Test case $arg1 start at $interval_time_start_tc"  >> $Alltestcasestimetxt
}
function summary() {
		func_name=$1
		value=$2
		ITS_no=$3
		interval_time_end_tc=$(date +\%s)
		interval_time_total_tc=$(expr $interval_time_end_tc - $interval_time_start_tc)
		total_min_tc=60		
		interval_time_total_min_tc=$(echo "scale=2; $interval_time_total_tc / $total_min_tc" | bc)
		
		string_count=$(echo -n $func_name | wc -m)
		count=$((90-$string_count))
		

		if [ "$func_name" == "summary_imsanity_tc" ]
		then 
			echo " Total number of Test Cases : "$TotalTestCases >> $summarylog
			echo " PASS : "$Pass >> $summarylog
			echo " FAIL : "$Fail >> $summarylog 
		else
			if [ "$value" == "0" ]
			then
				printf "$func_name :-%"$count"s%s\n" "....................:" "[PASS] (Time Taken : $interval_time_total_tc Sec.)" >> summary.log
				Pass=$(($Pass+1))
				TotalTestCases=$(($TotalTestCases+1))
			else
				printf "$func_name :-%"$count"s%s\n" "....................:" "[FAIL] (Time Taken : $interval_time_total_tc Sec.) $ITS_no" >> summary.log
				Fail=$(($Fail+$value))
				TotalTestCases=$(($TotalTestCases+$value))
			fi
		fi
} 
function summary_imsanity() {
		echo
		echo
		prints "##############################################" "summary_imsanity" 
		prints "        SUMMARY OF THE IMSANITY TOOL          " "summary_imsanity" 
		prints " Refer sumamry.log file for Test cases result " "summary_imsanity" 
		prints "##############################################" "summary_imsanity" 
		#echo
		prints "FINDING CORES FILES..." "summary_imsanity" 
		prints "===========" "summary_imsanity" 
		#cat cores_found.txt
		#cat mta_cores_found.txt
		#cat pop_cores_found.txt
		#cat imap_cores_found.txt
		find $INTERMAIL/ -name "*core.*"
		#echo
		prints "FINDING ERRORS LOGS..." "summary_imsanity" 
		prints "===============" "summary_imsanity" 
		 
		echo "========== the content of error mta.log ==========" >> debug.log
		cat $INTERMAIL/log/mta.log | egrep -i "erro;|urgt;|fatl;" >> debug.log
		echo "==================================================" >> debug.log
		err_count=$(cat $INTERMAIL/log/mta.log | egrep -i "erro;|urgt;|fatl;" | wc -l)
		echo "########## err_count=$err_count" >>debug.log
		if [ "$err_count" -gt "0" ]	
		then
			prints "MTA ERRORS >>>" "summary_imsanity" "1"
			prints "Error found in mta.log. Please check debug.log" "smtp_operation" "1"
			prints "<<<" "summary_imsanity" "debug" "1"
		else
			prints "No Error found in mta.log." "smtp_operation" "2"
		fi
		echo "========== the content of error popserv.log ==========" >> debug.log
		cat $INTERMAIL/log/popserv.log | egrep -i "erro;|urgt;|fatl;" >> debug.log
		echo "======================================================" >> debug.log
		err_count=$(cat $INTERMAIL/log/popserv.log | egrep -i "erro;|urgt;|fatl;" | wc -l)
		echo "########## err_count=$err_count" >>debug.log
		if [ "$err_count" -gt "0" ]	
		then
			prints "POP ERRORS >>>" "summary_imsanity" "1"
			prints "Error found in popserv.log. Please check debug.log" "smtp_operation" "1"
			prints "<<<" "summary_imsanity" "debug" "1"
		else
			prints "No Error found in popserv.log." "smtp_operation" "2"
		fi
		echo "========== the content of error imapserv.log ==========" >> debug.log	
		cat $INTERMAIL/log/imapserv.log | egrep -i "erro;|urgt;|fatl;" >> debug.log
		echo "=======================================================" >> debug.log
		err_count=$(cat $INTERMAIL/log/imapserv.log | egrep -i "erro;|urgt;|fatl;" | wc -l)
		echo "########## err_count=$err_count" >>debug.log
		if [ "$err_count" -gt "0" ]	
		then
			prints "IMAP ERRORS >>>" "summary_imsanity" "1"
			prints "Error found in imapserv.log. Please check debug.log" "smtp_operation" "1"
			prints "<<<" "summary_imsanity" "debug" "1"
		else
			prints "No Error found in imapserv.log." "smtp_operation" "2"
		fi
		echo "========== the content of error mss.log ==========" >> debug.log
		cat $INTERMAIL/log/mss.log | egrep -i "erro;|urgt;|fatl;" | egrep -v "ClusterUnableToPingMSS|ProcWriteToStderr" >> debug.log
		echo "==================================================" >> debug.log
		err_count=$(cat $INTERMAIL/log/mss.log | egrep -i "erro;|urgt;|fatl;" | egrep -v "ClusterUnableToPingMSS|ProcWriteToStderr" | wc -l)
		echo "########## err_count=$err_count" >>debug.log
		if [ "$err_count" -gt "0" ]	
		then
			prints "MSS ERRORS >>>" "summary_imsanity" "1"
			prints "Error found in mss.log. Please check debug.log" "smtp_operation" "1"
			prints "<<<" "summary_imsanity" "debug" "1"
		else
			prints "No Error found in mss.log." "smtp_operation" "2"
		fi
		prints "NOTE:" "summary_imsanity" "6"
		prints "=====" "summary_imsanity" "6"
		prints "1. Please check cores and errors on other Mx hosts in this setup." "summary_imsanity" "6"
		#prints "2. This utility works only if atleast 2 MSS are there in the MSS Cluster." "summary_imsanity" "6"
		prints "2. Please refer sumamry.log file for Test cases result" "summary_imsanity" "6"
		prints "3. Please ignore the message \"-ERR no such message\" from the POP results. This occurs in an edge case and is expected." "summary_imsanity" "6"
		prints "##############################################" "summary_imsanity" "6"
		#echo
		prints "===============================================================" "summary_imsanity" "6"
		prints "IMSANITY TOOL COMPLETED AT ====> `date`" "summary_imsanity" "6"
		prints "===============================================================" "summary_imsanity" "6"
		interval_time_end=$(date +\%s)
		interval_time_total=$(expr $interval_time_end - $interval_time_start)
		total_min=60		
		interval_time_total_min=$(echo "scale=2; $interval_time_total / $total_min" | bc)
		prints "================================================================" >> summary.log
		prints "IMSANITY TOOL TOOK "$interval_time_total_min" MINUTE TO COMPLETE" >> summary.log
		prints "================================================================" >> summary.log
		prints "================================================================" "summary_imsanity" "6"
		prints "IMSANITY TOOL TOOK "$interval_time_total_min" MINUTE TO COMPLETE" "summary_imsanity" "6"
		prints "================================================================" "summary_imsanity" "6"
		#calling function for summary logs
		summary summary_imsanity_tc 0
		echo 
		echo
		cat $summarylog
		exit
}




#clear imapsrev.log ,popserv.log and mta.log
function clearfeplog (){
		echo "****************** clearing FEP logs ... ************************"                                                  
		> $INTERMAIL/log/imapserv.log
		> $INTERMAIL/log/popserv.log
		> $INTERMAIL/log/mta.log
		echo "******************** clear FEP logs finished ********************"
}


#clear core files
function clearcore (){
		echo "********************* clear core ... ************************"
		 for corefile in $(find $INTERMAIL/tmp  -name core.*)
		 do
		 	rm $corefile
		 done
		 echo "*********************** clear core finished *****************"
}



function printtestsuit(){
  type=$1
	currpath=$(pwd)
	testsuit=${currpath#/*Imsanity*/}
	length=$(echo -n $testsuit|wc -m)
	if [[ $type == 1 ]];then
	
		#show test suits name
		echo -e "\033[35m\n##############################################################################################################"
		echo -e "\033[35m\n##############################################################################################################" >>$debuglog
		echo -en "##################### $testsuit Test suit "
		echo -en "##################### $testsuit Test suit " >> $debuglog
		#output rest "##"
		let taillength=77-length
		for (( i=1;i<=$taillength;i++ ))
		do
				echo -n "#"
				echo -n "#" >>$debuglog
		done 
		echo 
		echo >> $debuglog
		echo -e "##############################################################################################################\033[0m\n"
		echo -e "##############################################################################################################\033[0m\n" >>$debuglog
  else
    echo -en "\033[34m\n======================= $testsuit Test "
		echo -en "\033[34m\n======================= $testsuit Test " >> $debuglog
		#output rest "##"
		let taillength=80-length
		for (( i=1;i<=$taillength;i++ ))
		do
				echo -n "="
				echo -n "=" >>$debuglog
		done 
		echo -e "\033[0m\n\n">> $debuglog
		echo -e "\033[0m\n"
	fi
}

function welcome(){

		echo -e "\033[35m====================================================="
		echo "====================================================="
		echo "||      Imsanity Test Suits for MX9.X              ||"
		echo "||                     By:Dev and QA               ||"
		echo "====================================================="
		echo -e "=====================================================\033[0m"		
		echo
		set_color "1"
		echo "Before starting Imsanity, all your servers should be up."
		echo "Please check all points are mounted"
		echo "Please clear the logs and clean the cores before starting Imsanity"
		set_color "0"

}
