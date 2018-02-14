#!/bin/bash

#Utilities functions list
#function account_create_fn() 
#function account_delete_fn() 
#function imboxstats_fn ()
#function immsgdelete_utility() 
#function immssdescms_utility() 
#function imfolderlist_utility() 
#function immsgdump_utility() 
#function immsgfind_utility() 
#function immsgtrace_utility() 
#function imboxattctrl_utility() 
#function imboxtest_utility() 
#function imcheckfq_utility() 
#function imboxmaint_fn()

function account_create_fn() {
	
	start_time_tc account_create_fn_tc
	user_name=$1
	cosname=$2
	if [[ $cosname == "" ]];then
			cosname=default
	fi
	MBXID_user_name=$(echo $RANDOM)
	MBXID_user_name=`echo $MBXID_user_name | tr -d " "`
	account-create $user_name@${default_domain} $user_name $cosname -mboxid $MBXID_user_name &> log_account_create.tmp
	#cat log_account_create.tmp
	echo "========== the content of log_account_create.tmp ==========" >>debug.log
	cat log_account_create.tmp >>debug.log
	echo "===========================================================" >>debug.log
	count_create_mailbox_success=$(cat log_account_create.tmp | grep -i Created |wc -l)
	count_create_mailbox_success1=$(cat log_account_create.tmp | grep -i MailboxId | wc -l)
	count_create_mailbox_failure=$(cat log_account_create.tmp | grep -i ERROR | wc -l)
	echo "########## count_create_mailbox_success =$count_create_mailbox_success" >>debug.log
	echo "########## count_create_mailbox_success1=$count_create_mailbox_success1" >>debug.log
	if [[ "$count_create_mailbox_success" == "1" && "$count_create_mailbox_success1" == "1" ]] 
	then 
		prints "Mailbox for $user_name with mailbox id $MBXID_user_name is created successfully" "account_create_fn" "2"
		Result="0"
	elif [ "$count_create_mailbox_failure" == "1" ]
	then
		prints "Mailbox for $user_name is not created" "account_create_fn" "1"
		Result="1"
	fi
	
}
function account_delete_fn() {
	user_name=$1
	account-delete $user_name@${default_domain} &> log_account_delete.tmp
  #cat log_account_delete.tmp
  echo "=========== the contentt of log_account_delete.tmp ==========" >>debug.log
  cat log_account_delete.tmp >>debug.log
  echo "=============================================================" >>debug.log
	count_delete_mailbox_success=$(cat log_account_delete.tmp | grep -i Deleted | wc -l)
	count_delete_mailbox_success=`echo $count_delete_mailbox_success | tr -d " "` 
	
	count_delete_mailbox_failure=$(cat log_account_delete.tmp | grep -i ERROR | wc -l)
	count_delete_mailbox_failure=`echo $count_delete_mailbox_failure | tr -d " "` 
	if [[ "$count_delete_mailbox_success" == "1" && "$count_delete_mailbox_failure" == "0" ]]
	then
		prints "Mailbox $user_name is deleted successfully" "account_delete_fn" "2"
		Result="0"
	else 
		prints "Mailbox $user_name is not deleted" "account_delete_fn" "1"
		Result="1"
	fi
}
function imboxstats_fn (){
	user_name=$1
	imboxstats $user_name@${default_domain} &> log_imboxstats.tmp
	echo "========== thecontent of  log_imboxstats.tmp ==========" >>debug.log
	cat log_imboxstats.tmp >> debug.log 
	echo "=======================================================" >>debug.log
	imboxstats_result_success=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" |wc -l)
	imboxstats_result_success=`echo $imboxstats_result_success | tr -d " "` 
	
	imboxstats_result_failure=$(cat log_imboxstats.tmp | grep -i ERROR | wc -l)
	imboxstats_result_failure=`echo $imboxstats_result_failure | tr -d " "` 
  echo "########## imboxstats_result_success=$imboxstats_result_success" >>debug.log
  echo "########## imboxstats_result_failure =$imboxstats_result_failure" >>debug.log 
	if [[ "$imboxstats_result_success" == "1" && "$imboxstats_result_failure" == "0" ]] 
	then
		prints "imboxstats for user $user_name is successful" "imboxstats_fn" "2"
		Result=0
	else
		prints "imboxstats for user $user_name is failed" "imboxstats_fn" "1"
		Result=1
	fi
}
function immsgdelete_utility() {
	
	#start_time_tc immsgdelete_utility_tc
	user_name=$1
	option=$2
	
	imboxstats_fn "$user_name" 
	msg_msgdel1=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
	msg_msgdel1=`echo $msg_msgdel1 | tr -d " "`
	prints "Currently "$msg_msgdel1" messages are stored in the mailbox" "immsgdelete_utility" 
	immsgdelete $user_name@${default_domain} $option  >log_immsgdelete.tmp
	#cat log_immsgdelete.tmp
	echo "========== the content of log_immsgdelete.tmp =========="  >>debug.log
	cat log_immsgdelete.tmp >> debug.log
	echo "========================================================"  >>debug.log
	
	imboxstats_fn "$user_name"  
	msg_msgdel2=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
	msg_msgdel2=`echo $msg_msgdel2 | tr -d " "`
	echo "########## msg_msgdel2=$msg_msgdel2"  >>debug.log
	if [ "$msg_msgdel2" == "0" ]
	then
		prints "Currently "$msg_msgdel2" messages are stored in the mailbox" "immsgdelete_utility" "2"
		prints "immsgdelete utility is successful" "immsgdelete_utility" "2"
		Result="0"
	else
		prints "ERROR: Currently "$msg_msgdel2" messages are stored in the mailbox" "immsgdelete_utility" "1"
		prints "ERROR: immsgdelete utility is not successful.Please check Manually." "immsgdelete_utility" "1"
		Result="1"
	fi 
}	
function immssdescms_utility() {
	#start_time_tc immssdescms_utility_tc
	user_name=$1	
	imboxstats_fn "$user_name" 
	msg_exists=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
	msg_exists=`echo $msg_exists | tr -d " "`
	
	year=$(date +%Y)
	month=$(date +%b)
	immssdescms $user_name@${default_domain} > log_immssdescms.tmp
	echo "========== the content of log_immssdescms.tmp =========="  >>debug.log
	cat log_immssdescms.tmp >>debug.log
	echo "========================================================"  >>debug.log
	
	msgid=$(cat log_immssdescms.tmp | egrep -i "Message ID" | wc -l)
	msgid=`echo $msgid | tr -d " "`
	msartime_yr=$(cat log_immssdescms.tmp | egrep -i "MSSArrivalTime" | grep -i "$year" | wc -l)
	msartime_yr=`echo $msartime_yr | tr -d " "`
	msartime_mon=$(cat log_immssdescms.tmp | egrep -i "MSSArrivalTime" | grep -i "$month" | wc -l)
	msartime_mon=`echo $msartime_mon | tr -d " "`
	mbxartime_yr=$(cat log_immssdescms.tmp | egrep -i "MailboxArrivalTime" | grep -i "$year" | wc -l)
	mbxartime_yr=`echo $mbxartime_yr | tr -d " "`
	mbxartime_mon=$(cat log_immssdescms.tmp | egrep -i "MailboxArrivalTime" | grep -i "$month" | wc -l)
	mbxartime_mon=`echo $mbxartime_mon | tr -d " "`
	echo "########## msgid=$msgid"  >>debug.log
	echo "########## msg_exists=$msg_exists"  >>debug.log
	echo "########## msartime_yr=$msartime_yr"  >>debug.log
	echo "########## msartime_mon=$msartime_mon"  >>debug.log
	echo "########## mbxartime_mon=$mbxartime_mon"  >>debug.log
	if [ "$msgid" == "$msg_exists" ]
	then
		if [ "$msartime_yr" == "$msg_exists" ]
		then
			if [ "$msartime_mon" == "$msg_exists" ]
			then
				if [ "$mbxartime_yr" == "$msg_exists" ]
				then
					if [ "$mbxartime_mon" == "$msg_exists" ]
					then
						Result="0"
						prints "imssdescms utility is working fine." "immssdescms_utility" "2"
					else
						Result="1"
						prints "ERROR: mailbox arrival time is not correct" "immssdescms_utility" "1"
					fi
				else
					Result="1"
					prints "ERROR: mailbox arrival time is not correct" "immssdescms_utility" "1"
				fi
			else
				Result="1"
				prints "ERROR: message arrival time is not correct" "immssdescms_utility" "1"
			fi
		else
			Result="1"
			prints "ERROR: message arrival time is not correct" "immssdescms_utility" "1"
		fi
	else
		Result="1"
		prints "ERROR: Number of Messages are not correct" "immssdescms_utility" "1"
	fi
		
}
function imfolderlist_utility() {
	#start_time_tc imfolderlist_utility_tc
	user_name=$1
	
	imboxstats_fn "$user_name" 

	msg_exists=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
	msg_exists=`echo $msg_exists | tr -d " "`
	
	imfolderlist $user_name@${default_domain} -folder INBOX > log_folderlist.tmp
	echo "========== the content of log_folderlist.tmp =========="  >>debug.log
	cat log_folderlist.tmp >> debug.log
	echo "======================================================="  >>debug.log
	msgs_fldr=$(cat log_folderlist.tmp | grep -i "Message-Id" | wc -l)
	msgs_fldr=`echo $msgs_fldr | tr -d " "`
	echo "########## msgs_fldr=$msgs_fldr"  >>debug.log
	echo "########## msg_exists=$msg_exists" >>debug.log
	if [ "$msgs_fldr" == "$msg_exists" ]
	then
		prints "imfolderlist utility is working fine." "imfolderlist_utility" "2"
		Result="0"
	else
		prints "ERROR: imfolderlist utility is not showing proper results." "imfolderlist_utility" "1"
		Result="1"
	fi
}
function immsgdump_utility() {
	#start_time_tc immsgdump_utility_tc
	user_name=$1
	msg_no=$2
	uidstart="100"
	uidno==$uidstart$msg_no
	
	immsgdump $user_name@${default_domain} $msg_no  > log_immsgdump.tmp
	echo "========== the content of log_immsgdump.tmp ==========" >>debug.log
	cat log_immsgdump.tmp >>debug.log
	echo "======================================================" >>debug.log
	check_msgfind=$(cat log_immsgdump.tmp | wc -l)
	check_msgfind=$(echo $check_msgfind | tr -d " ")
	verify_msgfind=$(cat log_immsgdump.tmp | grep -i UID=$uidno | wc -l)
	verify_msgfind=$(echo $verify_msgfind | tr -d " ")
	echo "########## check_msgfind=$check_msgfind" >>debug.log
	echo "########## verify_msgfind=$verify_msgfind"  >>debug.log
	if [[ "$check_msgfind" > "1" || "$verify_msgfind" == "1" ]]
	then
		prints "immsgdump utility is working fine" "immsgdump_utility" "2"
		Result="0"
	else
		prints "ERROR: immsgdump utility output is not correct. Please check manually." "immsgdump_utility" "1"
		Result="1"
	fi
}
function immsgfind_utility() {
	#start_time_tc immsgfind_utility_tc
	
	user_name=$1	
	mail_send "$user_name" "small" "2"
	immssdescms $user_name@${default_domain} > descms_Sanity.tmp
	msg_id=$(cat descms_Sanity.tmp | grep -i "Message ID" | cut -d " " -f2 | cut -d "=" -f2 | head -1)
	msg_id=`echo $msg_id | tr -d " "`
	
	immsgfind $user_name@${default_domain} "$msg_id" "/Inbox" > log_immsgfind.tmp
	echo "========== the content of log_immsgfind.tmp ==========" >>debug.log
	cat log_immsgfind.tmp >> debug.log
	echo "======================================================"  >>debug.log
	chk_msg_id=$(cat log_immsgfind.tmp | egrep -i "MESSAGE-ID" | wc -l)
	chk_msg_id=`echo $chk_msg_id | tr -d " "`
	echo "########## chk_msg_id=$chk_msg_id" >>debug.log
	if [ "$chk_msg_id" == "1" ]
	then
		prints "immsgfind utility is working fine" "immsgfind_utility" "2"
		Result="0"
	else
		prints "ERROR: immsgfind utility output is not correct. Please check Manually." "immsgfind_utility" "1"
		Result="1"
	fi
	
}
function immsgtrace_utility() {
	#start_time_tc immsgtrace_utility_tc
	
	user_name=$1					
	immsgtrace -to $user_name -size 2 > log_msgtrace.tmp				
	echo "========== the content of log_msgtrace.tmp	==========" >>debug.log
	cat log_msgtrace.tmp	 >>debug.log
	echo "======================================================" >>debug.log
	msg_count1=$(cat log_msgtrace.tmp | grep "sending message" | wc -l)
	msg_count1=`echo $msg_count1 | tr -d " "`			
	echo "########## msg_count1=$msg_count1" >>debug.log
	if [ "$msg_count1" == "1" ]
	then
		prints " immsgtrace is working fine." "immsgtrace_utility" "2"
		Result="0"
	else
		prints " immsgtrace is not working fine. Please check manually" "immsgtrace_utility" "1"
		Result="1"
	fi
		
}
function imboxattctrl_utility() {
	start_time_tc imboxattctrl_utility_tc
	
	user_name=$1	
	type_att=$2
	imboxattrctrl > automsg
	
	imboxattrctrl set $type_att $user_name ${default_domain} automsg > log_imboxatt.tmp
	echo "========== the content of log_imboxatt.tmp ==========" >>debug.log
	cat log_imboxatt.tmp >>debug.log
	echo "=====================================================" >>debug.log
	check_setattr=$(cat log_imboxatt.tmp | grep -i "1" | wc -l )
	check_setattr=`echo $check_setattr | tr -d " "`
	prints "We have set "$check_setattr" auto reply for the user $user_name" "imboxattctrl_utility" 
	
	imboxattrctrl get $type_att $user_name ${default_domain} > log_imboxatt_1.tmp
	echo "========== the content of  log_imboxatt_1.tmp ==========" >>debug.log
	cat  log_imboxatt_1.tmp >>debug.log
	echo "========================================================" >>debug.log
	check_getattr=$(cat log_imboxatt_1.tmp | grep -i "1" | head -1 | wc -l)
	check_getattr=`echo $check_getattr | tr -d " "`
	prints "We have got "$check_getattr" auto reply for the user $user_name" "imboxattctrl_utility" 
	echo "########## check_setattr=$check_setattr" >>debug.log
	echo "########## check_getattr=$check_getattr" >>debug.log
	if [[ "$check_setattr" == "1" && "$check_getattr" == "1" ]]
	then
		prints "imboxattrctrl utility is working fine" "imboxattctrl_utility" "2"
		Result="0"
	else
		prints "ERROR: imboxattrctrl utility is not working fine. Please check Manually." "imboxattctrl_utility" "1"
		Result="1"
	fi
		
}
function imboxtest_utility() {
	#start_time_tc imboxtest_utility_tc
	user_name=$1	
	
	imboxtest $POPHost $user_name $user_name > log_imboxtest.tmp
	echo "========== the content of log_imboxtest.tmp ==========" >>debug.log
	cat log_imboxtest.tmp >>debug.log
	echo "======================================================"  >>debug.log
	error_cnt=$(cat log_imboxtest.tmp | grep -i "ERR" | wc -l)
	error_cnt=`echo $error_cnt | tr -d " "`
	
  echo "########## error_cnt=$error_cnt" >>debug.log
	if [ "$error_cnt" == "0" ]
	then
		prints "imboxtest utility is working fine." "imboxtest_utility" "2"
		Result="0"
	else
		prints "ERROR: imboxtest utility is not showing proper results." "imboxtest_utility" "1"
		Result="1"
	fi
}
function imcheckfq_utility() {
	#start_time_tc imcheckfq_utility_tc
	
	user_name=$1
	imdbcontrol SetCosAttribute default mailFolderQuota '/ all,AgeSeconds,1'
	
	imcheckfq -u $user_name@${default_domain} > log_imcheckfq.tmp
	echo "========== the content of log_imcheckfq.tmp ==========" >>debug.log
	cat log_imcheckfq.tmp >>debug.log
	echo "======================================================" >>debug.log
	check_imcheckfq=$(cat log_imcheckfq.tmp | grep -i "AgeSeconds" | wc -l)
	check_imcheckfq=`echo $check_imcheckfq | tr -d " "`
	echo "########## check_imcheckfq=$check_imcheckfq" >>debug.log
	if [ "$check_imcheckfq" == "1" ]
	then
		prints "Imcheckfq utility is working fine" "imcheckfq_utility" "2"
		Result="0"
	else
		prints "ERROR: Imcheckfq utility is not working fine. Please check Manually." "imcheckfq_utility" "1"
		Result="1"
	fi
	
}

function imboxmaint_fn(){
		maint_user=$1
		#imboxmaint $maint_user  &>imboxmaints.tmp
		#cat imboxmaints.tmp
		#out=`grep "MsLoadedByOtherMSS"   imboxmaints.tmp |wc -l `
		out=1
		while [[ $out != 0 ]]
		do
				echo -en "\n\033[35m########## Running imboxmaint ########## \033[0m\n\n"
				echo -en "\n\033[35m########## Running imboxmaint ########## \033[0m\n\n" >>debug.log
				#sleep 2
				#set Cluster key
				set_config_keys "/*/imboxmaint/clusterName" "$Cluster"
				sleep 2
				imboxmaint $maint_user  &>imboxmaints.tmp 
				echo "========== the content of imboxmaints.tmp ==========" >>debug.log
				cat imboxmaints.tmp >>debug.log
				echo "====================================================" >>debug.log
				out=`grep "MsLoadedByOtherMSS"   imboxmaints.tmp |wc -l `
		done
		
		prints  "Imboxmaint runs successfully!!!!"	  "imboxmaint_fn"  2
}