# coding: utf-8 

# Run "python report.py" to generate the mxos test result summay

file_in=open('summary.log','rb')

feature_list=[
"Domain",
"Mailbox",
"Cos",
"Folder",
"Message",
"Notify",
"Address Book",
"Tasks",
]

suite_list=[
["Mailbox","Authenticate.xlsx",0,0],
["Cos","CosInternalInfo.xlsx",0,0],
["Domain","BaseAllowedDomainAPI.xlsx",0,0],
["Notify","BaseNotificationMailSentStatus.xlsx",0,0],
["Cos","CosBase.xlsx",0,0],
["Cos","CosCalendarFeatures.xlsx",0,0],
["Cos","CosCredentials.xlsx",0,0],
["Cos","CosExternalAccount.xlsx",0,0],
["Cos","CosExternalStore.xlsx",0,0],
["Cos","CosGeneralPreferance.xlsx",0,0],
["Cos","CosMailRealm.xlsx",0,0],
["Cos","CosMailReceiptSenderBlocking.xlsx",0,0],
["Cos","CosMailReceiptSieveFilters.xlsx",0,0],
["Cos","CosMailsend.xlsx",0,0],
["Cos","CosMailStore.xlsx",0,0],
["Cos","CosMessageEventRecords.xlsx",0,0],
["Cos","CosSmsonline.xlsx",0,0],
["Cos","CosSmsServices.xlsx",0,0],
["Cos","CosSocialNetwork.xlsx",0,0],
["Cos","CosWebMailFeaturesAddressBookOptions.xls",0,0],
["Cos","CosWebMailFeaturesAddressBook.xls",0,0],
["Cos","CosWebMailFeatures.xlsx",0,0],
["Cos","CosMailReceipt.xlsx",0,0],
["Cos","CosMailAccess.xlsx",0,0],
["Cos","Cossendblock.xlsx",0,0],
["Mailbox","Credentials.xlsx",0,0],
["Mailbox","DataStore.xlsx",0,0],
["Domain","Domain.xlsx",0,0],
["Mailbox","EmailAliasesAPI.xlsx",0,0],
["Mailbox","ExtendedEamilAliases.xlsx",0,0],
["Mailbox","ExternalAccount.xlsx",0,0],
["Mailbox","ExternalMailAccount.xlsx",0,0],
["Mailbox","ExternalStore.xlsx",0,0],
["Folder","FolderAPI.xlsx",0,0],
["Mailbox","GeneralPreferance.xlsx",0,0],
["Mailbox","GroupAdminAllocations.xlsx",0,0],
["Mailbox","InternalInfoCos.xlsx",0,0],
["Mailbox","LastSuccessfulLoginDate.xlsx",0,0],
["Mailbox","MaiboxEncryptedPassword.xlsx",0,0],
["Mailbox","MailSendBmiFilter.xlsx",0,0],
["Mailbox","MailAccessAllowedIps.xlsx",0,0],
["Mailbox","MailAccessCos.xlsx",0,0],
["Mailbox","MailAccess.xlsx",0,0],
["Mailbox","MailboxBaseAPI.xlsx",0,0],
["Mailbox","MailboxRealm.xlsx",0,0],
["Mailbox","MailReceiptAddressesForLocalDelivery.xlsx",0,0],
["Mailbox","MailReceiptAllowedSendersList.xlsx",0,0],
["Mailbox","MailReceiptBmiFilters.xlsx",0,0],
["Mailbox","MailReceiptCloudmarkFilters.xlsx",0,0],
["Mailbox","MailReceiptCommTouchFilters.xlsx",0,0],
["Mailbox","MailReceiptCos.xlsx",0,0],
["Mailbox","MailReceiptForwardAddress.xlsx",0,0],
["Mailbox","MailReceiptMcAfeeFilters.xlsx",0,0],
["Mailbox","MailReceiptRazorgateFilters.xlsx",0,0],
["Mailbox","MailReceiptSenderBlocking.xlsx",0,0],
["Mailbox","MailReceiptSieveBlockedSenders.xlsx",0,0],
["Mailbox","MailReceiptSieveFilters.xlsx",0,0],
["Mailbox","MailReceipt.xlsx",0,0],
["Mailbox","MailsendBmiFilter.xlsx",0,0],
["Mailbox","MailsendCommtouchFilter.xlsx",0,0],
["Mailbox","MailSendDeliveryMessagesPending.xlsx",0,0],
["Mailbox","MailsendMcAfeeFilter.xlsx",0,0],
["Mailbox","MailSendSignature.xlsx",0,0],
["Mailbox","MailSend.xlsx",0,0],
["Mailbox","MailStoreAttributes.xlsx",0,0],
["Mailbox","MailStore.xlsx",0,0],
["Mailbox","MailSendMcAfeeFilter.xlsx",0,0],
["Mailbox","MessageEventRecords.xlsx",0,0],
["Mailbox","MailboxHoh.xlsx",0,0],
["Notify","Notify.xlsx",0,0],
["Notify","SmsNotification.xlsx",0,0],
["Mailbox","SmsOnline.xlsx",0,0],
["Mailbox","SmsServices.xlsx",0,0],
["Mailbox","SocialNetworkSite.xlsx",0,0],
["Mailbox","SocialNetwork.xlsx",0,0],
["Mailbox","WebMailFeaturesAddressBookOptions.xls",0,0],
["Mailbox","WebMailFeaturesAddressBook.xls",0,0],
["Mailbox","WebMailFeaturesCalendar.xlsx",0,0],
["Mailbox","WebMailFeaturesExternalCalendar.xlsx",0,0],
["Mailbox","WebMailFeatures.xlsx",0,0],
["Mailbox","MailSendCommtouchFilter.xlsx",0,0],
["Mailbox","authenticateAndGetMailbox.xlsx",0,0],
]

def log_suite_result(suite_name,passed,failed):
    suite_find=0
    for suite in suite_list:
        if suite[1] == suite_name:
            suite[2]=passed
            suite[3]=failed
            return
    if suite_find ==0 :
        print suite_name+ " not find in suite list"

def display_feature_report():
    print "********************Feature List Details**********************"
    for feature in feature_list:
        feature_pass=0
        feature_fail=0

        for suite in suite_list:
            if suite[0] == feature:
                feature_pass = feature_pass + suite[2]
                feature_fail = feature_fail + suite[3]
                #print suite[1]+"  "+str(suite[2])+"  "+str(suite[3])
        
        print feature+" "+str(feature_pass)+" "+str(feature_fail)
    print "********************Feature List Details**********************"


file_name=''
line_before=''
failed_num=9999
passed_num=9999

for line in file_in.readlines():
    
    if line.find('.xlsx') >0 :
        if failed_num!=9999 and failed_num >0:
            print '\r\n'
            print '****************'+file_name+'****************'
            print '****** Failed case count in the suite: '+str(failed_num)+' ******\n'
        if(passed_num!=9999):
            log_suite_result(file_name,passed_num,failed_num)
            
        passed_num=0
        failed_num=0
        file_name=line[line.rfind('/')+1:]
        file_name=file_name.strip()
        #print file_name
    elif line.find('TEST : FAIL')>0 :
        failed_num=failed_num+1
        if line_before.find('=====')>0 :
            print line[line.find('=====')+14:line.rfind('TEST')]
    elif line.find("TEST : PASS")>0:
        passed_num = passed_num+1
        

    line_before=line
#end for read lines

file_in.close()

#print final failed number
if failed_num!=9999 and failed_num >0:
    print '\r\n'
    print '****************'+file_name+'****************'
    print '****** Failed case count in the suite: '+str(failed_num)+' ******\n'

#log the last test suite file result
log_suite_result(file_name,passed_num,failed_num)

#show the report the feature list
display_feature_report()