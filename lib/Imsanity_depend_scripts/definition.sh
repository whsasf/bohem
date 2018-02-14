#!/bin.bash

#definition function 
#function definition ()
  
#define test scripts names
function Definition (){
		echo "======================== Definations ========================================"
		echo "|define: Setup=Setup.sh                                  "
		echo "|define: Test=Test.sh                                    "
		echo "|define: Cleanup=Cleanup.sh                              " 
		echo "|define: Title=Printtitle.sh                             " 
		echo "|define: summarylog=$roothome/summary.log                   "
		echo "|define: debuglog=$roothome/debug.log                       "  
		echo "|define: smpl=$roothome/System_depend_scripts/sm.pl                               " 
		echo "|define: Alltestcasestimetxt=$roothome/System_bak/Alltestcasestime.txt "
		echo "|define: message_template_1K=$roothome/System_Msg_templates/1K                   "
		echo "|define: message_template_100K=$roothome/System_Msg_templates/100K               "
		echo "|define: message_template_200K=$roothome/System_Msg_templates/200K               "
		echo "|define: message_template_1MB=$roothome/System_Msg_templates/1MB                 "
		echo "|define: message_template_10MB=$roothome/System_Msg_templates/10MB               "
		echo "|define: doc32k=$roothome/System_Msg_templates/32k-mime_doc                      "
		echo "|define: pdf64k=$roothome/System_Msg_templates/64k-mime_pdf                      "
		#echo "|define: header1_txt=$roothome/System_Msg_templates/header1.txt                  "
		#echo "|define: header2_txt=$roothome/System_Msg_templates/header2.txt                  "
		#echo "|define: header3_txt=$roothome/System_Msg_templates/header3.txt                  "
		echo "|define: imaplog=$INTERMAIL/log/imapserv.log             "
		echo "|define: poplog=$INTERMAIL/log/popserv.log               "
		echo "|define: mtalog=$INTERMAIL/log/mta.log                   "
		
		Setup=Setup.sh
		Test=Test.sh
		Cleanup=Cleanup.sh
		Title=Printtitle.sh 
		summarylog=$roothome/summary.log
		debuglog=$roothome/debug.log
		smpl=$roothome/System_depend_scripts/sm.pl
		message_template_1K=$roothome/System_Msg_templates/1K
		message_template_100K=$roothome/System_Msg_templates/100K
		message_template_200K=$roothome/System_Msg_templates/200K
		message_template_1MB=$roothome/System_Msg_templates/1MB
		message_template_10MB=$roothome/System_Msg_templates/10MB
		doc32k=$roothome/System_Msg_templates/32k-mime_doc
		pdf64k=$roothome/System_Msg_templates/64k-mime_pdf
		Alltestcasestimetxt=$roothome/System_bak/Alltestcasestime.txt
		#header1_txt=$roothome/System_Msg_templates/header1.txt 
		#header2_txt=$roothome/System_Msg_templates/header2.txt 
		#header3_txt=$roothome/System_Msg_templates/header3.txt 
		imaplog=$INTERMAIL/log/imapserv.log
		poplog=$INTERMAIL/log/popserv.log
		mtalog=$INTERMAIL/log/mta.log
		echo "======================== Definations end ===================================="
}