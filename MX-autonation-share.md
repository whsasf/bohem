# **MX automation share**

 ---
## **Indexes**


- Automation in **new Imsanity** and one example
- One+ Automation example in **Body_preview**
- One+ Automation example in **Logging_enhancement**
- One Automation example in **Autoreply_enhancement -*Bohem* **
- summary
 ---
## **1 new Imsanity**

In new Imsanity testing,each testcase is **separated** in single location and independent to the rests.Each testcase is made up of 3 steps if it has:setup(prepare),test (run) ,cleanup ,which is inherited from **TTI**.

- **below shows the new Imsanity home folder structer containing test suits:**
![new Imsanity folder structer](/home/ram/Pictures/1.png  "new Imsanity folder structer")
---

- **below shows the test cases under SMTP_Auth:**
![test cases under SMTP_Auth](/home/ram/Pictures/2.png  "test cases under SMTP_Auth")

- **below shows the details of testcase  Auth_CRAM-MD5_success:**
![details of testcase  Auth_CRAM-MD5_success](/home/ram/Pictures/3.png  "details of testcase  Auth_CRAM-MD5_success")
---
### **Details of test scripts**
- ###**cat Setup.sh**
- ###**cat Test.sh**
- ###**cat Cleanup.sh**
---
### **Run testcases**
- mx-10-49-58-118:imail2:Mx9.5:~/Imsanity5.0.2$ **./mainimsanity_5.0.2.sh**
- mx-10-49-58-118:imail2:Mx9.5:~/Imsanity5.0.2$ ./**mainimsanity_5.0.2.sh   SMTP_Auth/**
- mx-10-49-58-118:imail2:Mx9.5:~/Imsanity5.0.2$ ./ 
**mainimsanity_5.0.2.sh   SMTP_Auth/Auth_CRAM-MD5_success/**
---
## **2 One+ Automation example in Body_preview**  

- **one from Imsanity**
- **one from old**

---
## **3 One+ Automation example in Logging_enhancement**  

- **direct and NAT**
- **proxy and XCLP**

---
## **4 One Automation example in Autoreply_enhancement -*Bohem* **  

- **single-between**

---
# **5 Summary from me**

- **Writing automation during testing(not before,not after)**
- **Use variables as much as possible and make them easy to change**
- **Independent echo testcase in test scripts as much as possible**
- **All current test structures of test suits i have been using are silimar(TTI,Bohen,Imsanity,IMAPCollider)**
- **when can we achieve the first real automation with installation, functional testing trigered by new HO release? **