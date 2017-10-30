#!/usr/local/bin/python

from selenium import selenium
import time, re 
import sys, os


##########################################################################
########     Tools that can be used in test scripts    ###################
##########################################################################
class cp_selenium(selenium):

    def __init__(self):
        self.pshost=str(os.environ.get("PS1_HOST"));
        self.psport=str(os.environ.get("PS1_PORT"));
        self.seleniumhost=str(os.environ.get("SELENIUM_HOST"));
        self.seleniumport=str(os.environ.get("SELENIUM_PORT"));
        self.tcname=str(os.environ.get("TC_NAME"));
        self.browser=str(os.environ.get("SELENIUM_BROWSER"));
    
        self.start_time=int(time.time());

        if self.browser == "None":
            print "No Browser set in environment, setting browser to default (firefox)"
            self.browser="*firefoxproxy"

        print "Checking if PS1_HOST PS1_PORT SELENIUM_HOST SELENIUM_PORT SELENIUM_BROWSER are set"
        if (self.pshost != "") or (self.psport != "") or (self.browser != "") or (self.seleniumhost != "") or (self.seleniumport != ""):
            print "Initializing Selenium..."
            selenium.__init__(self, self.seleniumhost, self.seleniumport, self.browser , "http://"+self.pshost+":"+self.psport)        
        else:
            raise Exception("There are unset selenium variables, test case cannot continue")

        self.start()

    def __del__(self):
        if(self.sessionId != None):
            self.stop()        

    def login(self, domain, user, password):
        print "Logging in with user "+user+"@"+domain

        self.open("/cp/ps/Main/login/Login?d="+domain)
        print "Entering username and password"
        self.wait_for_element("usrField", 30)
        self.type("usrField", user)
        self.type("password", password)
        print "Clicking Submit"
        self.click("submitName")
        self.wait_for_page_to_load("60000")
        time.sleep(2);

        # The rest of this function checks the status bar at the top right, to see if the loading logo is present

        print "Looking for loading image and waiting until it disappears!" 
        # roughly 60 second timeout
        for i in range(1,60):
            # Check if either 8.0 or 8.5 loading image is showing
            if self.is_element_present("//span[@id='MetaNavWorking']/img"):
                element_string="//span[@id='MetaNavWorking']/img"
                break
            elif self.is_element_present("//table[@id='Status0']/tbody/tr/td[1]/span/img"):
                element_string="//table[@id='Status0']/tbody/tr/td[1]/span/img"
                break

            time.sleep(1)
        else:
             raise Exception("Failed to find page loading image")

        _count = 0;

        for i in range(1,30):
            if self.is_element_present(element_string) and not self.is_visible(element_string):
                _count = _count + 1;
            else:
                _count = 0

            if _count == 3:
                print "Finished Loading"
                break

            time.sleep(1)
            print "waiting for page to load"
        else:
            raise Exception("Page Failed to load")

    def attempt_login(self, domain, user, password):
        print "Logging in with user "+user+"@"+domain

        self.open("/cp/ps/Main/login/Login?d="+domain)
        print "Entering username and password"
        self.wait_for_element("usrField", 30)
        self.type("usrField", user)
        self.type("password", password)
        print "Clicking Submit"
        self.click("submitName")
        self.wait_for_page_to_load("30000")

    def logout(self):
        print "Logging out"
        if self.is_element_present("//table[@id='Status0']/tbody/tr/td[6]/span"):
                self.click("//table[@id='Status0']/tbody/tr/td[6]/span")
        else:
                self.click("//span[@onclick='if (window.MetaNav) MetaNav.logout();']")
        time.sleep(3)
        self.search_for_confirmation("Are you sure you want to log out of your account", 30)

    def logout_reset(self):
        print "Logging out"
        if self.is_element_present("//table[@id='Status0']/tbody/tr/td[6]/span"):
                self.click("//table[@id='Status0']/tbody/tr/td[6]/span")
        else:
                self.click("//span[@onclick='if (window.MetaNav) MetaNav.logout();']")
        time.sleep(3)
        self.search_for_confirmation("Are you sure you want to log out of your account", 30)
        self.stop()
        self.start()

    # this function verifies that text, "text", is contained in a specific location, "location"
    def check_location_for_text(self, location, text):
        text1 = self.get_text(location)
        if text1 == text:
           print ""+text1 + " matches " + text
        else:
           raise Exception(""+text1 + " does not match " + text )

    # this fucntion will put a selected mail into the first new folder that you have created
    # TODO make the folder selectable
    def move_mail_new_folder(self, id):
       self.click("//div[2]/div/div/div[1]/div[1]/nobr/span")
       time.sleep(2)
       lid = int(id)+1
       lid = str(lid)
       self.click("//html/body/div/div[4]/div/div/div["+lid+"]/table/tbody/tr/td/input")
       self.select("mailMessageSelectAction", "label=Move")
       time.sleep(2)
       self.click("//div[6]/nobr/input")
       self.click("//html/body/div/table[2]/tbody/tr/td[2]/div/div/div[3]/a")

    # this function will add a new mail folder by using the drop down menu on the right
    def add_mail_folder(self, name):
        print "Adding a new mail folder" + name
        self.click("//div[2]/div/div/div[1]/div/nobr/span")
        self.click("mailTreeMenuButton")
        self.click("//html/body[@id='psBody']/div[@id='_CP_PS_MENU']/a[1]")
        self.type("//input[@type='text']", ""+name);
        self.click("link=OK")
        self.click("//div[2]/div/div/div[1]/div/nobr/span")

    # This function will run a shell command. I takes one argument <command to run>
    def run_shell(self, command):
        sys.stdout.flush()
        out = os.system(command)
        print out
        if out:
           raise Exception("FAILED: shell command \""+command+"\" exited with non zero error")

    # This function will send a mail through the smtp port. It runs sendmail.pl in a sheel and it 
    # takes sender, recipient and the filename for the message as arguments
    def sendmail_smtp(self, sender, recip, filename):
        self.run_shell("sendmail.pl $CPMS1_HOST $CPMS1_SMTP_PORT "+  sender+ " " + recip + " <"+filename)

    def sendmail_ui(self, recip, subject, body):
        print "send a mail to recipient " +recip
        self.click("metaNavTabLinkMail")
        time.sleep(15)
        self.click("//a[@onclick='MailToolbar.newMailMenuHandler(this)']")
        self.click("//a[@onclick=\"MailToolbar.messageActionClick('COMPOSE_NEW')\"]")
        self.type("//tr[2]/td[2]/input", ""+recip)
        self.type("//tr[5]/td[2]/input", ""+subject)
        self.type("messageComposeTextarea", ""+body)
        self.click("//a[@onclick='MessageCompose.handleSend()']")
        time.sleep(15)

    # A function to search for a confirmation window (e.g. a contact delete pop-up) with given text

    def search_for_confirmation(self, con_string, timeout):
        print "Searching for confirmation pop up containing text \""+con_string+"\""
        for i in range(1,timeout):
            try:
                re.search(con_string, self.get_confirmation())
                print "Found confirmation containing text: "+con_string
                break
            except Exception, e:
                print "waiting for 1 second"
                time.sleep(1)
        else:
            raise Exception("Failed to get confirmation containing text \""+con_string+"\"")

    def assert_no_alert(self):
        print "Searching for alert" 
        self.select_window("null")
        for i in range(1,30):
            if self.is_alert_present():
                raise Exception("Found alert!!!")
            print "waiting for 1 second"
            time.sleep(1)
        else:
            print "No Alert Found"

    # A function to search for an alert window (e.g. message moved to drafts) with given text

    def search_for_alert(self, alert_string, timeout):
        print "Searching for alert pop up containing text \""+alert_string+"\""
        for i in range(1,timeout):
            try:
                found_alert = self.get_alert()
                re.search(alert_string, found_alert)
                print "Found alert: "+found_alert
                break
            except Exception, e:
                print "waiting for 1 second"
                time.sleep(1)
        else:
            raise Exception("Failed to get alert containing text \""+alert_string+"\"")
            
    # added 2 wait_for elements that throw an exception if they don't find an element/text within a given timeout

    def wait_for_element(self,element_string,timeout):
        print "Checking for element "+element_string+" with a timeout of "+str(timeout)+" seconds"
        for i in range(1,timeout):
            if self.is_element_present(element_string) and self.is_visible(element_string):
                print "Found it"
                break

            time.sleep(1)
            print "waiting for 1 second"
        else:
            raise Exception("failed to find element "+element_string)

    def wait_for_text(self,string_to_test, timeout): 
        print "Checking for string "+string_to_test+" with a timeout of "+str(timeout)+" seconds"
        for i in range(1,timeout):
            if self.is_text_present(string_to_test):
                print "Found it"
                break

            time.sleep(1)
            print "waiting for 1 second"
        else:
            raise Exception("failed to find string "+string_to_test)

    def wait_for_text_loc(self,element_string,string,timeout):
        print "Checking for string "+string+" at "+element_string+" with a timeout of "+str(timeout)+" seconds"
        self.wait_for_element(element_string, 30)
        for i in range(1,timeout):
            if string == self.get_text(element_string):
                print "Found it"
                break

            time.sleep(1)
            print "waiting for 1 second"
        else:
            raise Exception("failed to find string "+string+" at "+element_string)

    def verify_no_text(self,string_to_test):
        print "Checking for string "+string_to_test
        if self.is_text_present(string_to_test):
            raise Exception("Found "+string_to_test+" when it shouldn't be there")

    def verify_element_present(self,string_to_test):
	print "Checking for element "+string_to_test
	if not self.is_element_present(string_to_test):
	    raise Exception("Did not find "+string_to_test+" when it should be there")

    def verify_element_not_present(self,string_to_test):
        print "Checking for element "+string_to_test
        if self.is_element_present(string_to_test):
            raise Exception("Found "+string_to_test+" when it shouldn't be there")

    # Waits for input to become editable    

    def wait_for_editable(self, field, timeout): 
        print "Checking if "+field+" is editable with a timeout of "+str(timeout)+" seconds"
        for i in range(1,timeout):
            if self.is_editable(field):
                print "Found it"
                break
 
            time.sleep(1)
            print "waiting for 1 second"
        else:
            raise Exception(field+" is not editable")

    # Added assertEqual function that throws an exception if the 2 string inputs are different

    def assertEqual(self,string1,string2):
        print "Checking if "+string1+" matches "+string2
        if(string1 != string2):
            raise Exception(string1+" does not match "+string2)
        else:
            print "strings match!"
    

    # This function is needed as the address book search returns values in a seemingly random order
    # i.e. the Address Book doesn't appear in the same place every time

    def find_pab_address_book(self, ab_name):
        print "Looking for address book with name: "+ab_name
        for i in range(1,10):
            if ab_name == self.get_text("//div[@id=\'panel_10"+str(i)+"\']/form/table/tbody/tr/td[8]/nobr/span"):
                print "Found Address book at position: "+str(i)
                return i
        else:
            raise Exception("Cannot find Address Book")

    # This uses the previous function to verify the address book details

    def verify_address_book_found(self, ab_name, status):
        print "Verifying that "+ab_name+" has status "+status
        ab_number = self.find_pab_address_book(ab_name)
        print "Status of AB is "+self.get_text("//div[@id=\'panel_10"+str(ab_number)+"\']/form/table/tbody/tr/td[11]/nobr/span")
        if self.get_text("//div[@id=\'panel_10"+str(ab_number)+"\']/form/table/tbody/tr/td[11]/nobr/span") != status:
            raise Exception("Status of Address Book is wrong")
        
    # This uses find_pab_address_book to click the address book clickbox

    def click_found_address_book(self, ab_name):
        self.click("chkContactpanel_10"+str(self.find_pab_address_book(ab_name)))

    # Added log_pass and log_fail functions that mirror bohems log_pass log_fail
    def log_pass(self,log_string):
        end_time=int(time.time());
        time_taken=end_time-self.start_time;
        print "TESTPASSED: "+self.tcname+": "+log_string+" ("+str(time_taken)+" sec.)";
        sys.exit(0)

    def log_fail(self,log_string):
        end_time=int(time.time());
        time_taken=end_time-self.start_time;
        print "TESTFAILED: "+self.tcname+": "+log_string+" ("+str(time_taken)+" sec.)";
        sys.exit(1)

    # This verifies that an element top postition is equal to value

    def verify_element_position_top(self, element, value):
        print "Verifiying that the position of "+element+" from the top is "+value
        if self.assertEqual(value, self.get_element_position_top(element)):
            raise Exception("Top position of "+element+" is not equal to "+value)

