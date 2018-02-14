#!/bin/bash

#functions list
##COS related functions
#function create_cos () 
#function delete_cos() 
#function show_defaultcos () 
#function set_cos() 
##SMTP related #functions
#function mail_send()  
#function mail_send_thread()
#function large_message_send()
#function no_flag_msg() 
##IMAP related #functions
#function imap_fetch()
#function imap_invalid_tag()
#function imap_uid_fetch()
#function imap_login()
#function imap_logout()
#function imap_list()
#function imap_examine()
#function imap_capability() 
#function imap_status() 
#function imap_select()
#function imap_create()
#function imap_uid_check ()
#function imap_idle() 
#function imap_getquota_root() 
#function imap_noop()
#function imap_check()
#function imap_close()
#function imap_delete()
#function imap_append()
#function imap_copy()
#function imap_rename()
#function imap_move()
#function imap_store()
#function imap_sort() 
#function imap_search()
#function imap_thread()
#function imap_expunge()
#function uid_x-thread_utf8_all()
#function uid_x-thread_store_flags_Seen()
#function uid_x-thread_list_utf8_all()
##POP related #functions#
#function pop_retrieve()
#function pop_login()
#function pop_list()
#function pop_uidl()                                                                                                            
#function POP_quit_before_login()                                                                                                                                                                                                  
#function POP_quit_after_login()                                                                                                                                                                                 
#function pop_delete()                                                                                                                                                              
#function pop_stat()                                                                                                                                                                                           
##folderhare and unshare #functions,added begin MX9.5
#function shareFolder()
#function unshareFolder()
##LDAP test #functions
#function ldap_add_test() 
#function ldap_search_utilty() 
#function ldap_modify_utility() 
#function ldap_delete_utility() 
##logging enhancement #functions
#function logging_enhancement_test()
##special delete
#function special_delete_config_keys()
#function special_delete_case_pop() 
#function special_delete_case_imap() 
##alias #functions
#function create_alias () 
#function delete_alias () 
##remote foreard #function
#function create_remote_fwd () 
#function list_remote_fwd() 
#function delete_remote_fwd () 
#function create_domain()

#function invalid_keyvalue_msslog_imap() 
#function invalid_keyvalue_msslog_pop() 
#function account_mode_M() 
		
		
#COS related functions
#"##################COS related functions######################"
function create_cos () {
		#start_time_tc create_cos_tc
		cosname=$1
		#imdbcontrol CreateCos bogus >> debug.log
		#there is a reason why not use imdbcontrol to create cos :imdbcontrol showcos and not show cos created using imdbcontrol
		curl -s -X PUT -H "Content-Type: application/x-www-form-urlencoded" "http://${mxoshost}:${mxosport}/mxos/cos/v2/$cosname" >createcos.tmp
		echo "========== the content of createcos.tmp ==========" >>debug.log
		cat  createcos.tmp  >>debug.log
		echo "==================================================" >>debug.log
		newcos_name=$(imdbcontrol ListCosNames | grep $cosname | wc -l)
		echo "########## newcos_name=$newcos_name" >> debug.log
		if [ "$newcos_name" == "1" ]
		then
			prints "Created COS $cosname successfully" "create_cos" "2"
			Result="0"
		else
			prints "ERROR:Not able to create COS $cosname. Please check manually." "create_cos" "1"
			Result="1"
		fi
		echo "########## Result=$Result"  >> debug.log
		#if newly created cos has mailrealm attributes, need add realm in config.db
		imdbcontrol showcos $cosname|grep mailrealm >showcos.tmp
		showcoscount=`grep mailrealm showcos.tmp|wc -l`
		echo "========== the content of showcos.tmp ==========" >>debug.log
		cat showcos.tmp  >>debug.log
		echo "================================================" >>debug.log
		echo "########## showcoscount=$showcoscount"  >> debug.log
		if [ $showcoscount -eq 1 ];then
		  set_config_keys "/*/mss/realmsLocal"  "realm"  "1"
		else
		  set_config_keys "/*/mss/realmsLocal"  ""  "1"
		fi
}

function delete_cos() {
	#start_time_tc TC_delete_cos_tc
	deletecosname=$1
	imdbcontrol DeleteCos bogus > deletecos.tmp
	echo "========== the content of deletecos.tmp ==========" >>debug.log
	cat deletecos.tmp >>debug.log
	echo "==================================================" >>debug.log
	deletecos_name=$(imdbcontrol ListCosNames | grep "bogus" | wc -l)
	echo "########## deletecos_name=$deletecos_name"  >> debug.log
	if [ "$deletecos_name" == "0" ]
	then
		prints "COS $deletecosname is deleted successfully" "TC_delete_cos" "2"
		Result="0"
	else
		prints "ERROR:Not able to delete COS $deletecosname. Please check manually." "TC_delete_cos" "1"
		Result="1"
	fi
}

function show_defaultcos () {
    #start_time_tc TC_show_cos_tc
				
	show_cosname=$(imdbcontrol ShowCos default | wc -l)
	echo "########## show_cosname=$show_cosname" >>debug.log
	if [ $show_cosname -gt 110 ]
	then
		prints "'Default' COS is shown successfully"  "TC_show_defaultcos" "2"
		Result="0"
	else
		prints "ERROR:Not able to see default COS. Please check manually." "TC_show_defaultcos" "1"
		Result="1"
	fi
	
}

function set_cos() {
	#start_time_tc set_cos_tc
	
	user_name=$1
	cos_attribute_name=$2
	cos_value=$3
	
	imdbcontrol SetAccountCos $user_name ${default_domain} $cos_attribute_name $cos_value &> sac.tmp
	echo "========== the content of sac.tmp ==========" >>debug.log
	cat sac.tmp >>debug.log
	echo "============================================" >>debug.log
	
	imdbcontrol gaf $user_name ${default_domain}  &> gaf.tmp
	echo "========== the content of gaf.tmp ==========" >>debug.log
	cat gaf.tmp >>debug.log
	echo "============================================" >>debug.log
	check_cosadded=$(cat gaf.tmp | grep -i $cos_attribute_name | cut -d ":" -f1)
	check_cosadded=`echo $check_cosadded | tr -d " "`
	
	check_valueadded=$(cat gaf.tmp | grep -i $cos_attribute_name | cut -d ":" -f2 )
	check_valueadded=`echo $check_valueadded | tr -d " "`
	echo "########## check_cosadded=$check_cosadded" >>debug.log
	echo "########## check_valueadded=$check_valueadded" >>debug.log
	if [[ "$check_cosadded" == "$cos_attribute_name" && "$check_valueadded" == "$cos_value" ]]
	then
		prints "Cos $cos_attribute_name for $user_name is set successfully" "set_cos" "2"
		Result="0"
	else
		prints "Cos $cos_attribute_name for $user_name is not set" "set_cos" "1"
		prints "ERROR: Please check Manually." "set_cos" "1"
		Result="1"
	fi
}

# "##################SMTP related functions######################"
#SMTP related functions  
function mail_send() { 

#mail_send "test1" "small" "2"
				
		user_mail=$1
		mail_size=$2
		mail_count=$3
		
		imboxstats_fn "$user_mail" 
		check_msgcount=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
		check_msgcount=`echo $check_msgcount | tr -d " "`
		prints "Message count for $user_mail at start is $check_msgcount " "imboxstats_fn" 
		#Information related to SMTP session			
		SUBJECT="Sanity Test"
		user_mail_name=$(whoami)
		MAILFROM=`imdbcontrol la | grep -i @ | grep -i $user_mail_name | cut -d ":" -f2 | cut -d "@" -f1`
		MAILFROM=`echo $MAILFROM | tr -d " "`
		
			
		if [ "$mail_size" == "small" ]
		then
				DATA="Test message for Sanity Tool"
		  	msgdata_size=`echo $DATA | wc -c`
		elif [ "$mail_size" == "large" ]
		then
				ls -lrtR $INTERMAIL/ > large_msg
				#cat large_msg >>debug.log
				#DATA=`cat 10MB`
		    DATA=`cat large_msg`
				msgdata_size=`ls -al large_msg | cut -d " " -f5`    
				#msgdata_size=`ls -al 10MB | cut -d " " -f5`
		fi
		msgdata_size=`echo $msgdata_size | tr -d " "`	
		echo "########## msgdata_size=$msgdata_size" >>debug.log
		c="1"
		exec 3<>/dev/tcp/$MTAHost/$SMTPPort
			
		while [ $c -le $mail_count ]  
		do  
		    echo "sending message..."
		    echo "sending message..." >>debug.log
				echo -en "MAIL FROM:$MAILFROM\r\n" >&3
				echo -en "RCPT TO:$user_mail\r\n" >&3
				echo -en "DATA\r\n" >&3
				echo -en "Subject: $SUBJECT\r\n\r\n" >&3
				echo -en "$DATA\r\n" >&3
				echo -en ".\r\n" >&3
				(( c++ ))
		done
		echo -en "QUIT\r\n" >&3
		cat <&3 > sendmsg.tmp
		echo "========== the content of sendmsg.tmp ==========" >>debug.log
		cat sendmsg.tmp >>debug.log
		echo "================================================" >>debug.log
		#imboxstats_fn "$user_mail" 
		if [ ! -n "$4" ]
		then
			password=$user_mail
			loginaccount=$user_mail
			imap_select $loginaccount
			new_check_msgcount=$(grep -i "EXISTS" imapselect.tmp |awk '{print $2}'|tr -d " ")
		else
		  loginaccount=$user_mail@${default_domain}
		  password=$4
		  imap_select $loginaccount INBOX $password
		  new_check_msgcount=$(grep -i "EXISTS" imapselect.tmp |awk '{print $2}'|tr -d " ")
		fi
		
		#new_check_msgcount=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
		#new_check_msgcount=`echo $new_check_msgcount | tr -d " "`
		
		total_msgcount=$(($check_msgcount+$mail_count))
		prints "Message count for $user_mail after sending $mail_count message is $total_msgcount " "imboxstats_fn" 
		echo "newcheck_msgcount is new_check_msgcount=$new_check_msgcount" >>debug.log
		echo "total_msgcount is total_msgcount=$total_msgcount" >>debug.log
		let msg_seq_n1=${check_msgcount}+1
		msg_seq_n2=$new_check_msgcount
		echo "########## msg_seq_n1=$msg_seq_n1" >>debug.log
		echo "########## msg_seq_n2=$msg_seq_n2" >>debug.log
		echo "... IMAP fetcing rfc822.size ..."
		echo "... IMAP fetcing rfc822.size ..." >>debug.log
		#considering alias imapfethc situation
		if [ ! -n "$4" ]
		then
			password=$user_mail
			loginaccount=$user_mail
		else
		  loginaccount=$user_mail@${default_domain}
		  password=$4
		fi
		
		rmefailcount=1
		while [[ $rmefailcount != 0 ]]  
		do    
		      
					exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
					echo -en "a login $loginaccount $password\r\n" >&3
					echo -en "a select inbox\r\n" >&3
					echo -en "a fetch ${msg_seq_n1}:${msg_seq_n2} rfc822.size\r\n" >&3
					#echo -en "a fetch 1 rfc822\r\n" >&3
					echo -en "a logout\r\n" >&3
					cat <&3 > imapfetchsize.tmp
					rmefailcount=$(grep "RmeRetryFailure" imapfetchsize.tmp|wc -l )
		done
		
		echo -e "\033[32m... IMAP fetcing rfc822.size completed! \033[0m"
		echo -e "\033[32m... IMAP fetcing rfc822.size completed! \033[0m" >>debug.log
		echo "========== the content of imapfetchsize.tmp ==========" >>debug.log
		cat imapfetchsize.tmp >> debug.log
		echo "======================================================" >>debug.log
		check_imapfetch=$(cat imapfetchsize.tmp | grep '(RFC822.SIZE' | wc -l)
		check_imapfetch=`echo $check_imapfetch | tr -d " "`
		echo "########## check_imapfetch=$check_imapfetch" >>debug.log
		echo "########## mail_count=$mail_count" >>debug.log
		if [ "$check_imapfetch" == "$mail_count" ]
		then
		    msg_min_size=`cat imapfetchsize.tmp | grep '(RFC822.SIZE'| awk '{print $NF}'| sort| head -1| sed 's/).*//g'`
		    echo  "########## msg_min_size=$msg_min_size" >>debug.log
		    echo  "########## msgdata_size=$msgdata_size" >>debug.log
		    if [ $msg_min_size -gt $msgdata_size ];then
		        prints "$mail_size Message to $user_mail delivered successfully" "mail_send" "2"
		        Result="0"
		    else
		        prints "$mail_size Message to $user_mail delivered unsuccessfully" "mail_send" "1"
		        Result="1"
		    fi
		else
		      prints "-ERR IMAP Fetch command for msg is unsuccessful" "imap_fetch" "1"
		      Result="1"
		fi
		
}
function mail_send_thread(){
        user_mail=$1
        mail_type=$2
        foldername2=$3
        mail_parent=$4
        #imboxstats_fn "$user_mail" 
        #The reason i abonddon imboxstats here is that imboxstats has some latency in fast running scripts,whcih will
        #cause y=test cases failed.So changed it to imap fetch .
        imap_select  "$user_mail"  "$foldername2"  &> /dev/null
        emptyflag=$(grep -i "specified mailbox does not exist" imapselect.tmp|wc -l)
        echo "########## emptyflag=$emptyflag" >>debug.log
        if [ "$emptyflag" == "1" ]
        then
         	check_msgcount=0
        else
        	check_msgcount=$(grep EXISTS  imapselect.tmp |awk '{print $2}')
        	#check_msgcount=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)	
        	check_msgcount=`echo $check_msgcount | tr -d " "`
        fi
        
        prints "Message count for $user_mail at start is $check_msgcount " "imap_select" 
        user_mail_name=$(whoami)
        MAILFROM=`imdbcontrol la | grep -i @ | grep -i $user_mail_name | cut -d ":" -f2 | cut -d "@" -f1`
        MAILFROM=`echo $MAILFROM | tr -d " "`
        SUBJECT="Sanity test $check_msgcount"
        DATA="test message"
        echo "########## mail_type=$mail_type"  >>debug.log
        if [ "$mail_type" == "REFERENCES" ];then       
            if [ "x$mail_parent" != "x" ];then
                let mail_seqn=${mail_parent}-1
        
                imfolderlist $user_mail@${default_domain} -folder $foldername2 | grep -q "${mail_seqn}: Message-Id:"
                if [ $? -ne 0 ];then 
                    prints "ERROR:There is no Parent message $4" "mail_send_thread" "1"
                    Result="1"
                fi
              
        
                exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
                echo -en "a login $user_mail $user_mail\r\n" >&3
                echo -en "a select $foldername2\r\n" >&3
                echo -en "a fetch ${mail_parent} BODY[HEADER.FIELDS (Message-Id references)]\r\n" >&3
                echo -en "a logout\r\n" >&3
                cat <&3 > imapfetch.tmp 
                echo "========== the content of imapfetch.tmp ==========" >>debug.log
                cat imapfetch.tmp >> debug.log
                echo "==================================================" >>debug.log
                
                msgid=`cat imapfetch.tmp |grep -i "Message-Id:" | cut -d ":" -f 2`
                msgid=`echo $msgid | tr -d " "`
                oldrefid=`cat imapfetch.tmp | grep -i "REFERENCES:" | head -1 | cut -d ":" -f 2`
                oldrefid=`echo $oldrefid | tr -d " "`
                newrefid="${oldrefid}${msgid}"
                echo "########## msgid=$msgid" >>debug.log
                echo "########## oldrefid=$oldrefid" >>debug.log
                echo "########## newrefid=$newrefid" >>debug.log
                DATA="REFERENCES: ${newrefid}\r\nTest message"
            fi
        elif [ "$mail_type" == "ORDEREDSUBJECT" ];then
            if [ "x$mail_parent" != "x" ];then 
                let mail_seqn=${mail_parent}-1
                imfolderlist $user_mail@${default_domain} -folder $foldername2 | grep "${mail_seqn}: Subject:"  &> log_imfolderlist.tmp
                echo "========== the content of log_imfolderlist.tmp ==========" >>debug.log
                cat log_imfolderlist.tmp  >>debug.log
                echo "=========================================================" >>debug.log
                SUBJECT=`cat log_imfolderlist.tmp | cut -d ":" -f 3`
                echo "########## SUBJECT=$SUBJECT"  >>debug.log
            fi
        fi
        echo "########## foldername2=$foldername2" >>debug.log
        if [ "$foldername2" == "INBOX" ];then
        #send msg
            exec 3<>/dev/tcp/$MTAHost/$SMTPPort
            echo -en "MAIL FROM:$MAILFROM\r\n" >&3
            echo -en "RCPT TO:$user_mail\r\n" >&3
            echo -en "DATA\r\n" >&3
            echo -en "Subject: $SUBJECT\r\n" >&3
            echo -en "$DATA\r\n" >&3
            echo -en ".\r\n" >&3
            echo -en "QUIT\r\n" >&3
            cat <&3 > msgsend.tmp
            echo "========== the content of msgsend.tmp ==========" >>debug.log
            cat msgsend.tmp >>debug.log
            echo "================================================" >>debug.log
        else
            imfolderlist $user_mail@${default_domain} -folder $foldername2 &> log_imfolderlist.tmp
            echo "========== the content of log_imfolderlist.tmp ==========" >>debug.log
            cat log_imfolderlist.tmp   >> debug.log
            echo "=========================================================" >>debug.log
            if cat log_imfolderlist.tmp | grep -q "FLD_NOT_FOUND"
            then
                imap_create "$user_mail" "$foldername2"
                result_create=$Result
                if [ $result_create -ne 0 ];then
                    prints "Create folder $foldername2 for $user_mail unsuccessfully" "imap_create" "1"
                    Result="1"
                else
                		prints "Create folder $foldername2 for $user_mail successfully" "imap_create" "2"
                    Result="0"
                fi
            fi
            msgtxt="TO:$user_mail\r\nMessage-ID: <message-append-id-$check_msgcount>\r\nSubject: $SUBJECT\r\n$DATA\r\n"
            msg_strip=`echo $msgtxt | sed -e 's#\\\r##g' -e 's#\\\n##g'` 
            msgch=`echo $msg_strip| wc -c`
            echo "########## msgch=$msgch" >>debug.log
            msgl=`echo -ne $msgtxt | wc -l`
            echo "########## msgl=$msgl" >>debug.log
            msgsize=$(($msgl*2 + $msgch))
            echo "########## msgsize=$msgsize" >>debug.log
            imap_append "$user_mail" "$foldername2" "{$msgsize}" "$msgtxt"
            result_append=$Result
            echo "########## result_append=$result_append"  >>debug.log
            if [ $result_append -ne 0 ];then
                prints "Message to $user_mail appened unsuccessfully" "imap_append" "1"
                Result=1
            fi
        fi   
        #sleep 10
        #imboxstats_fn "$user_mail"
        imap_select  "$user_mail" "$foldername2"
        new_check_msgcount=$(grep EXISTS  imapselect.tmp |awk '{print $2}')
        
        #new_check_msgcount=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
        new_check_msgcount=`echo $new_check_msgcount | tr -d " "`
        total_msgcount=$(($check_msgcount+1))
        prints "Message count for $user_mail after deliever is $new_check_msgcount " "imap_select" 
        echo "########## new_check_msgcount=$new_check_msgcount"  >>debug.log
        echo "########## total_msgcount=$total_msgcount"  >>debug.log
        if [ "$new_check_msgcount" == "$total_msgcount" ];then
                 prints "Message to $user_mail delivered successfully" "mail_send_thread" "2"
                 Result="0"
        else 
                 prints "Unable to deliver Message to $user_mail " "mail_send_thread" "1"
                 Result="1"
        fi
}

function large_message_send(){
    #large_message_send  "test2"  "$msg_200kb"   "200KB" "$message_template_200K"
    rcptto=$1
    msgdata=$2
    flag=$3
    msgsize=$4
		user_mail_name=$(whoami)
		MAILFROM=$(imdbcontrol la | grep -i @ | grep -i $user_mail_name | cut -d ":" -f2 | cut -d "@" -f1)
		MAILFROM=$(echo $MAILFROM | tr -d " ")
		prints "Sending a $flag mail to $rcptto" "large_msg_delivery_$flag"  2
		exec 3<>/dev/tcp/$MTAHost/$SMTPPort
		echo -en "MAIL FROM:$MAILFROM\r\n" >&3
		echo -en "RCPT TO:$rcptto\r\n" >&3
		echo -en "DATA\r\n" >&3
		echo -en "Subject: $SUBJECT\r\n\r\n" >&3
		echo -en "$msgdata\r\n" >&3
		echo -en ".\r\n" >&3
		echo -en "QUIT\r\n" >&3
		imboxstats $rcptto@${default_domain} > boxstats.tmp
		msgs_user=$(grep "Total Messages Stored"  boxstats.tmp | cut -d ":" -f2)
		msgs_user=$(echo $msgs_user | tr -d " ")
		msgs_stored=$(grep "Total Bytes Stored" boxstats.tmp | cut -d ":" -f2)
		msgs_stored=$(echo $msgs_stored | tr -d " ")
		msgs_size=$(ls -l "$msgsize" | cut -d " " -f5)
		echo "########## msgs_size=$msgs_size" >>debug.log
		echo "########## msgs_stored=$msgs_stored"  >>debug.log
		echo "########## msgs_user=$msgs_user"  >>debug.log
}



function no_flag_msg() {
        
     user1=$1
     user2=$2
		 imboxstats $user2@${default_domain} > boxstats.tmp
		 echo "========== the content of boxstats.tmp ==========" >>debug.log
		 cat boxstats.tmp >>debug.log
		 echo "=================================================" >>debug.log
     msgs=$(grep "Total Messages Stored"  boxstats.tmp | cut -d ":" -f2)
     msgs=`echo $msgs | tr -d " "`
     msgs=$(($msgs+1))
	   prints "Sending a mail to $user2 from $user1" "No_flags_msg_deliver" 
	   
	   exec 3<>/dev/tcp/$MTAHost/$SMTPPort
	   echo -en "MAIL FROM:$user1\r\n" >&3
	   echo -en "RCPT TO:$user2\r\n" >&3
	   echo -en "DATA\r\n" >&3
	   echo -en "Subject: no_flag_msg test\r\n\r\n" >&3
	   echo -en "hahahaha\r\n" >&3
	   echo -en ".\r\n" >&3
	   echo -en "QUIT\r\n" >&3
	   imboxstats $user2@${default_domain} >  boxstats2.tmp
	   echo "========== the content of boxstats2.tmp==========" >>debug.log
	   cat boxstats2.tmp >>debug.log
	   echo "=================================================" >>debug.log
     msgs1=$(grep "Total Messages Stored"   boxstats2.tmp | cut -d ":" -f2)
     msgs1=`echo $msgs1 | tr -d " "`
     echo "########## msgs1=$msgs1" >>debug.log
     echo "########## msgs=$msgs"  >>debug.log
     if [ "$msgs1" == "$msgs" ]
     then
         prints "No_flags_msg mail delivered successfully" "No_flags_msg_deliver" "2"
         Result=0
	   else
	       prints " ERROR:No_flsg_msg mail delivered failed" "No_flags_msg_deliver" "1"
		     Result=1
     fi
}

function pure_telnet_msgsend(){

		mailfrom=$1
		rcptto=$2
		msgdata=$3	
		exec 3<>/dev/tcp/$MTAHost/$SMTPPort
		echo -en "MAIL FROM:$mailfrom\r\n" >&3
		echo -en "RCPT TO:$rcptto\r\n" >&3
		echo -en "DATA\r\n" >&3
		echo -en "$(cat $msgdata)\r\n">&3
		echo -en ".\r\n" >&3
		echo -en "quit\r\n" >&3
		cat <&3 >smtp-temp.tmp
		exec 3>&-
		echo "========== the content of smtp-temp.tmp ==========" >>debug.log
		cat smtp-temp.tmp >>debug.log
		echo "==================================================" >>debug.log
		sentflag=`grep "Message received"   smtp-temp.tmp |wc -l`
		echo "########## sentflag=$sentflag" >>debug.log
		if [ $sentflag -eq 1 ];then
				prints "mesage delivered successfully" "pure_telnet_msgsend" "2"
		else
				prints "mesage delivered failed" "pure_telnet_msgsend" "1"
		fi
}
# "##################IMAP related functions######################"

function imap_lsub(){
	
	user=$1
	targetfolder=$2
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $user $user\r\n" >&3
	echo -en "a lsub \"\" *\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imap_lsub.tmp
	echo "========== the content of imap_lsub.tmp ==========" >>debug.log
	cat imap_lsub.tmp >>debug.log
	echo "==================================================" >>debug.log
	
	lsub_exist=$(cat imap_lsub.tmp|grep -i LSUB|grep $targetfolder|wc -l)
	echo "########## lsub_exist=$lsub_exist" >>debug.log
	if [ $lsub_exist -eq 1 ];then
		 prints "Target folder found, LSUB running successfully" "IMAP_LSUB" "2"
		 Result=0
	else
	   prints "Target folder not found, LSUB running failed or no folder exists" "IMAP_LSUB" 1
		 Result=1
	fi	
}


function imap_subscribe (){

     user=$1
	   foldername=$2
     exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		 echo -en "a login $user $user\r\n" >&3
		 echo -en "a subscribe $foldername\r\n" >&3
		 echo -en "a logout\r\n" >&3
		 cat <&3 > imap_sub.tmp
		 echo "========== the content of imap_sub.tmp ==========" >>debug.log
		 cat imap_sub.tmp >>debug.log
		 echo "==================================================" >>debug.log
		 
		 sub_exist=$(cat imap_sub.tmp|grep -i "OK SUBSCRIBE completed"|wc -l)
		 echo "########## sub_exist=$sub_exist" >>debug.log
		 if [ $sub_exist -eq 1 ];then
		 	 prints "Subscribe command running successfully" "IMAP_SUBSCRIBE" "2"
		 	 Result=0
		 else
		   prints "Subscribe command running  failed" "IMAP_SUBSCRIBE" "1"
		 	 Result=1
		 fi	
}

function imap_unsubscribe (){

     user=$1
	   foldername=$2
     exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		 echo -en "a login $user $user\r\n" >&3
		 echo -en "a unsubscribe $foldername\r\n" >&3
		 echo -en "a logout\r\n" >&3
		 cat <&3 > imap_unsub.tmp
		 echo "========== the content of imap_unsub.tmp ==========" >>debug.log
		 cat imap_unsub.tmp >>debug.log
		 echo "==================================================" >>debug.log
		 
		 unsub_exist=$(cat imap_unsub.tmp|grep -i " OK UNSUBSCRIBE completed"|wc -l)
		 echo "########## unsub_exist=$unsub_exist" >>debug.log
		 if [ $unsub_exist -eq 1 ];then
		 	 prints "Unsubscribe command running successfully" "IMAP_UNSUBSCRIBE" "2"
		 	 Result=0
		 else
		   prints "Unsubscribe command running failed" "IMAP_UNSUBSCRIBE" "1"
		 	 Result=1
		 fi	
}



function imap_fetch(){
		#start_time_tc imap_fetch_tc
		imapUser=$1
		msg_tobefetched=$2
		parameter_tobefetched=$3
		foldername=$4
	
		if [ "$3" == "" ]
		then
				parameter_tobefetched="rfc822"
		fi
		if [ "$4" == "" ]
		then
				foldername="INBOX"
		fi
		echo "... IMAP fetcing ... "
		echo "... IMAP fetcing ... " >>debug.log
		out=1
		while [[ $out != 0 ]]  
		do
			exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
			echo -en "a login $imapUser $imapUser\r\n" >&3
			echo -en "a select $foldername\r\n" >&3
			echo -en "a fetch $msg_tobefetched $parameter_tobefetched\r\n" >&3
			echo -en "a logout\r\n" >&3
			cat <&3 > imapfetch.tmp
			echo "========== the content of imapfetch.tmp ==========" >>debug.log
			cat imapfetch.tmp >> debug.log 
			echo "==================================================" >>debug.log
			out=$(grep "MsLoadedByOtherMSS" imapfetch.tmp|wc -l )
		done
		
		echo -e "\033[32m... IMAP fetcing completed! \033[0m"
		echo -e "\033[32m... IMAP fetcing completed! \033[0m" >>debug.log
		
		check_imapfetch=$(cat imapfetch.tmp | grep -i "OK FETCH completed" | wc -l)
		check_imapfetch=`echo $check_imapfetch | tr -d " "`
		echo "########## check_imapfetch=$check_imapfetch" >>debug.log
		if [ "$check_imapfetch" == "1" ]
		then
				prints "IMAP Fetch command for $parameter_tobefetched for $imapUser is successful" "imap_fetch" "2"
				Result="0"
		else
				prints "-ERR IMAP Fetch command for $parameter_tobefetched for $imapUser is unsuccessful" "imap_fetch" "1"
				Result="1"
		fi
}

function imap_invalid_tag(){
		user=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a select INBOX\r\n" >&3
		echo -en "fdg#@$%%  logout\r\n" >&3
		echo -en "a logout\r\n" >&3
		
		cat <&3 > invalid_tag.tmp
		echo "========== the content of invalid_tag.tmp ==========" >>debug.log
		cat invalid_tag.tmp >>debug.log
		echo "====================================================" >>debug.log
		
		invalid_count=$(cat invalid_tag.tmp | grep "BAD Illegal character in tag" | wc -l)
		echo "########## invalid_count=$invalid_count" >>debug.log
		if [ "$invalid_count" == "1" ]
		then
			prints "Giving proper error message while wrong logout command" "imap_invalid_tag" "2"
			Result="0"
		else
			prints "ERROR:Not giving proper error message while wrong logout command. Please check manually." "imap_invalid_tag" "1"
			Result="1"
		fi
}
function imap_uid_fetch(){
		#start_time_tc imap_uid_fetch_tc
		imapUser=$1
		msg_tobefetched=$2
		parameter_tobefetched=$3
		foldername=$4
		
		
		
		if [ "$3" == "" ]
		then
				parameter_tobefetched="rfc822"
		fi
		if [ "$4" == "" ]
		then
				foldername="INBOX"
		fi
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a select $foldername\r\n" >&3
		echo -en "a uid fetch $msg_tobefetched $parameter_tobefetched\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapuidfetch.tmp
		echo "========== the content of imapuidfetch.tmp ==========" >>debug.log
		cat imapuidfetch.tmp >> debug.log
		echo "=====================================================" >>debug.log
		
		check_imapuidfetch=$(cat imapuidfetch.tmp | grep -i "OK UID FETCH completed" | wc -l)
		check_imapuidfetch=`echo $check_imapuidfetch | tr -d " "`
		echo "########## check_imapuidfetch=$check_imapuidfetch" >>debug.log
		if [ "$check_imapuidfetch" == "1" ]
		then
				prints "IMAP UID Fetch command for $parameter_tobefetched for $imapUser is successful" "imap_uid_fetch" "2"
				Result="0"
		else
				prints "-ERR IMAP UID Fetch command for $parameter_tobefetched for $imapUser is unsuccessful" "imap_uid_fetch" "1"
				Result="1"
		fi
		
}         


function imap_login(){
		
		user2=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user2 $user2\r\n" >&3
		echo -en "a logout\r\n" >&3	
		
		cat <&3 > imaplogin.tmp
		echo "========== the content of imaplogin.tmp==========" >>debug.log
		cat imaplogin.tmp >> debug.log
		echo "=================================================" >>debug.log
		check_imaplogin=$(cat imaplogin.tmp | grep -i "OK LOGIN completed" | wc -l)
		check_imaplogin=`echo $check_imaplogin | tr -d " "`
		echo "########## check_imaplogin=$check_imaplogin" >>debug.log
		if [ "$check_imaplogin" == "1" ]
		then
				prints "IMAP Login is successful" "imap_login" "2"
				Result="0"
		else
				prints "IMAP Login is unsuccessful" "imap_login" "1"
				Result="1"
		fi
}

function imap_logout(){
	
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a logout\r\n" >&3
		cat <&3 > imaplogout.tmp
		
		echo "========== the content of imaplogout.tmp ========== " >>debug.log
		cat imaplogout.tmp >> debug.log
		echo "====================================================" >>debug.log
		
		check_imaplogout=$(cat imaplogout.tmp | grep -i "OK LOGOUT completed" | wc -l)
		check_imaplogout=`echo $check_imaplogout | tr -d " "`
		echo "########## check_imaplogout=$check_imaplogout"  >>debug.log
		if [ "$check_imaplogout" == "1" ]
		then
				prints "IMAP Logout is successful" "imap_logout" "2"
				Result="0"
		else
				prints "IMAP Logout is unsuccessful" "imap_logout" "1"
				Result="1"
		fi
		
}

function imap_list(){
	
		imapUser=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a list \"\" *\r\n" >&3
		echo -en "a logout\r\n" >&3	
		cat <&3 > imaplist.tmp
		echo "========== the content of imaplist.tmp ==========" >>debug.log
		cat imaplist.tmp >> debug.log
		echo "=================================================" >>debug.log
		check_imaplist=$(cat imaplist.tmp | grep -i "OK LIST completed" | wc -l)
		check_imaplist=`echo $check_imaplist | tr -d " "`
		echo "########## check_imaplist=$check_imaplist"  >>debug.log
		if [ "$check_imaplist" == "1" ]
		then
				prints "IMAP list command for $imapUser is successful" "imap_list" "2"
				Result="0"
		else
				prints "-ERR IMAP list command for $imapUser is unsuccessful" "imap_list" "1"
				Result="1"
		fi
}


function imap_examine(){
		imapUser=$1
		foldername=$2
		
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a examine $foldername\r\n" >&3
		echo -en "a store 1 +flags \Draft\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapexamine.tmp
		
		echo "========== the content of imapexamine.tmp ==========" >>debug.log
		cat imapexamine.tmp >> debug.log
		echo "====================================================" >>debug.log
		
		check_imapexamine=$(cat imapexamine.tmp | grep -i "EXAMINE completed" | cut -d " " -f3)
		check_imapexamine=`echo $check_imapexamine | tr -d " "`
		
		verify_imapexamine=$(cat imapexamine.tmp | grep -i  "NO The mailbox is read-only" | wc -l)
		verify_imapexamine=`echo $verify_imapexamine | tr -d " "`
		echo "########## check_imapexamine=$check_imapexamine"  >>debug.log
		echo "########## verify_imapexamine=$verify_imapexamine"  >>debug.log
		if [[ "$check_imapexamine" == "[READ-ONLY]" && "$verify_imapexamine" == "1" ]]
		then
			prints "IMAP EXAMINE for $imapUser is successful" "imap_examine" "2"
			Result="0"
		else
			prints "ERROR: IMAP EXAMINE for $user2 is not successful" "imap_examine" "1"
			prints "ERROR: IMAP EXAMINE for $user2 is not successful. Please check Manually." "imap_examine" "1"
			Result="1"
		fi
}

function imap_capability() {
		imapUser=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a capability\r\n" >&3
		echo -en "a logout\r\n" >&3
		
		cat <&3 > imapCapablity.tmp
		echo "========== the content of imapCapablity.tmp ==========" >>debug.log
		cat imapCapablity.tmp >> debug.log
		echo "======================================================" >>debug.log
		check_capability_count1=$(cat imapCapablity.tmp | awk '{print $4}' | grep 'UIDPLUS' | wc -l)
		check_capability_count2=$(cat imapCapablity.tmp | awk '{print $4}' | grep 'completed' | wc -l)
		echo "########## check_capability_count1=$check_capability_count1" >> debug.log
		echo "########## check_capability_count2=$check_capability_count2" >>debug.log
		if [[ $check_capability_count1 == 1 && $check_capability_count2 == 3 ]]; then
				prints "IMAP CAPABILITY for $imapUser is successful" "imap_capability" "2"
				Result="0" 
		else 
				prints "-ERR IMAP CAPABILITY for $imapUser is unsuccessful" "imap_capability" "1"
				Result="1"
		fi
}

function imap_status() {
	
	imapUser=$1
	# login and check status command
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a status inbox (messages recent uidnext UNSEEN)\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapStatus.tmp
	echo "========== the content of imapStatus.tmp ==========" >>debug.log
	cat imapStatus.tmp >> debug.log
	echo "===================================================" >>debug.log
	# assert result
	check_status_count=$(cat imapStatus.tmp | grep 'STATUS completed' | wc -l)
	echo "########## check_status_count=$check_status_count"  >>debug.log
	if [[ $check_status_count == 1 ]] ;then
		prints "IMAP STATUS for $imapUser is successful" "imap_status" "2"
		Result="0"
	else 
		prints "-ERR IMAP STATUS for $imapUser is unsuccessful" "imap_status" "1"
		Result="1"
	fi
}

function imap_select(){
		
		imapUser=$1
		foldername=$2
		if [ "$2" == "" ]
		then
			foldername="INBOX"
		fi
		if [  -n "$3" ]
		then
			password=$3		
		else
		  password=$1
		fi
		echo "########## imapUser=$imapUser" >>debug.log
		echo "########## password=$password" >>debug.log
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $password\r\n" >&3
		echo -en "a select $foldername\r\n" >&3
		echo -en "a logout\r\n" >&3	
		
		cat <&3 > imapselect.tmp
		echo "========== the content of imapselect.tmp ==========" >>debug.log
		cat imapselect.tmp >> debug.log
		echo "===================================================" >>debug.log
		check_imapselect=$(cat imapselect.tmp | grep -i "SELECT completed" | wc -l)
		check_imapselect=`echo $check_imapselect | tr -d " "`
		echo "########## check_imapselect=$check_imapselect" >>debug.log
		if [ "$check_imapselect" == "1" ]
		then
			prints "IMAP select command for folder $foldername is successful" "imap_select" "2"
			Result="0"
		else
			prints "-ERR IMAP select command for $foldername is unsuccessful" "imap_select" "1"
			Result="1"
		fi
		
}

function imap_create(){
	imapUser=$1
	foldername=$2
		
	folderlist=()  #put 5 default folders into this array
	imconfget -fullpath /*/common/defaultFolderList >& folder.tmp
	maxcount=$( cat folder.tmp | wc -l)
	echo "########## maxcount=$maxcount" >>debug.log
	index=0
	for((i=1;i<=$maxcount;i++))
		do
			line_p="p"
			line=$i$line_p
			check_folder=$(sed -n $line folder.tmp)
			folderlist[$index]="$check_folder"
			index=$index+1
		done
	
	index=$(($index+1))
	folderlist[$index]="INBOX"
	
	function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
	}
		
	if [ $(contains "${folderlist[@]}" "$foldername") == "y" ]
	then
		folder_to_create_flag=0
	else
		folder_to_create_flag=1
	fi
	
	if [ "$folder_to_create_flag" == "1" ]
	then
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a create $foldername\r\n" >&3
		echo -en "a list \"\" *\r\n" >&3
		echo -en "a logout\r\n" >&3
		
		cat <&3 > imapcreate.tmp
		
		check_imap_create=$(cat imapcreate.tmp | grep -i "OK CREATE completed" | wc -l)
		check_imap_create=`echo $check_imap_create | tr -d " "`
		
		imap_list "$imapUser"
		
		check_createfolder=$(cat imaplist.tmp | grep -i $foldername | wc -l)	
		check_createfolder=`echo $check_createfolder | tr -d " "`
		echo "========== the content of imapcreate.tmp ==========" >>debug.log
		cat imapcreate.tmp >> debug.log
		echo "===================================================" >>debug.log
		echo "########## check_imap_create=$check_imap_create" >>debug.log
		echo "########## check_createfolder=$check_createfolder" >>debug.log
		if [[ "$check_imap_create" == "1" && "$check_createfolder" == "1" ]]
		then
			prints "IMAP CREATE command is successful. Created folder $foldername" "imap_create" "2"
			Result="0"
		else
			prints "-ERR IMAP CREATE command is unsuccessful. Not able to create folder $foldername" "imap_create" "1"
			Result="1" 
		fi
	else
			prints "The specified folder \"$foldername\" already exists; Create command is successful" "imap_create" "2"
			Result="0" 
	fi
	
}

function imap_uid_check (){
      user1=$1
			exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		  echo -en "a login $user1 $user1\r\n" >&3
		  echo -en "a select INBOX\r\n" >&3
		  echo -en "a fetch 2 rfc822\r\n" >&3
		  echo -en "a fetch 2:4 uid\r\n" >&3
			echo -en "a fetch 2 envelope\r\n" >&3
			echo -en "a logout\r\n" >&3
			cat <&3 >> check.tmp
			echo "========== the content of check.tmp ==========" >>debug.log
			cat  check.tmp >>debug.log
			echo "==============================================" >>debug.log

      first=$(cat check.tmp | grep "* 2 FETCH" | grep -i "UID" | cut -d " " -f5) 
			first=${first:0:4}
      prints " first uid == "$first "imap_uid_check" 
							
			second=$(cat check.tmp | grep "* 3 FETCH" | grep -i "UID" | cut -d " " -f5)
      second=${second:0:4}							
			prints " second uid == "$second "imap_uid_check" 
			third=$(cat check.tmp | grep "* 4 FETCH" | grep -i "UID" | cut -d " " -f5)
      third=${third:0:4}							
			prints " third uid == "$third "imap_uid_check" 
			echo "########## first=$first"  >>debug.log
			echo "########## second=$second" >>debug.log
			echo "########## third=$third"  >>debug.log
			
			if [ "$first" == "1002" ] && [ "$second" == "1003" ] && [ "$third" == "1004" ]
			then
			   prints "UID in IMAP is correct and in proper sequence" "imap_uid_check" "2"
			   Result=0
			else
			   prints "ERROR:UID in IMAP is not correct and in unproper sequence" "imap_check" "1"
			   Result=1
			fi						
}

function imap_idle() {
	user2=$1
	set_config_keys "/*/imapserv/enableIdle" "true" 
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $user2 $user2\r\n" >&3
	echo -en "a list \"\" *\r\n" >&3
	echo -en "a select INBOX\r\n" >&3				
	echo -en "a idle\r\n" >&3
	echo -en "DONE\r\n" >&3
	echo -en "a logout\r\n" >&3
	
	cat <&3 &>> imapidle.tmp
	echo "========== the content of imapidle.tmp ==========" >>debug.log
	cat imapidle.tmp >> debug.log
	echo "=================================================" >>debug.log
	
	check_idle=$(cat imapidle.tmp | grep -i "+ idling" |wc -l)
	check_idle=`echo $check_idle | tr -d " "`
	
	echo "########## check_idle=$check_idle"  >>debug.log
	if [ "$check_idle" == "1" ] 
	then
		prints "IMAP IDLE for $user2 is successful" "TC_Imap_idle" "2"
		Result="0"
	else
		prints "ERROR: IMAP IDLE for $user2 is not successful" "TC_Imap_idle" "1"
		prints "ERROR: IMAP IDLE for $user2 is not successful. Please check Manually." "TC_Imap_idle" "1"
		Result="1"
	fi
	set_config_keys "/*/imapserv/enableIdle" "false" 	
}

function imap_getquota_root() {
		user=$1
		set_cos "$user" "mailquotamaxmsgs" "100"
		set_cos "$user" "mailquotatotkb" "10000"
		set_cos "$user" "mailquotamaxmsgkb" "1000"
		
		mail_send "$user" "small" "1" 
		
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a list \"\" *\r\n" >&3
		echo -en "a select INBOX\r\n" >&3				
		echo -en "a getquotaroot INBOX\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > root.tmp
		echo "========== the content of  root.tmp ==========" >>debug.log
		cat  root.tmp >> debug.log
		echo "==============================================" >>debug.log
		
		check_getquotaroot=$(cat root.tmp | grep "QUOTA \"\" " | cut -d "(" -f2 | cut -d ")" -f1 | grep "MESSAGE" | wc -l)
		check_getquotaroot=`echo $check_getquotaroot | tr -d " "`
		echo "########## check_getquotaroot=$check_getquotaroot"  >>debug.log
		if [ "$check_getquotaroot" == "1" ]
		then
			prints "IMAP get quota root for INBOX is sucessful" "TC_Imap_getquota_root" "2"
			Result="0"
		else
			prints "ERROR:IMAP get quota root for INBOX is not successful" "TC_Imap_getquota_root" "1"
			prints "ERROR: Please check Manually." "TC_Imap_getquota_root" "1"
			Result="1"
		fi
		immsgdelete_utility "$user" "-all"
}

function imap_noop(){
	
	user2=$1
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a NOOP\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapnoop1.tmp
	
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $user2 $user2\r\n" >&3
	echo -en "a NOOP\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapnoop2.tmp
	
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $user2 $user2\r\n" >&3
	echo -en "a select INBOX\r\n" >&3
	echo -en "a NOOP\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapnoop3.tmp
	echo "========== the content of imapnoop1.tmp ==========" >>debug.log
	cat imapnoop1.tmp  >> debug.log
	echo "==================================================" >>debug.log
	echo "========== the content of imapnoop2.tmp ==========" >>debug.log
	cat imapnoop2.tmp  >> debug.log
	echo "==================================================" >>debug.log
	echo "========== the content of imapnoop3.tmp ==========" >>debug.log
	cat imapnoop3.tmp >> debug.log
	echo "==================================================" >>debug.log
	
	check_imapnoop1=$(cat imapnoop1.tmp | grep -i "OK NOOP completed" |wc -l)
	check_imapnoop1=`echo $check_imapnoop1 | tr -d " "`
	
	check_imapnoop2=$(cat imapnoop2.tmp | grep -i "OK NOOP completed" |wc -l)
	check_imapnoop2=`echo $check_imapnoop2 | tr -d " "`
	
	check_imapnoop3=$(cat imapnoop3.tmp | grep -i "OK NOOP completed" |wc -l)
	check_imapnoop3=`echo $check_imapnoop3 | tr -d " "`
	echo "########## check_imapnoop1=$check_imapnoop1" >>debug.log
	echo "########## check_imapnoop2=$check_imapnoop2" >>debug.log
	echo "########## check_imapnoop3=$check_imapnoop3" >>debug.log 
	if [[ "$check_imapnoop1" == "1" && "$check_imapnoop2" == "1" && "$check_imapnoop3" == "1" ]]
	then
		prints "IMAP NOOP for $user2 is successful" "TC_Imap_noop" "2"
		Result="0"
	else
		prints "ERROR: IMAP NOOP for $user2 is not successful" "TC_Imap_noop" "1"
		prints "ERROR: IMAP NOOP for $user2 is not successful. Please check Manually." "TC_Imap_noop" "1"
		Result="1"
	fi
	
}


function imap_check(){
	
		user=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a check\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapcheck1.tmp
		
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a check\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapcheck2.tmp
		
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a select INBOX\r\n" >&3
		echo -en "a check\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapcheck3.tmp
		
		echo "========== the content of imapcheck1.tmp ==========" >>debug.log
		cat imapcheck1.tmp  >> debug.log
		echo "==================================================" >>debug.log
		echo "========== the content of imapcheck2.tmp ==========" >>debug.log
		cat imapcheck2.tmp  >> debug.log
		echo "==================================================" >>debug.log
		echo "========== the content of imapcheck3.tmp ==========" >>debug.log
		cat imapcheck3.tmp  >> debug.log
		echo "==================================================" >>debug.log
		
		check_imapcheck1=$(cat imapcheck1.tmp | grep -i "BAD Unrecognized command" |wc -l)
		check_imapcheck1=`echo $check_imapcheck1 | tr -d " "`
		
		check_imapcheck2=$(cat imapcheck2.tmp | grep -i "BAD Unrecognized command" |wc -l)
		check_imapcheck2=`echo $check_imapcheck2 | tr -d " "`
		
		check_imapcheck3=$(cat imapcheck3.tmp | grep -i "OK CHECK completed" |wc -l)
		check_imapcheck3=`echo $check_imapcheck3 | tr -d " "`
		echo "########## check_imapcheck1=$check_imapcheck1"  >>debug.log
		echo "########## check_imapcheck2=$check_imapcheck2" >>debug.log
		echo "########## check_imapcheck3=$check_imapcheck3" >>debug.log
		if [[ "$check_imapcheck1" == "1" && "$check_imapcheck2" == "1" && "$check_imapcheck3" == "1" ]]
		then
			prints "IMAP CHECK for $user is successful" "TC_Imap_check" "2"
			Result="0"
		else
			prints "ERROR: IMAP CHECK for $user is not successful" "TC_Imap_check" "1"
			prints "ERROR: IMAP CHECK for $user is not successful. Please check Manually." "TC_Imap_check" "1"
			Result="1"
		fi
}

function imap_close(){
	
	user=$1
	mail_send "$user" "small" "2" 
	imap_select "$user" "INBOX"
	
	check_exists=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists=`echo $check_exists | tr -d " "`
	
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $user $user\r\n" >&3
	echo -en "a select INBOX\r\n" >&3
	echo -en "a store 2:2 +flags (\Deleted)\r\n" >&3
	echo -en "a examine INBOX\r\n" >&3
	echo -en "a select INBOX\r\n" >&3
	echo -en "a close\r\n" >&3
	echo -en "a select INBOX\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapclose.tmp
	echo "========== the content of imapclose.tmp ==========" >>debug.log
	cat imapclose.tmp >> debug.log
	echo "==================================================" >>debug.log
	
	check_imapclose=$(cat imapclose.tmp | grep -i "OK CLOSE completed" |wc -l)
	check_imapclose=`echo $check_imapclose | tr -d " "`
	
	check_exists_new=$(cat imapclose.tmp |grep -i EXISTS | cut -d " " -f2 | tail -1)
	check_exists_new=`echo $check_exists_new | tr -d " "`
	
	total_count=$(($check_exists-1))
	echo "########## check_imapclose=$check_imapclose" >>debug.log
	echo "########## total_count=$total_count" >>debug.log
	echo "########## check_exists_new=$check_exists_new"  >>debug.log
	
	if [[ "$check_imapclose" == "1" && "$total_count" == "$check_exists_new" ]]
	then
		prints "IMAP CLOSE for $user10 is successful" "TC_Imap_close" "2"
		Result="0"
	else
		prints "ERROR: IMAP CLOSE for $user10 is not successful" "TC_Imap_close" "1"
		prints "ERROR: IMAP CLOSE for $user10 is not successful. Please check Manually." "TC_Imap_close" "1"
		Result="1"
	fi

}

function imap_delete(){
	#start_time_tc imap_delete_tc
	imapUser=$1
	foldername=$2
	
	folderlist=()
	imconfget -fullpath /*/common/defaultFolderList >& folder.tmp
	maxcount=$( cat folder.tmp | wc -l)
	index=0
	for((i=1;i<=$maxcount;i++))
		do
			line_p="p"
			line=$i$line_p
			check_folder=$(sed -n $line folder.tmp)
			folderlist[$index]="$check_folder"
			index=$index+1
		done
	
	index=$(($index+1))
	folderlist[$index]="INBOX"
	
	function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
	}
		if [ $(contains "${folderlist[@]}" "$foldername") == "y" ]
	then
		folder_to_create_flag=0
	else
		folder_to_create_flag=1
	fi
	
	if [ "$folder_to_create_flag" == "1" ]
	then
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a delete $foldername\r\n" >&3
	echo -en "a list \"\" *\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapdelete.tmp
	
	check_imapdelete=$(cat imapdelete.tmp | grep -i "OK DELETE completed" | wc -l)
	check_imapdelete=`echo $check_imapdelete | tr -d " "`
	
	imap_list "$imapUser"
	check_deletefolder=$(cat imaplist.tmp | grep -i $foldername | wc -l)
	check_deletefolder=`echo $check_deletefolder | tr -d " "`
	echo "========== the content of imapdelete.tmp==========" >>debug.log
	cat imapdelete.tmp >> debug.log
	echo "==================================================" >>debug.log
	echo "########## check_imapdelete=$check_imapdelete" >>debug.log
	echo "########## check_deletefolder=$check_deletefolder" >>debug.log
	if [[ "$check_imapdelete" == "1" && "$check_deletefolder" == "0" ]]
	then
		prints "IMAP DELETE command is successful. Able to delete folder $foldername_to_delete" "imap_delete" "2"
		Result="0"
	else
		prints "-ERR IMAP DELETE command is unsuccessful. Not able to delete folder $foldername_to_delete" "imap_delete" "1"
		Result="1"
	fi
	else
		prints "The default folder \"$foldername\" cannot be deleted ; Delete command is successful" "imap_delete" "2"
		Result="0" 
	fi
	
}

function imap_append(){
	#start_time_tc imap_append_tc
		
	imapUser=$1
	foldername=$2
	sizeofmsg=$3
	textentered=$4
	
	imap_select "$imapUser" "$foldername"
	check_exists_folder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_folder=`echo $check_exists_folder | tr -d " "`
	
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a append $foldername $sizeofmsg\r\n" >&3
	echo -en "$textentered\r\n" >&3
	echo -en "a select $foldername\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapappend.tmp
	echo "========== the content of imapappend.tmp ==========" >>debug.log
	cat imapappend.tmp >> debug.log
	echo "==================================================="  >>debug.log
	check_imapappend_success=$(cat imapappend.tmp | grep -i "APPEND completed" | wc -l)
	check_imapappend_success=`echo $check_imapappend_success | tr -d " "`
	
	check_exists_new=$(cat imapappend.tmp |grep -i EXISTS |cut -d " " -f2)
	check_exists_new=`echo $check_exists_new | tr -d " "`
	total_msgcount=$(($check_exists_folder+1))
	echo "########## total_msgcount=$total_msgcount" >>debug.log
	echo "########## check_exists_new=$check_exists_new"  >>debug.log
	echo "########## check_imapappend_success=$check_imapappend_success"  >>debug.log
	if [[ "$total_msgcount" == "$check_exists_new" &&  "$check_imapappend_success" == "1" ]] 
	then
		prints "IMAP APPEND command is successful for $foldername and the total count of msg after append is $total_msgcount" "imap_append" "2"
		Result="0"
	else 
		prints "-ERR IMAP APPEND command is unsuccessful for $foldername and the total count of msg after append is $total_msgcount" "imap_append" "1"
		Result="1"
	fi
}


function imap_copy(){
	#start_time_tc imap_copy_tc
	imapUser=$1
	msg_tobecopied=$2
	foldername_tobecopied=$3
	foldername_from_copy=$4
	
	imap_select "$imapUser" "$foldername_from_copy"
	check_exists_fromfolder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_fromfolder=`echo $check_exists_fromfolder | tr -d " "`
		
	imap_select "$imapUser" "$foldername_tobecopied"
	check_exists_tofolder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_tofolder=`echo $check_exists_tofolder | tr -d " "`
	
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a select $foldername_from_copy\r\n" >&3
	echo -en "a list \"\" *\r\n" >&3
	echo -en "a copy 1:$msg_tobecopied $foldername_tobecopied\r\n" >&3
	echo -en "a select $foldername_tobecopied\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapcopy.tmp
	
	check_imapcopy_success=$(cat imapcopy.tmp | grep -i "COPY completed" | wc -l)
	check_imapcopy_success=`echo $check_imapcopy_success | tr -d " "`

	
	check_exists_new=$(cat imapcopy.tmp | grep -i $msg_tobecopied | grep -i EXISTS | cut -d " " -f2 | tail -1)
	check_exists_new=`echo $check_exists_new | tr -d " "`
	echo "========== the content of imapcopy.tmp ==========" >>debug.log
	cat imapcopy.tmp >> debug.log
	echo "=================================================" >>debug.log
	total_msgcount=$(($check_exists_tofolder+$msg_tobecopied))
	
	echo "########## total_msgcount=$total_msgcount" >>debug.log
	echo "########## check_exists_new=$check_exists_new" >>debug.log
	echo "########## check_imapcopy_success=$check_imapcopy_success" >>debug.log
	
	if [[ "$total_msgcount" == "$check_exists_new" && "$check_imapcopy_success" == "1" ]] 
	then
		prints "IMAP COPY command from $foldername_from_copy to $foldername_tobecopied for $imapUser is successful" "imap_copy" "2"
		Result="0"
	else 
		prints "-ERR IMAP COPY command from $foldername_from_copy to $foldername_tobecopied for $imapUser is unsuccessful" "imap_copy" "1"
		Result="1"
	fi
		
}


function imap_rename(){
	#start_time_tc imap_rename_tc
	imapUser=$1
	foldername=$2
	new_foldername=$3
	
	folderlist=()
	imconfget -fullpath /*/common/defaultFolderList >& folder.tmp
	maxcount=$( cat folder.tmp | wc -l)
	index=0
	for((i=1;i<=$maxcount;i++))
		do
			line_p="p"
			line=$i$line_p
			check_folder=$(sed -n $line folder.tmp)
			folderlist[$index]="$check_folder"
			index=$index+1
		done
	
	index=$(($index+1))
	folderlist[$index]="INBOX"
	
	function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
	}
	
	if [ $(contains "${folderlist[@]}" "$foldername") == "y" ]
	then
		folder_to_create_flag=0
	else
		folder_to_create_flag=1
	fi
	if [ $(contains "${folderlist[@]}" "$new_foldername") == "y" ]
	then
		folder_to_create_flag=0
	else
		folder_to_create_flag=1
	fi	
	echo "########## folder_to_create_flag=$folder_to_create_flag" >>debug.log
	if [ "$folder_to_create_flag" == "0" ]
	then
		prints "The specified mailbox already exists.. Cannot rename" "imap_rename" "2"
		Result="0"
	else	
  echo "########## foldername=$foldername" >>debug.log
	if [ "$foldername" == "$new_foldername" ]
	then
		prints "The specified mailbox already exists.. Cannot rename" "imap_rename" "2"
		Result="0"
	else
		prints "Renaming the folder" "imap_rename" 
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a list \"\" *\r\n" >&3
		echo -en "a rename $foldername $new_foldername\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imaprename.tmp
		
		check_imap_rename=$(cat imaprename.tmp | grep -i "OK RENAME completed" | wc -l)
		check_imap_rename=`echo $check_imap_rename | tr -d " "`
		
		imap_list "$imapUser"
		
		check_newfolder=$(cat imaplist.tmp | grep -i $new_foldername | wc -l)	
		check_newfolder=`echo $check_newfolder | tr -d " "`
		check_oldfolder=$(cat imaplist.tmp | grep -i $foldername | wc -l)	
		check_oldfolder=`echo $check_oldfolder | tr -d " "`
		echo "========== the content of  imaprename.tmp ==========" >>debug.log
		cat imaprename.tmp >> debug.log
		echo "====================================================" >>debug.log
		echo "########## check_imap_rename=$check_imap_rename"  >>debug.log
		echo "########## check_newfolder=$check_newfolder"  >>debug.log
		if [[ "$check_imap_rename" == "1" && "$check_newfolder" == "1" ]]
		then
			prints "IMAP RENAME command is successful. Renamed folder $foldername to $new_foldername" "imap_rename" "2"
			Result="0"
		else
			prints "-ERR IMAP RENAME command is unsuccessful. Not able to rename folder $foldername to $new_foldername" "imap_rename" "1"
			Result="1" 
		fi
	fi
	fi
		
}


function imap_move(){
	#start_time_tc imap_move_tc
	#imap_move "test1" "2" "SentMail" "INBOX"
	imapUser=$1
	msg_tobemoved=$2
	foldername_tobemoved=$3
	foldername_from_move=$4
	
	set_config_keys "/*/imapserv/enableMOVE" "true" 
			
	imap_select "$imapUser" "$foldername_from_move"
	check_exists_fromfolder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_fromfolder=`echo $check_exists_fromfolder | tr -d " "`
			
	imap_select "$imapUser" "$foldername_tobemoved"
	check_exists_tofolder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_tofolder=`echo $check_exists_tofolder | tr -d " "`
			
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a select $foldername_from_move\r\n" >&3
	echo -en "a move 1:$msg_tobemoved $foldername_tobemoved\r\n" >&3
	echo -en "a select $foldername_tobemoved\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapmove.tmp
		
	check_imapmove=$(cat imapmove.tmp | grep -i "MOVE completed" | wc -l)
	check_imapmove=`echo $check_imapmove | tr -d " "`
		
	check_exists_new=$(cat imapmove.tmp | grep -i $msg_tobemoved |grep -i EXISTS |cut -d " " -f2 | tail -1)
	check_exists_new=`echo $check_exists_new | tr -d " "`
			
	imap_select "$imapUser" 
	check_msgleft_fromfolder=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_msgleft_fromfolder=`echo $check_msgleft_fromfolder | tr -d " "`
		
	total_msgcount_tofolder=$(($check_exists_tofolder+$msg_tobemoved))
	total_msgleft_fromfolder=$(($check_exists_fromfolder-$msg_tobemoved))
	
  echo "=========== the content of imapmove.tmp ==========" >>debug.log
	cat imapmove.tmp >> debug.log
	echo "==================================================" >>debug.log
	echo "########## total_msgcount_tofolder=$total_msgcount_tofolder"  >>debug.log
	echo "########## check_exists_new=$check_exists_new" >>debug.log
	echo "########## total_msgleft_fromfolder=$total_msgleft_fromfolder"  >>debug.log
	echo "########## check_msgleft_fromfolder=$check_msgleft_fromfolder" >>debug.log
	if [[ "$total_msgcount_tofolder" == "$check_exists_new" && "$total_msgleft_fromfolder" == "$check_msgleft_fromfolder" ]]
	then 
		prints "IMAP MOVE command for $imapUser $foldername_from_move to $foldername_tobemoved is successful" "imap_move" "2"
		Result="0"
	else
		prints "-ERR IMAP MOVE command for $imapUser $foldername_from_move to $foldername_tobemoved is unsuccessful" "imap_move" "1"
		Result="1"
	fi
	set_config_keys "/*/imapserv/enableMOVE" "false" 
}	


function imap_store(){
				#start_time_tc imap_store_tc
				#imap_store "test1" "1" "+" "\Draft" "INBOX"	
				imapUser=$1
				msg_tobeflagged=$2
				option=$3
				flagname=$4
				foldername=$5
				flags="flags"
				parameter=$option$flags
				
				if [ "$3" == "+" ]
				then
						stringused="Added"
				else
						stringused="Removed"
				fi
				
				exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
				echo -en "a login $imapUser $imapUser\r\n" >&3
				echo -en "a select $foldername\r\n" >&3
				echo -en "a store 1:$msg_tobeflagged $parameter $flagname\r\n" >&3
				echo -en "a logout\r\n" >&3
				cat <&3 > imapstore.tmp
				echo "========== the content of  imapstore.tmp ==========" >>debug.log
				cat imapstore.tmp >> debug.log
				echo "===================================================" >>debug.log
				
				check_imapstore=$(cat imapstore.tmp | grep -i "OK STORE completed" | wc -l)
				check_imapstore=`echo $check_imapstore | tr -d " "`
				
				check_imapstore_failure=$(cat imapstore.tmp | grep -i "not a valid flag" | wc -l)
				check_imapstore_failure=`echo $check_imapstore_failure | tr -d " "`
				
				#check flags
        msg_exists=`cat imapstore.tmp | grep EXISTS |cut -d ' ' -f2`
        echo "########## msg_tobeflagged=$msg_tobeflagged" >>debug.log
        if [ "$msg_tobeflagged" == "*" ];then
            msg_tobeflagged_no=$msg_exists
        else
            singleflag=`echo $msg_tobeflagged |grep ","|wc -l`
     				if [ $singleflag -eq 1 ]
       			then
       				#firstbegin=1
	       			firstend=`echo $msg_tobeflagged  |awk -F "," '{print $1}'`
	       			#let firstpart=firstend-firstbegin
	       			secondbegin=`echo $msg_tobeflagged  |awk -F "," '{print $2}'|awk -F ":" '{print $1}'`
	       			secondend=`echo $msg_tobeflagged  |awk -F "," '{print $2}'|awk -F ":" '{print $2}'`
	       			let secondpart=secondend-secondbegin+1
	       			let msg_tobeflagged_no=secondpart+firstend	
	       		else      		
        	    	msg_tobeflagged_no=$msg_tobeflagged
	        	fi
        fi
        imap_fetch "$imapUser" "1:*" "flags"
        echo "########## stringused=$stringused" >>debug.log
        
        if [ "$stringused" == "Removed" ];then
            check_flags=$(cat imapfetch.tmp | grep "FETCH.*FLAGS" | grep -i "$flagname" | wc -l)
            check_flags=`echo $check_flags | tr -d " "`
            echo "########## check_imapstore=$check_imapstore" >>debug.log
            echo "########## check_flags=$check_flags" >>debug.log
            if [ "$check_imapstore" == "1" ] && [ "$check_flags" == "0" ]
            then
                prints "IMAP STORE command for $imapUser is successful,$stringused Flag $flagname" "imap_store" "2"
                Result="0"
            else
                    if [ "$check_imapstore_failure" == "1" ]
                    then
                            prints "IMAP STORE command for $imapUser is successful. $flagname is not a valid flag" "imap_store" "2"
                            Result="0"
                    else
                            prints "-ERR IMAP STORE command for $imapUser is unsuccessful.$flagname could not be $stringused" "imap_store" "1"
                            Result="1"
                    fi
            fi
				else
            check_flags=$(cat imapfetch.tmp | grep FETCH| grep -i "$flagname" | wc -l)
            check_flags=`echo $check_flags | tr -d " "`
            echo "########## check_imapstore=$check_imapstore"  >>debug.log
            echo "########## msg_tobeflagged_no=$msg_tobeflagged_no" >>debug.log
            echo "########## check_flags=$check_flags"  >>debug.log
            if [ "$check_imapstore" == "1" ] && [ "$msg_tobeflagged_no" == "$check_flags" ]
            then
                    prints "IMAP STORE command for $imapUser is successful,$stringused Flag $flagname" "imap_store" "2"
                    Result="0"
            else
            				echo "########## check_imapstore_failure=$check_imapstore_failure"  >>debug.log
                    if [ "$check_imapstore_failure" == "1" ]
                    then
                        prints "IMAP STORE command for $imapUser is successful. $flagname is not a valid flag" "imap_store" "2"
                        Result="0"
                    else
                        prints "-ERR IMAP STORE command for $imapUser is unsuccessful.$flagname could not be $stringused" "imap_store" "1"
                        Result="1"
                fi
            fi
        fi
	
}



function imap_sort() {
	#start_time_tc imap_sort_tc
	imapUser=$1
	foldername=$2
	option=$3
	set_config_keys "/*/imapserv/enableSORT" "true" "1"
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a select $foldername\r\n" >&3 
	echo -en "a uid sort ($option) us-ascii all\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapsort.tmp
	echo "========== teh content of imapsort.tmp ==========" >>debug.log
	cat imapsort.tmp >>debug.log
	echo "=================================================" >>debug.log
	check_imapsort=$(cat imapsort.tmp | grep -i "SORT completed" | wc -l)
	check_imapsort=`echo $check_imapsort | tr -d " "`
	echo "########## check_imapsort=$check_imapsort" >>debug.log
	if [ "$check_imapsort" == "1" ]
	then
		prints "IMAP SORT for $imapUser is successful" "imap_sort" "2"
		Result="0"
	else
		prints "-ERR IMAP SORT for $imapUser is unsuccessful" "imap_sort" "1"
		Result="1"
	fi
	set_config_keys "/*/imapserv/enableSORT" "false" "1"
}



function imap_search(){
	#start_time_tc imap_search_tc
	#imap_search "test1" "INBOX" "all"
	imapUser=$1
	foldername=$2
	option=$3
	value=$4
		
	if [ "$4" == "" ]
	then
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a select $foldername\r\n" >&3
		echo -en "a search $option\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapsearch.tmp
		echo "========== the content of imapsearch.tmp ==========" >>debug.log
		cat imapsearch.tmp >> debug.log
		echo "===================================================" >>debug.log
	else
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $imapUser $imapUser\r\n" >&3
		echo -en "a select $foldername\r\n" >&3
		echo -en "a search $option $value\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 > imapsearch.tmp
		echo "=========== the content of imapsearch.tmp ==========" >>debug.log
		cat imapsearch.tmp >> debug.log
		echo "===================================================="  >>debug.log
	fi	
		check_imapsearch=$(cat imapsearch.tmp | grep -i "SEARCH completed" | wc -l)
		check_imapsearch=`echo $check_imapsearch | tr -d " "`
		echo "########## check_imapsearch=$check_imapsearch"  >>debug.log
		if [ "$check_imapsearch" == "1" ]
		then
			prints "IMAP SEARCH for $imapUser is successful" "imap_search" "2"
			Result="0"
		else
			prints "-ERR IMAP SEARCH for $imapUser is unsuccessful" "imap_search" "1"
			Result="1"
		fi
}


function imap_thread(){
	#start_time_tc imap_thread_tc
	#imap_thread "test1" "INBOX" "REFERENCES UTF-8" "all"
	imapUser=$1
	foldername=$2
	option=$3
	value=$4
		
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a select $foldername\r\n" >&3
	echo -en "a thread $option $value\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapthread.tmp
	echo "========== the content of imapthread.tmp ==========" >>debug.log
	cat imapthread.tmp >> debug.log
	echo "===================================================" >>debug.log
	
	check_imapthread=$(cat imapthread.tmp | grep -i "THREAD completed" | wc -l)
	check_imapthread=`echo $check_imapthread | tr -d " "`
	echo "########## check_imapthread=$check_imapthread"  >>debug.log
	if [ "$check_imapthread" == "1" ]
	then
		prints "IMAP THREAD for $imapUser is successful" "imap_thread" "2"
		Result="0"
	else
		prints "-ERR IMAP THREAD for $imapUser is unsuccessful" "imap_thread" "1"
		Result="1"
	fi
}


function imap_expunge(){
	#start_time_tc imap_expunge_tc
	imapUser=$1
	imap_select "$imapUser"
	check_exists=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists=`echo $check_exists | tr -d " "`
		
	imap_fetch "$imapUser" "1:*" "flags" 
	check_flags=$(cat imapfetch.tmp | grep -i FETCH | grep -i \Deleted | wc -l)
	check_flags=`echo $check_flags | tr -d " "`
		
	exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
	echo -en "a login $imapUser $imapUser\r\n" >&3
	echo -en "a select $foldername\r\n" >&3
	echo -en "a expunge\r\n" >&3
	echo -en "a logout\r\n" >&3
	cat <&3 > imapexpunge.tmp
	
	imap_select "$imapUser"
	check_exists_new=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2)
	check_exists_new=`echo $check_exists_new | tr -d " "`
		
	check_imapexpunge=$(cat imapexpunge.tmp | grep -i "OK EXPUNGE completed" | wc -l)
	check_imapexpunge=`echo $check_imapexpunge | tr -d " "`
	echo "========== the content of imapexpunge.tmp ==========" >>debug.log
	cat imapexpunge.tmp >> debug.log
	echo "====================================================" >>debug.log
	total_msgleft=$(($check_exists-$check_flags))
	echo "########## total_msgleft=$total_msgleft"  >>debug.log
	echo "########## check_exists_new=$check_exists_new"  >>debug.log
	if [ "$total_msgleft" == "$check_exists_new" ] 
	then
		prints "IMAP EXPUNGE command for $imapUser is successful" "imap_expunge" "2"
		Result="0"
	else
		prints "-ERR IMAP EXPUNGE command for $imapUser is unsuccessful" "imap_expunge" "1"
		Result="1"
	fi
}


function  uid_x-thread_utf8_all(){
    
    user=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a select inbox\r\n" >&3
		echo -en "a UID X-THREAD (PARTICIPANTS) UTF-8 ALL\r\n" >&3
		echo -en "a logout\r\n" >&3
		cat <&3 >imap-xthread.tmp
		exec 3>&-
		
		echo "========== the content of imap-xthread.tmp ==========" >>debug.log
		cat imap-xthread.tmp >>debug.log
		echo "=====================================================" >>debug.log
		
}

function uid_x-thread_list_utf8_all(){
  
      user=$1
			exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
			echo -en "a login $user $user\r\n" >&3			
			echo -en "a select inbox\r\n" >&3
			echo -en "a UID X-THREAD (PARTICIPANTS) LIST ($target) UTF-8 ALL\r\n" >&3
			echo -en "a logout\r\n" >&3
			cat <&3 >imap-xthread_list.tmp
			exec 3>&-
			echo "========== the content of imap-xthread_list.tmp ==========" >>debug.log
			cat imap-xthread_list.tmp >>debug.log
			echo "==========================================================" >>debug.log
}

function uid_x-thread_store_flags_Seen(){

    user=$1
		exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
		echo -en "a login $user $user\r\n" >&3
		echo -en "a select inbox\r\n" >&3
		echo -en "a UID X-THREAD (PARTICIPANTS) STORE ($target) +flags \Seen\r\n" >&3		
		echo -en "a logout\r\n" >&3
		cat <&3 >imap-x-thread_store.tmp
		exec 3>&-
		echo "========== the content of imap-x-thread_store.tmp ==========" >>debug.log
		cat imap-x-thread_store.tmp >>debug.log
		echo "============================================================" >>debug.log
}


###################POP related functions######################"
function pop_retrieve(){
		#taking start time of tc
		#start_time_tc pop_retrieve_tc 
		popUser=$1
		msgtoberetrieved=$2
		exec 3<>/dev/tcp/$POPHost/$POPPort
		echo -en "user $popUser\r\n" >&3
		echo -en "pass $popUser\r\n" >&3
		echo -en "retr $msgtoberetrieved\r\n" >&3
		echo -en "quit\r\n" >&3
		cat <&3 > popretrieve.tmp
		echo "========== the content of popretrieve.tmp ==========" >>debug.log
		cat popretrieve.tmp >> debug.log
		echo "====================================================" >>debug.log
		check_retr=$(cat popretrieve.tmp | grep -i "+OK" | grep -i "octets" |wc -l)
		check_content=$(cat popretrieve.tmp | grep -i "Test message for Sanity Tool" |wc -l)
		echo "########## check_retr=$check_retr"  >>debug.log
		echo "########## check_content=$check_content" >>debug.log
		if [[ "$check_retr" == "1" && "$check_content" == "1" ]]
		then
				prints "POP retr command for $popUser is successful" "pop_retrieve" "2"
				Result="0"
		else
				prints "-ERR POP retr command for $popUser is unsuccessful" "pop_retrieve" "1"
				Result="1"
		fi
}

function pop_login(){
		user1=$1
		exec 3<>/dev/tcp/$POPHost/$POPPort
		echo -en "user $user1\r\n" >&3
		echo -en "pass $user1\r\n" >&3
		echo -en "quit\r\n" >&3
		cat <&3 > poplogin.tmp
		echo "========== the content of poplogin.tmp ==========" >>debug.log
		cat poplogin.tmp >> debug.log
		echo "=================================================" >>debug.log
		check_poplogin=$(cat poplogin.tmp | grep -i "welcome here" | wc -l)
		echo "########## check_poplogin=$check_poplogin"  >>debug.log
		if [ "$check_poplogin" == "1" ]
		then
				prints "POP Login is successful" "pop_login" "2"
				Result="0"
		else
				prints "-ERR POP Login is unsuccessful" "pop_login" "1"
				Result="1"
		fi
}

function pop_list(){
	 
		popUser=$1
		exec 3<>/dev/tcp/$POPHost/$POPPort
		echo -en "user $popUser\r\n" >&3
		echo -en "pass $popUser\r\n" >&3
		echo -en "list\r\n" >&3
		echo -en "quit\r\n" >&3
		cat <&3 > poplist.tmp
		echo "=========== the content of poplist.tmp ==========" >>debug.log
		cat poplist.tmp >> debug.log
		echo "=================================================" >>debug.log
		check_list=$(cat poplist.tmp | grep -i "+OK" | grep -i "messages" | wc -l)
		check_list=`echo $check_list | tr -d " "`     
		echo "########## check_list=$check_list"  >>debug.log
		if [ "$check_list" == "1" ]
		then
			prints "POP list command for $popUser is successful" "pop_list" "2"
			Result="0"
		else
			prints "-ERR POP list command for $popUser is unsuccessful" "pop_list" "1"
			Result="1"
		fi
}       

function pop_uidl(){                                                                                                            
                                                  
	popUser=$1    
	messagecount=$2                                                        
	exec 3<>/dev/tcp/$POPHost/$POPPort                                          
	echo -en "user $popUser\r\n" >&3                                            
	echo -en "pass $popUser\r\n" >&3                                            
	echo -en "uidl 1\r\n" >&3                                                   
	echo -en "quit\r\n" >&3                                                                                                                 
	cat <&3 > popuidl.tmp
	echo "========== the content of poplist.tmp  ==========" >>debug.log                                                       
	cat popuidl.tmp >> debug.log                                        
	echo "=================================================" >>debug.log        
	check_uidl=$(cat popuidl.tmp | grep -i "+OK 1" | grep -o "-" | wc -l)       
	check_uidl=`echo $check_uidl| tr -d " "`  
	echo "########## check_uidl=$check_uidl" >>    debug.log                              
	if [ "$check_uidl" == "$messagecount" ]                                                 
	then                                                                        
		prints "POP uidl command for $popUser is successful" "pop_uidl" "2"       
		Result="0"                                                                
	else                                                                        
		prints "-ERR POP uidl command for $popUser is unsuccessful" "pop_uidl" "1"
		Result="1"                                                                
	fi                                                                          
	                                                                            
}    


function POP_quit_before_login(){                                                                                                                                                                                                  
	                                                                                            
	exec 3<>/dev/tcp/$POPHost/$POPPort                                                          
	echo -en "quit\r\n" >&3                                                                                                                                                         
	cat <&3 > popquit.tmp
	echo "========== the content of popquit.tmp==========" >>debug.log                                                                       
	cat popquit.tmp >> debug.log                                      
	echo "===============================================" >>debug.log                          
	check_popquit=$(cat popquit.tmp | grep -i "+OK ? InterMail POP3 server signing off" | wc -l) 
	echo "########## check_popquit=$check_popquit" >>debug.log
	if [ "$check_popquit" == "1" ]                                                              
	then                                                                                        
		prints "POP Quit is successful" "TC_POP_quit_before_login" "2"                            
		Result="0"                                                                                
	else                                                                                        
		prints "-ERR POP Quit is unsuccessful" "TC_POP_quit_before_login" "1"                     
		Result="1"                                                                                
	fi                                                                                                                                       
}                                                

function POP_quit_after_login(){                                                                                                                                                                                 
	user1=$1
	exec 3<>/dev/tcp/$POPHost/$POPPort                                                               
	echo -en "user $user1\r\n" >&3                                                                   
	echo -en "pass $user1\r\n" >&3                                                                   
	echo -en "quit\r\n" >&3                                                                                                                                                                        
	cat <&3 > popquit.tmp 
	echo "========== the content of popquit.tmp ==========" >>debug.log                                                                           
	cat popquit.tmp >> debug.log  
	echo "================================================" >>debug.log                                                                   
	check_popquit=$(cat popquit.tmp | grep -i "+OK $user1 InterMail POP3 server signing off" | wc -l)
	echo "########## check_popquit=$check_popquit"  >>debug.log
	if [ "$check_popquit" == "1" ]                                                                   
	then                                                                                             
		prints "POP Quit is successful" "TC_POP_quit_after_login" "2"                                  
		Result="0"                                                                                     
	else                                                                                             
		prints "-ERR POP Quit is unsuccessful" "TC_POP_quit_after_login" "1"                           
		Result="1"                                                                                     
	fi                                                                                                                                                
}     

function pop_delete(){                                                                                                                                                              
	                                                                                     
	#taking start time of tc                                                                                                                 
	popUser=$1                                                                           
	pop_list "$popUser"  
	cat   poplist.tmp >>debug.log
	check_msgexists=$(cat poplist.tmp | grep -i +OK | grep -i messages | cut -d " " -f2) 
	check_msgexists=`echo $check_msgexists | tr -d " "`                                  
	exec 3<>/dev/tcp/$POPHost/$POPPort                                                   
	echo -en "user $popUser\r\n" >&3                                                     
	echo -en "pass $popUser\r\n" >&3                                                     
	echo -en "dele 1\r\n" >&3                                                            
	echo -en "list\r\n" >&3                                                              
	echo -en "quit\r\n" >&3                                                              
	cat <&3 > list.tmp                                                                   
	#cat  list.tmp  >>debug.log
	check_msgexists_new=$(cat list.tmp | grep -i +OK | grep -i messages | cut -d " " -f2)
	check_msgexists_new=`echo $check_msgexists_new | tr -d " "`                                                                                                                                            
	total_msgleft=$(($check_msgexists-1))                                                
	echo "########## total_msgleft=$total_msgleft"     >> debug.log   
	echo "########## check_msgexists_new=$check_msgexists_new"   >> debug.log                                                              
	if [ "$total_msgleft" == "$check_msgexists_new" ]                                    
	then                                                                                 
		prints "POP dele command for $popUser is successful" "pop_delete" "2"              
		Result="0"                                                                         
	else                                                                                 
		prints "-ERR POP dele command for $popUser is unsuccessful" "pop_delete" "1"       
		Result="1"                                                                         
	fi                                                                                   
                                                 
}  

function pop_stat(){                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                             
	popUser=$1                                                                                                               
	                                                                                                                         
	pop_list "$popUser"                                                                                                      
	check_msgexists=$(cat poplist.tmp | grep -i +OK | grep -i messages | cut -d " " -f2)                                     
	check_msgexists=`echo $check_msgexists | tr -d " "`                                                                                                                                                                                              
	exec 3<>/dev/tcp/$POPHost/$POPPort                                                                                       
	echo -en "user $popUser\r\n" >&3                                                                                         
	echo -en "pass $popUser\r\n" >&3                                                                                         
	echo -en "stat\r\n" >&3                                                                                                  
	echo -en "quit\r\n" >&3                                                                                                  
	cat <&3 > popstat.tmp    
	echo "========== the content of popstat.tmp ==========" >>debug.log                                                                                                
	cat popstat.tmp  >>debug.log                                       
	echo "================================================" >>debug.log                                                                                 
	check_msgstat=$(cat popstat.tmp | grep -i "+OK" | grep -v "$popUser" | grep -v "POP3" | grep -v "PASS" | cut -d " " -f2) 
	check_msgstat=`echo $check_msgstat | tr -d " "`                                                                          
	check_sizestat=$(cat popstat.tmp | grep -i "+OK" | grep -v "$popUser" | grep -v "POP3" | grep -v "PASS" | cut -d " " -f3)
	check_sizestat=`echo $check_sizestat | tr -d " "`                                                                        
	                                                                                                                         
	echo "########## check_msgstat=$check_msgstat"    >>debug.log
	echo "########## check_msgexists=$check_msgexists"  >>debug.log                                                                                                                  
	if [ "$check_msgstat" == "$check_msgexists" ]                                                                            
	then	                                                                                                                   
		total_msgsize=0                                                                                                   
		for ((i=1; i<=check_msgexists;i++))                                                                                    
			do                                                                                                                   
				line_number=$(cat poplist.tmp | cut -d " " -f1 | grep -i -n "$i" | cut -d ":" -f1)                                 
				line_p="p"                                                                                                         
				line=$line_number$line_p                                                                                           
				check_msgsize=$(sed -n $line poplist.tmp | cut -d " " -f2)                                                         
				total_msgsize=$(($total_msgsize+${check_msgsize//$'\r'}))     #delete  "\r"                                                     
			done                                                                                                                 
		total_msgsize=${total_msgsize//$'\r'}                                                                                  
		total_msgsize=`echo $total_msgsize | tr -d " "`                                                                        
		check_sizestat=${check_sizestat//$'\r'}                                                                                
		check_sizestat=`echo $check_sizestat | tr -d " "`                                                                      
		 echo "########## total_msgsize=$total_msgsize" >>debug.log
		 echo "########## check_sizestat=$check_sizestat" >>debug.log                                                                                                                      
		if [ "$total_msgsize" == "$check_sizestat" ]                                                                           
		then                                                                                                                   
			prints "POP stat command for $popUser  is successful" "pop_stat" "2"                                                 
			Result="0"                                                                                                           
		else                                                                                                                   
			prints "-ERR POP stat command for $popUser is unsuccessful" "pop_stat" "1"                                           
			Result="1"                                                                                                           
		fi                                                                                                                     
	fi                                                                                                                       
                                                                                                                                                                                 
}   

#Foldershare and folder unshare

#folderhare and unshare functions,added begin MX9.5
function shareFolder(){
	mxoshost_port=$1
	userfrom=$2
	userto=$3
	foldername=$4
	echo "Sharing folder ..."
	echo "Sharing folder ..." >>debug.log
	curl -X PUT -v -H "Content-Type: application/x-www-form-urlencoded"  "http://${mxoshost_port}/mxos/mailbox/v2/${userfrom}@${default_domain}/folders/${foldername}/share/${userto}@${default_domain}"   &> foldershare.tmp
  outcome_det=`grep "200 OK" foldershare.tmp |wc -l`
  echo "========== the content of foldershare.tmp ==========" >>debug.log
  cat foldershare.tmp  >>debug.log
  echo "====================================================" >>debug.log
  echo "########## outcome_det=$outcome_det" >>debug.log
  if [ $outcome_det -eq 1 ];then
  	prints "Foldershare operation for folder:$foldername from $userfrom to $userto is successful" "shareFolder-operation" "2"
		Result_share="0"
	else
		prints "-ERR Foldershare operation for folder:$foldername from $userfrom to $userto is unsuccessful" "shareFolder-operation" "1"
		Result_share="1"	
  fi
} 


function unshareFolder(){
	mxoshost_port=$1
	userfrom=$2
	userto=$3
	foldername=$4
	echo "Unsharing folder ..."
	echo "Unsharing folder ..." >>debug.log
	curl -X DELETE -v -H "Content-Type: application/x-www-form-urlencoded"  "http://${mxoshost_port}/mxos/mailbox/v2/${userfrom}@${default_domain}/folders/${foldername}/share/${userto}@${default_domain}"   &> unfoldershare.tmp
  outcome_det=`grep "200 OK" unfoldershare.tmp |wc -l`
  echo "========== thecontent of unfoldershare.tmp ==========" >>debug.log
  cat unfoldershare.tmp >>debug.log
  echo "=====================================================" >>debug.log
  echo "########## outcome_det=$outcome_det" >>debug.log
  if [ $outcome_det -eq 1 ];then
		prints "UnFoldershare for folder:$foldername from $userfrom to $userto successful" "UnshareFolder" "2"
		Result="0"
  else
		prints "-ERR UnFoldershare for folder:$foldername from $userfrom to $userto is unsuccessful" "UnshareFolder" "1"
		Result="1"	
  fi
}

########################################## LDAP test functions######################################
function ldap_add_test() {
        #start_time_tc ldap_add_test_tc
        DIRHost=$(cat $INTERMAIL/config/config.db | grep -i dirserv_run  | grep -i on | cut -d "/" -f2)						 
	      DIRPort=$(cat $INTERMAIL/config/config.db | grep -i ldapPort | grep -v cache | grep -v pabd |cut -d "[" -f2 | cut -d "]" -f1)	
			  prints " Directory Host = $DIRHost" "ldap_add_test" 
			  prints " Directory Port = $DIRPort" "ldap_add_test" 
		    user=ldaptest1
			  mailboxid="1"$(date +%S%k%M%S)
			  mailboxid=`echo $mailboxid | tr -d " "`
				echo "dn: mail=$user@${default_domain},dc=openwave,dc=com" > add.ldif
			  echo "objectclass: top" >> add.ldif
			  echo "objectclass: person" >> add.ldif
			  echo "objectclass: mailuser" >> add.ldif
			  echo "objectclass: mailuserprefs" >> add.ldif
			  echo "mailpassword: $user" >> add.ldif
			  echo "mailpasswordtype: C" >> add.ldif
			  echo "mailboxstatus: A" >> add.ldif
			  echo "maillogin: $user" >> add.ldif
			  echo "mail: $user@${default_domain}" >> add.ldif
			  echo "mailmessagestore: $DIRHost" >> add.ldif
        echo "mailautoreplyhost: $DIRHost" >> add.ldif
        echo "mailboxid: $mailboxid" >> add.ldif
			  echo "cn: $user@${default_domain}" >> add.ldif
			  echo "sn: $user@${default_domain}" >> add.ldif
			  echo "adminpolicydn: cn=default,cn=admin root" >> add.ldif
			  prints " Adding account $user@${default_domain} ..... " "ldap_add_test" 
			  echo "========== the contents of add.ldif =========="  >>debug.log
			  cat add.ldif >>debug.log
			  echo "============================================"  >>debug.log
			  ldapadd -D cn=root -w secret -p $DIRPort -f add.ldif > add_result.tmp
			  echo "==========the contents of add_result.tmp=========="  >>debug.log
			  cat add_result.tmp  >>debug.log
			  echo "=================================================="  >>debug.log
			  code=$(cat add_result.tmp | grep -i " return code" | cut -d " " -f7 )
			  code=`echo $code | tr -d " "`
			  echo "########## code=$code"  >>debug.log
			  if [ "$code" == "0" ]
			  then			
						 prints " Account created successfully ...." "ldap_add_test" "2"
			  else						
             prints " ERROR : Account cannot be created ...." "ldap_add_test" "1"
			  fi

			 imdbcontrol la | grep  -i $user | grep @ >add_result.tmp
			 added=$(cat add_result.tmp|  cut -d ":" -f2 | cut -d "@" -f1 )
			 added=`echo $added | tr -d " "`
			 echo "########## added=$added" >>debug.log
			 if [ "$added" == "$user" ]
			 then
			     prints " LDAPADD is working correctly " "ldap_add_test" "2"
				   summary "LDAPADD" 0
				   prints "Testing of ldapadd utility is successful" "ldap_add_test" 2 
                          
			 else
        	 prints " ERROR : LDAPADD is not working correctly " "ldap_add_test" "1"
				   summary "LDAPADD" 1
				   prints "Testing of ldapadd utility is failed" "ldap_add_test" 1
       fi								 						 
}  


function ldap_search_utilty() {
        #start_time_tc ldap_search_utilty_tc
        
        user=$1
        DIRHost=$(cat $INTERMAIL/config/config.db | grep -i dirserv_run  | grep -i on | cut -d "/" -f2)						 
	      DIRPort=$(cat $INTERMAIL/config/config.db | grep -i ldapPort | grep -v cache | grep -v pabd |cut -d "[" -f2 | cut -d "]" -f1)	
			  prints " Directory Host = $DIRHost" "ldap_add_test" 
			  prints " Directory Port = $DIRPort" "ldap_add_test" 
			  prints " Searching account $user@${default_domain} ..... " "ldap_search_utilty" 
			  ldapsearch -D cn=root -w secret -p $DIRPort "mail=$user*" > search_result.tmp
			  echo "=========the content of search_result.tmp ==========" >>debug.log
			  cat  search_result.tmp >>debug.log
			  echo "====================================================" >>debug.log
			  found=$(cat search_result.tmp | grep -i "mail" | cut -d "," -f1 | cut -d "=" -f2 |head -1|cut -d "@" -f1 )
			  found=`echo $found | tr -d " "`
			  echo "########## found=$found"  >>debug.log
			  if [ "$found" == "$user" ]
			  then				
          prints " Account found ...." "ldap_search_utilty" "2"
				  prints " Ldap search is working properly " "ldap_search_utilty" "2"
				  summary "LDAPSEARCH" 0
				  prints "Testing of ldapsearch utility is successful" "ldap_search_utilty"   2
			  else
          prints " ERROR : Account is not found ...." "ldap_search_utilty" "1"
				  prints " ERROR : Ldap search is not working properly " "ldap_search_utilty" "1"
				  summary "LDAPSEARCH" 1
				  prints "Testing of ldapsearch utility is failed" "ldap_search_utilty"   1 
			  fi		 
} 


function ldap_modify_utility() {
       #start_time_tc ldap_modify_utility_tc
       user=$1
       operation=$2
       attribute=$3
       newvalue=$4
     
       DIRHost=$(cat $INTERMAIL/config/config.db | grep -i dirserv_run  | grep -i on | cut -d "/" -f2)						 
	     DIRPort=$(cat $INTERMAIL/config/config.db | grep -i ldapPort | grep -v cache | grep -v pabd |cut -d "[" -f2 | cut -d "]" -f1)	
			 prints " Directory Host = $DIRHost" "ldap_add_test" 
			 prints " Directory Port = $DIRPort" "ldap_add_test" 
       
       echo "dn: mail=$user@${default_domain},dc=openwave,dc=com" > modify.ldif
       echo "changetype: modify" >> modify.ldif
       echo "$operation: $attribute" >> modify.ldif
       echo "$attribute: $newvalue" >> modify.ldif
			 prints " Modifying accoun $user@${default_domain} ..... " "ldap_modify_utility" 
			 echo "==========the content of modify.ldif =========="  >>debug.log
			 cat modify.ldif >>debug.log
			 echo "==============================================="  >>debug.log
			 ldapmodify -D cn=root -w secret -p $DIRPort -f modify.ldif >modify_result.tmp 
			 echo "========== the content of modify_result.tmp =========="  >>debug.log
			 cat modify_result.tmp   >>debug.log
			 echo "======================================================"  >>debug.log
			 result=$(cat modify_result.tmp | grep -i " return code" | cut -d " " -f6 )
			 result=`echo $result | tr -d " "`
			 echo "########## result=$result"  >>debug.log
			 if [ "$result" == "0" ]
			 then				
            prints " Account $attribute modified  successfully ...." "ldap_modify_utility" "2"
			 else						
            prints " ERROR : Account $attribute cannot be modified  ...." "ldap_modify_utility" "1"
			 fi
			 ldapsearch -D cn=root -w secret -p $DIRPort "mail=$user@${default_domain}*" > modify_result1.tmp
			 echo "==========the content of modify_result1.tmp ==========" >>debug.log
			 cat modify_result1.tmp >>debug.log
			 echo "======================================================" >>debug.log
			 modified=$(cat modify_result1.tmp| grep -i $attribute | cut -d "=" -f2 |tail -1  )
			 modified=`echo $modified | tr -d " "`
			 echo "########## modified=$modified"  >>debug.log
			 if [ "$modified" == "$newvalue" ]
			 then
			     prints " LDAPMODIFY is working correctly " "ldap_modify_utility" "2"
				   prints "Testing of ldapmodify utility is successfully" "ldap_modify_utility" 2
			 else
       		 prints " ERROR : LDAPMODIFY is not working correctly " "ldap_modify_utility" "1"
				   prints "Testing of ldapmodify utility is failed" "ldap_modify_utility"  1
       fi								                         
}     


function ldap_delete_utility() {
        #start_time_tc ldap_delete_utility_tc
        user=$1
        
        DIRHost=$(cat $INTERMAIL/config/config.db | grep -i dirserv_run  | grep -i on | cut -d "/" -f2)						 
	      DIRPort=$(cat $INTERMAIL/config/config.db | grep -i ldapPort | grep -v cache | grep -v pabd |cut -d "[" -f2 | cut -d "]" -f1)	
			  prints " Directory Host = $DIRHost" "ldap_add_test" 
			  prints " Directory Port = $DIRPort" "ldap_add_test" 
			  
        echo "mail=$user@${default_domain},dc=openwave,dc=com"  > del.ldif
			  prints " Deleting account $user@${default_domain} ..... " "ldap_delete_utility" 
        echo "==========the content of del.ldif ==========" >>debug.log
        cat del.ldif >>debug.log
        echo "============================================" >>debug.log
			  ldapdelete -D cn=root -w secret -p $DIRPort -f del.ldif 

			  imdbcontrol la |grep @ |grep -i "$user@${default_domain}" > delete_result.tmp
			  echo "========== the content of delete_result.tmp==========" >>debug.log
			  cat delete_result.tmp >>debug.log
			  echo "====================================================="  >>debug.log
			  deleted=$(cat delete_result.tmp | wc -l  )
			  deleted=`echo $deleted | tr -d " "`
			  echo "########## deleted=$deleted"   >>debug.log
			  if [ "$deleted" == "0" ]
			  then
			    prints " Account deleted ...." "ldap_delete_utility" "2"
				  prints " Ldap delete is working properly " "ldap_delete_utility" "2"
				  Result=0
				  prints "Testing of ldapdelete utility is successful" "ldap_delete_utility"  2
			  else			
          prints " Account is not deleted ...." "ldap_delete_utility" "1"
				  prints " Ldap delete is not working " "ldap_delete_utility" "1"
				  Result=1
				  prints "Testing of ldapdelete utility is failed" "ldap_delete_utility"  1
			  fi				 
}         

#######################logging enhancement functions###########################################
function logging_enhancement_test(){
    logtype=$1
		fhc=$(grep -i  fromhost  $logtype |wc -l)
		fpc=$(grep -i  fromport  $logtype |wc -l)
		echo "########## fhc=$fhc" 
		echo "########## fpc=$fpc" 
		
		echo "########## fhc=$fhc"  >>debug.log
		echo "########## fpc=$fpc"  >>debug.log
		type_imap=$(echo $logtype|grep -i imap|wc -l)
		type_pop=$(echo $logtype|grep -i pop|wc -l)
		type_mta=$(echo $logtype|grep -i mta|wc -l)
		echo "########## type_imap=$type_imap" >>debug.log
		echo "########## type_pop=$type_pop" >>debug.log
		echo "########## type_mta=$type_mta" >>debug.log
		if [ $type_imap -eq 1 ]
		then
			flag=imap 
		elif [ $type_pop -eq 1 ]
		then
		  flag=pop
		else
			flag=mta
		fi
		
		
		if [ $fhc -eq $fpc ];then
		  	 prints "logging enhancement for $flag is success" "TC_logging_enhancement_imap"  2 
		  	 Result=0 
		else
		  	 prints "logging enhancement for $flag is failed" "TC_logging_enhancement_imap"  1
		  	 Result=1
		fi  
}          


####################special delete ######################
function special_delete_config_keys(){
    
    configkey=$1
    title=$2
		key_present=$(cat $INTERMAIL/config/config.db | grep -i $configkey | wc -l)
		key_present=`echo $key_present | tr -d " "`
		if [ "$key_present" == "1" ]
		then
			key_present_flag=0
		else
			key_present_flag=1
		fi
		echo "########## key_present_flag=$key_present_flag" >>debug.log
		if [ "$key_present_flag" == "0" ]
		then
			key_value=$(cat $INTERMAIL/config/config.db | grep -i $configkey | cut -d "[" -f2 | cut -d "]" -f1 | head -1)	
			key_value=`echo $key_value | tr -d " "`
			echo "########## key_value=$key_value" >>debug.log
			if [ "$key_value" == "true" ] 
			then
				prints "$configkey is set as true" "special_delete_config_keys_$title" "2"
				Result=0
			else
				prints "$configkey is set as false" "special_delete_config_keys_$title" "2"
				Result=0
			fi
		else
			prints "ERROR :$configkey not present. Please check manually." "special_delete_config_keys_$title" "1"
			Result=1
		fi
}   



function special_delete_case_pop() {
	
	
			user_name=$1
			set_config_keys "/*/mss/enableSpecialDelete" "true" "1"
			set_config_keys "/*/popserv/enableSpecialDelete" "true" "1"
				
			mail_send "$user_name" "small" "2"
			
			exec 3<>/dev/tcp/$POPHost/$POPPort
			echo -en "user $user_name\r\n" >&3
			echo -en "pass $user_name\r\n" >&3
			echo -en "list\r\n" >&3
			echo -en "dele 1\r\n" >&3
			echo -en "list\r\n" >&3
			echo -en "quit\r\n" >&3
			cat <&3 > special_delete.tmp
			echo "========== the content of special_delete.tmp" >>debug.log
			cat special_delete.tmp >> debug.log	 
			echo "============================================" >>debug.log
			
			imap_select "$user_name"
			check_msgs_imap=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2 )
			check_msgs_imap=$(echo $check_msgs_imap | tr -d " ")
			
			imboxstats_fn "$user_name"
			msg_exists_new=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
			msg_exists_new=$(echo $msg_exists_new | tr -d " ")
			echo "########## msg_exists_new=$msg_exists_new"  >>debug.log
			echo "########## check_msgs_imap=$check_msgs_imap" >>debug.log
			if [ "$msg_exists_new" == "$check_msgs_imap" ]
			then								
				prints "Special delete for POP is working fine" "special_delete_case_pop" "2"
				Result="0"
			else	
				prints "ERROR:Special delete for POP is not working fine. Please check manually." "special_delete_case_pop" "1"
				Result="1"
			fi
			set_config_keys "/*/popserv/enableSpecialDelete" "false" "1"
			set_config_keys "/*/mss/enableSpecialDelete" "false" "1"
}      



function special_delete_case_imap() {
	
			user_name=$1	
			set_config_keys "/*/mss/enableSpecialDelete" "true" "1"
			set_config_keys "/*/imapserv/enableSpecialDelete" "true" "1"
			
			mail_send "$user_name" "small" "2"
			
			imap_store "$user_name" "1" "+" "\Deleted" "INBOX"
			imap_expunge "$user_name"
			imap_select "$user_name"
			check_msgs_imap=$(cat imapselect.tmp | grep -i EXISTS | cut -d " " -f2 )
			check_msgs_imap=$(echo $check_msgs_imap | tr -d " ")
				
			pop_list "$user_name"
			check_msgs_pop=$(cat poplist.tmp | grep -i "messages" | cut -d " " -f2)
			check_msgs_pop=$(echo $check_msgs_pop | tr -d " ")
			
			imboxstats_fn "$user_name"
			msg_exists_new=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
			msg_exists_new=`echo $msg_exists_new | tr -d " "`
			echo "########## msg_exists_new=$msg_exists_new"  >>debug.log
			echo "########## check_msgs_pop=$check_msgs_pop"  >>debug.log
			if [ "$msg_exists_new" == "$check_msgs_pop" ]
			then								
				prints "Special delete for IMAP is working fine" "special_delete_case_imap" "2"
				Result="0"
			else	
				prints "ERROR:Special delete for IMAP is not working fine. Please check manually." "special_delete_case_imap" "1"
				Result="1"
			fi
			set_config_keys "/*/imapserv/enableSpecialDelete" "false" "1"
			set_config_keys "/*/mss/enableSpecialDelete" "false" "1"
} 

#####################Alias##################################
function create_alias () {
	
	if [ "$1" == "1" ]
	then
			user=$2
			useralias=$3
			imdbcontrol CreateAlias $user $useralias ${default_domain} >> debug.log
			prints "Created Alias $useralias for user $user" "create_alias"  2
			imboxstats_fn "$user" 
			msg_exists=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
			msg_exists=$(echo $msg_exists | tr -d " ")
			
			mail_send "$useralias" "small" "1"	"$user"			
			
			imboxstats_fn "$user" 
			msg_exists_new=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
			msg_exists_new=$(echo $msg_exists_new | tr -d " ")
			
			imboxstats_fn "$useralias" 
			msg_exists_new_alias=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
			msg_exists_new_alias=$(echo $msg_exists_new_alias | tr -d " ")
			
			total_count=$(($msg_exists+1))
			
			echo "########## msg_exists_new=$msg_exists_new" >>debug.log
			echo "########## msg_exists_new_alias=$msg_exists_new_alias" >>debug.log
			echo "########## total_count=$total_count" >>debug.log
			if [[ "$msg_exists_new" == "$msg_exists_new_alias" && "$msg_exists_new_alias" == "$total_count" ]]
			then
				prints "Alias creation is working fine" "create_alias" "2"
				Result="0"
			else
				prints "ERROR:Alias creation is not working fine. Please restart manually." "create_alias" "1"
				Result="1"
			fi
	else
				user=$2
				useralias1=$3
				useralias2=$4
				useralias3=$5
				useralias4=$6
				
				imboxstats_fn "$user" 
				msg_exists=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
				msg_exists=$(echo $msg_exists | tr -d " ")
				
				for (( i=1;i<=4;i++ ))
				do
					temp=useralias$i
					imdbcontrol CreateAlias $user $temp ${default_domain} >> debug.log
				done
				imdbcontrol ListAliases $user ${default_domain} >> debug.log
				
				for (( i=1;i<=4;i++ ))
				do
					temp=useralias$i
					mail_send "$temp" "small" "1"	"$user"	
				done
				imboxstats_fn "$user" 
				msg_exists_new=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
				msg_exists_new=$(echo $msg_exists_new | tr -d " ")
				
				for (( i=1;i<=4;i++ ))
				do
					temp=useralias$i
					imboxstats_fn  $temp
					eval msg_exists_new_alias$i=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2|tr -d " ")
				done
				
				echo "########## msg_exists_new=$msg_exists_new" >>debug.log
				echo "########## msg_exists_new_alias1=$msg_exists_new_alias1" >>debug.log
				echo "########## msg_exists_new_alias2=$msg_exists_new_alias2" >>debug.log
				echo "########## msg_exists_new_alias3=$msg_exists_new_alias3" >>debug.log
				echo "########## msg_exists_new_alias4=$msg_exists_new_alias4" >>debug.log
				 
				
				if [[ "$msg_exists_new" == "$msg_exists_new_alias1" && "$msg_exists_new_alias1" == "$msg_exists_new_alias2" && "$msg_exists_new_alias2" == "$msg_exists_new_alias3" && "$msg_exists_new_alias3" == "$msg_exists_new_alias4" ]]
				then
					prints "Multiple Alias creation is working fine" "multiple_alias" "2"
					Result="0"
				else
					prints "ERROR:Multiple Alias creation is not working fine. Please restart manually." "multiple_alias" "1"
					Result="1"
				fi
	
	fi				
					
}                                         


function delete_alias () {
	if [ "$1" == "1" ]
	then
		user=$2
		aliasname=$3
		imdbcontrol DeleteAlias $aliasname ${default_domain} > Alias.tmp
		echo "========== the content of Alias.tmp ==========" >>debug.log
		cat Alias.tmp >>debug.log
		echo "==============================================" >>debug.log
		msg_no=$(cat Alias.tmp | grep "ERROR" | wc -l)
		echo "########## msg_no=$msg_no" >>debug.log
		if [ "$msg_no" == "0" ]
		then
			prints "Alias deletion is working fine" "delete_alias" "2"
			Result="0"
		else
			prints "ERROR:Alias deletion is not working fine. Please restart manually." "delete_alias" "1"
			Result="1"
		fi	
	
	else
	  user=$2
		useralias1=$3
		useralias2=$4
		useralias3=$5
		useralias4=$6
		
		for (( i=1;i<=4;i++ ))
		do
			temp=useralias$i
			imdbcontrol DeleteAlias $temp ${default_domain} >delealias.tmp
			echo "========== the contnet of delealias.tmp ==========" >>debug.log
			cat delealias.tmp >>debug.log
			echo "==================================================" >>debug.log
		done
		
	
		check_deletealias=$(imdbcontrol ListAliases $user ${default_domain}|tr -d " ")
		
		echo "########## check_deletealias=$check_deletealias" >>debug.log
	
	 	if [ "$check_deletealias" == "" ]
	 	then
			prints "All the alias are deleted" "multiple_alias" "2"
		else
			prints "All the alias are not deleted" "multiple_alias" "1"
		fi
	fi
}



####################remote forward ###########################
function create_remote_fwd () {
		user1=$1
		user2=$2
					
		imboxstats_fn "$user2" 
		msg_exists=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
		msg_exists=`echo $msg_exists | tr -d " "`
		
		imdbcontrol CreateRemoteForward $user1 ${default_domain} $user2@${default_domain} > crerfd.tmp
		echo "========== the content of  crerfd.tmp ==========" >>debug.log
		cat  crerfd.tmp >>debug.log
		echo "================================================" >>debug.log
		imdbcontrol EnableForwarding $user1 ${default_domain}
		
		mail_send "$user1" "small" "2"	
		#list_remote_fwd	 $user1 $user2	
		msg_fwd=$(imdbcontrol ListAccountForwards $user1 ${default_domain} | grep "$user2"| wc -l)
		
		imboxstats_fn "$user2" 
		msg_exists_new=$(cat log_imboxstats.tmp | grep -i "Total Messages Stored" | cut -d ":" -f2)
		msg_exists_new=`echo $msg_exists_new | tr -d " "`
		
		total_count=$(($msg_exists+2))
		echo "########## msg_fwd=$msg_fwd" >>debug.log
		echo "########## total_count=$total_count"  >>debug.log
		echo "########## msg_exists_new=$msg_exists_new" >>debug.log
		
		if [[ "$msg_fwd" == "1" && "$total_count" == "$msg_exists_new" ]]
		then
			prints "Create account forward is working fine" "create_remote_fwd" "2"
			Result="0"
		else
			prints "ERROR:Create account forward is not working fine. Please check manually." "create_remote_fwd" "1"
			Result="1"
		fi
		
}

function list_remote_fwd() {
    
    uuser1=$1
    uuser2=$2
		msg_fwd=$(imdbcontrol ListAccountForwards $uuser1 ${default_domain} | grep "$uuser2"| wc -l)
		echo "########## msg_fwd=$msg_fwd" >>debug.log
		if [ "$msg_fwd" == "1" ]
		then
			prints "List remote forward is working fine" "list_remote_fwd" "2"
			Result="0"
		else
			prints "ERROR:List remote forward is not working fine. Please restart manually." "list_remote_fwd" "1"
			Result="1"
		fi
}


function delete_remote_fwd () {

	  uuuser1=$1
	  uuuser2=$2
		imdbcontrol DeleteRemoteForward $uuuser1 ${default_domain} $uuuser2@${default_domain}
		msg_fwd=$(imdbcontrol ListAccountForwards $uuuser1 ${default_domain} | grep "$uuuser2"| wc -l)
		echo "########## msg_fwd=$msg_fwd" >>debug.log
		if [ "$msg_fwd" == "0" ]
		then
			prints "Delete account forward is working fine" "delete_remote_fwd" "2"
			Result="0"
		else
			prints "ERROR:Delete account forward is not working fine. Please check manually." "delete_remote_fwd" "1"
			Result="1"
		fi
		
}

#############domain related #############
function create_domain(){

		imdbcontrol cd beauty.com  &>> trash
		imdbcontrol ld &> domain.tmp
		
		check_domain=$(cat domain.tmp | grep -i "beauty.com"| wc -l )
		check_domain=$(echo $check_domain | tr -d " ")
		echo "########## check_domain=$check_domain" >>debug.log
		if [ $check_domain == "1" ]
		then
			prints "Created new domain 'beauty.com' " "TC_create_domain" "2"
			Result="0"
		else
			prints "ERROR: Not able to create new domain 'beauty.com'" "TC_create_domain" "1"
			prints "ERROR: Please check Manually." "TC_create_domain" "1"
			Result="1"
		fi
}


#####################Invalid_keyvalue_msslog  ###########################
function invalid_keyvalue_msslog_imap() {
				user1=$1
				#prints "################################################################" "invalid_keyvalue_msslog_imap" 
				prints "Check for [keepalive=1 Invalid key value] in mss log for IMAP" "invalid_keyvalue_msslog_imap"  2
				mail_send "$user1" "small" "2"
				exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
				echo -en "a login $user1 $user1\r\n" >&3
				echo -en "a logout\r\n" >&3
				cat <&3 > imap.tmp
				
													
				imconfcontrol -install -key "/*/mss/bogus1=12333240" &>> trash
				imconfcontrol -install -key "/*/mss/autoReplyExpireDays=20" &>> trash
				
				exec 3<>/dev/tcp/$IMAPHost/$IMAPPort
				echo -en "a login $user1 $user1\r\n" >&3
				echo -en "a logout\r\n" >&3
				cat <&3 >> imap.tmp
				echo "========== the content of imap.tmp ==========" >>debug.log
				cat imap.tmp >>debug.log
				echo "=============================================" >>debug.log
				
			 
			  msg_count=$(cat $INTERMAIL/log/mss.log | grep "keepalive=1 Invalid key value" | wc -l)
        echo "########## msg_count=$msg_count" >>debug.log											
				if [ "$msg_count" == "0" ]
				then
						prints "We are not able to see [keepalive=1 Invalid key value] in mss log for IMAP" "invalid_keyvalue_msslog_imap" "2"
						Result="0"
				else
				
						prints "We are able to see [keepalive=1 Invalid key value] in mss log for IMAP. Please check manually." "invalid_keyvalue_msslog_imap" "1"
						Result="1"
				
				fi 
			
								
}


function invalid_keyvalue_msslog_pop() {
				user1=$1
				prints "Check for [keepalive=1 Invalid key value] in mss log for POP" "invalid_keyvalue_msslog_pop" 2
			  prints "Sending mail to $user1" "invalid_keyvalue_msslog_pop" 
				mail_send "$user1" "small" "2"
				
				exec 3<>/dev/tcp/$POPHost/$POPPort
				echo -en "user $user1\r\n" >&3
				echo -en "pass $user1\r\n" >&3
				echo -en "quit\r\n" >&3
				
				
				imconfcontrol -install -key "/*/mss/bogus1=12333230" &>> trash
				imconfcontrol -install -key "/*/mss/autoReplyExpireDays=10" &>> trash
					
				exec 3<>/dev/tcp/$POPHost/$POPPort
				echo -en "user $user1\r\n" >&3
				echo -en "pass $user1\r\n" >&3
				echo -en "quit\r\n" >&3
				cat <&3 >pop.tmp
				echo "========== the content of pop.tmp ==========" >>debug.log
				cat pop.tmp >>debug.log
				echo "============================================" >>debug.log
			 
			  msg_count=$(cat $INTERMAIL/log/mss.log | grep "keepalive=1 Invalid key value" | wc -l)
				echo "########## msg_count=$msg_count" >>debug.log
				if [ "$msg_count" == "0" ]
				then
						prints "We are not able to see [keepalive=1 Invalid key value] in mss log for POP" "invalid_keyvalue_msslog_pop" "2"
						Result="0"
				else
						prints "We are able to see [keepalive=1 Invalid key value] in mss log for POP. Please check manually." "invalid_keyvalue_msslog_pop" "1"
						Result="1"
				
				fi
				
}

########## account_mode ###########
function account_mode_M() {
				user1=$1
				prints " Check for account mode M " "account_mode_M" 2							
				mail_send $user1 small 1							
			 	imdbcontrol SetAccountStatus $user1 ${default_domain} M 													
			  msg_sh=$(imdbcontrol gaf $user1 ${default_domain} | grep "Status" | cut -d ":" -f2| grep "M" | wc -l)
			  echo "########## msg_sh=msg_sh" >>debug.log										
				if [ "$msg_sh" == "1" ]
				then									
					prints "Mode M account for a user is working fine" "setaccount_status" "2"
					Result="0"
				else
					prints "ERROR:Mode M account for a user is not working fine" "setaccount_status" "1"								
					prints "ERROR: Please check Manually." "setaccount_status" "1"
					Result="1"
				fi						
							
}



# It is used to set the config keys #
function set_config_keys() {
	
	configkey_name=$1
	configkey_value=$2
	server_restart=$3
	
	if [ "$server_restart" == " " ]
	then
		server_restart_flag=0	
	else
		server_restart_flag=1
	fi
	
	imconfcontrol -install -key $configkey_name="$configkey_value" &> config_output.tmp
	echo "========== the content of config_output.tmp ==========" >>debug.log
	cat config_output.tmp >>debug.log
	echo "======================================================" >>debug.log
  key_added=$(imconfget -fullpath $configkey_name)
  configkey_value=`echo -ne $configkey_value `
  
  echo "########## key_added=$key_added" >>debug.log
	if [ "$key_added" == "$configkey_value" ] 
	then
		prints "$configkey_name is set" "set_config_keys" "debug" "2"
	else
    prints "ERROR : $configkey_name is not set" "set_config_keys" "1"	 
  fi
  echo "server_restart_flag=$server_restart_flag"   >>debug.log
	if [ "$server_restart_flag" == "1" ]
	then
		output_addconfig=$(cat config_output.tmp | grep -i "needs to be re-started" | wc -l)
		output_mss=$(cat config_output.tmp | grep -i "needs to be re-started" | grep -i  mss.1 | wc -l)
		output_imapserv=$(cat config_output.tmp | grep -i "needs to be re-started" | grep -i  imapserv | wc -l)
		output_popserv=$(cat config_output.tmp | grep -i "needs to be re-started" | grep -i  popserv | wc -l)
		
		echo "output_addconfig=$output_addconfig"  >>debug.log
		echo "output_mss=$output_mss"  >>debug.log
		echo "output_imapserv=$output_imapserv"  >>debug.log
		echo "output_popserv=$output_popserv"  >>debug.log
		if [ "$output_addconfig" -ge "1" ]
		then
			if [ "$output_mss" -ge "1" ]
			then
			  mssstartfail=1
			  #the loop tp avoid RmeClientTimeout error 
			  while [ "$mssstartfail" == "1" ]
			  do
			  	imctrl  allhosts  killStart mss   &> restart.tmp
				  mssstartfail=$(grep -i "RmeClientTimeout" restart.tmp|wc -l)
			  done
				
				prints " Restarting mss " "set_config_keys"
				#sleep 10
				msshosts=`imconfget -fullpath /*/common/groupDefinition  |head -2|tail -1|awk -F : '{print $2}'`
				number=`echo $msshosts|wc -w`
				echo "########## number=$number" >>debug.log
				total_mss=0 #used to judge id all mss has restarted successfully
				for (( i=1;i<=$number;i++))
				do
					msshost=`echo $msshosts|cut -d " " -f $i`
					imservping -h $msshost &> server.tmp
					mss1=$(cat server.tmp | grep -i "mss/mss.1 responded" |wc -l )
					let total_mss=total_mss+mss1
				done
				echo "########## total_mss=$total_mss"  >>debug.log
				echo "########## number=$number"  >>debug.log
				if [ "$total_mss" -eq "$number" ]
				then
					prints " MSS is restarted successfully" "set_config_keys" "2"
				else
					prints " MSS is not restarted successfully" "set_config_keys" "1"
				fi
			fi
			
			if [ "$output_imapserv" == "1" ]
			then
			  imctrl  allhosts  killStart imapserv  &>> restart.tmp
				prints " Restarting imapserv " "set_config_keys"
				imservping &> server.tmp
				imapserv1=$(cat server.tmp | grep -i "imapserv responded" |wc -l )
				echo "########## imapserv1=$imapserv1" >>debug.log
				if [ "$imapserv1" == "1" ]
				then
					prints " imapserv is restarted successfully" "set_config_keys" "2"
				else
					prints " imapserv is not restarted successfully" "set_config_keys" "1"
				fi
			fi
			echo "########## output_popserv=$output_popserv" >>debug.log
			if [ "$output_popserv" == "1" ]
			then
				imctrl  allhosts  killStart popserv  &>> restart.tmp
				prints " Restarting popserv " "set_config_keys"
				imservping &> server1.tmp
				popserv1=$(cat server1.tmp | grep -i "popserv responded" |wc -l)
				echo "########## popserv1=$popserv1" >>debug.log
				if [ "$popserv1" == "1" ]
				then
					prints " popserv is restarted successfully" "set_config_keys" "2"
				else
					prints " popserv is not restarted successfully" "set_config_keys" "1"
				fi
			fi

			if [[ "$output_mss" == "0"  && "$output_popserv" == "0" && "$output_imapserv" == "0" ]]
			then
			  imctrl  allhosts  killStart allservers  &>> restart.tmp
				prints " Restarting all Servers " "set_config_keys"
				imservping &> server.tmp
				allserv=$(cat server.tmp | grep -iv "responded" | wc -l )
				echo "########## allserv=$allserv" >>debug.log
				if [ "$allserv" == "0" ]
				then
					prints " All Servers are restarted successfully" "set_config_keys" "2"
				else
					prints " All Servers are not restarted successfully" "set_config_keys" "1"
				fi
				
			fi
			
		else
			prints "No need to restart the server for $configkey_name" "set_config_keys" 
		fi
		
	fi
	
}
