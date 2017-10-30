#!/usr/bin/env python

import smtplib
import sys, getopt
import os

def main(argv):
    server=''
    port='587'
    sender=''
    password=''
    recipient=''
    message_file=''
    ehlo_domain=None
    use_starttls = False
    msg=''

    try:
        opts, args = getopt.getopt(argv,"",["server=","port=","sender=","password=","recipient=","message=","ehlo-domain=","starttls"])
    except getopt.GetoptError:
        print 'sendmail.py ....'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'sjdfjls'
            sys.exit()
        elif opt in ("--server"):
            server = arg
        elif opt in ("--port"):
            port = arg
        elif opt in ("--sender"):
            sender = arg
        elif opt in ("--password"):
            password = arg
        elif opt in ("--recipient"):
            recipient = arg
        elif opt in ("--starttls"):
            use_starttls = True
        elif opt in ("--ehlo-domain"):
            ehlo_domain = arg
        elif opt in ("--message"):
            message_file = arg

    if recipient == '':
        print 'sendmail.py .... specify recipient'
        sys.exit(4)

    if server == '':
        print 'sendmail.py .... specify server'
        sys.exit(4)

    if message_file == '':
        for line in sys.stdin:
            msg += line

    elif os.path.isfile(message_file):
        f = open(message_file, 'r') 
        for line in f:
            msg += line
        f.close()

    # Pull off the sender's domain
    if ehlo_domain == None:
        sender_bits = sender.split('@')
        ehlo_domain = sender_bits[1]

    server = smtplib.SMTP(server, port)
    server.set_debuglevel(1)
    server.ehlo(ehlo_domain)
    if use_starttls == True:
        server.starttls()
        try:
            server.ehlo(ehlo_domain)
        except:
            print 'ERROR: Connection dropped after STARTTLS'
            sys.exit(5)
    if password != '':
        server.login(sender, password)
    server.sendmail(sender, recipient, msg)
    server.quit()

main(sys.argv[1:])


