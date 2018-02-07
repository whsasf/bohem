#!/bin/bash

# this tool makes ssh automatically via expect tool. so expect must be installed on the hosts requests from .

expect <<-EOF
log_file expect.log  
set timeout $expect_timeout
spawn ssh $expect_user@${MX1_HOST_IP1}
expect {
 "*yes/no"   {send "yes\r"; exp_continue}
 "*Password:" {send "$expect_pass\r"}
}
expect "~*#" {send "su - $1\r"}
expect "~" {send "$2\r"}
expect "~" {send "date -s\r"}
expect "~" {send "ifconfig\r"}
expect "~" {send "exit\r"}
EOF

cal