#!/bin/bash

expect_user=root
expect_pass=letmein

expect <<-EOF
log_file expect.log  
set timeout 120
spawn ssh $expect_user@10.49.58.239
expect {  
 "*yes/no"   { send "yes\r"; exp_continue }
 "*Password:" { send "$expect_pass\r" }
       }
expect  "*#" { send "su - imail\r" }

expect  "*$" { send "ls -al\r" }

exit
EOF