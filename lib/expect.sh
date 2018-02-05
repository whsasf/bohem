#!/bin/bash

# this tool makes ssh automatically via expect tool. so expect must be installed on the hosts requests from .

expect <<-EOF

# record logs file
log_file expect.log  

set timeout $expect_timeout

spawn ssh $expect_user@${MX1_HOST_IP1}

# enter password
expect {  
 "*yes/no"   { send "yes\r"; exp_continue }
 "*Password:" { send "$expect_pass\r" }
       }
#switch to target account
expect  "*#" { send "su - "$argv 1" \r" }       

#do all operations
for (( i=2;i<=$#;i++))
do       
expect  "*$" { send "$argv 2\r" }  
done
exit
EOF