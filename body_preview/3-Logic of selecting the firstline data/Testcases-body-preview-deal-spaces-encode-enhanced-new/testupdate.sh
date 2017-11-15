#!/bin/bash
sed -i '/#IMAP/a\bash logic-messagesend-IMAP-append-7bit.sh\nbash logic-messagesend-IMAP-append-8bit.sh\nbash logic-messagesend-IMAP-append-base64.sh\nbash logic-messagesend-IMAP-append-quoted.sh\n' testcase-run.sh
sed -i '/#SMTP/a\bash logic-messagesend-SMTP-7bit.sh\nbash logic-messagesend-SMTP-8bit.sh\nbash logic-messagesend-SMTP-base64.sh\nbash logic-messagesend-SMTP-quoted.sh\n' testcase-run.sh

sed -i '/#IMAP/d' testcase-run.sh
sed -i '/#SMTP/d' testcase-run.sh

