#!/bin/bash

for file in $(find .|grep test_run)
do
	sed -i 's/expect1.log/expect.log/g' $file
		sed -i 's/expect2.log/expect.log/g' $file
			sed -i 's/expect3.log/expect.log/g' $file
				sed -i 's/expect4.log/expect.log/g' $file
					sed -i 's/expect5.log/expect.log/g' $file
						sed -i 's/expect6.log/expect.log/g' $file
							sed -i 's/expect7.log/expect.log/g' $file
								sed -i 's/expect8.log/expect.log/g' $file
									sed -i 's/expect9.log/expect.log/g' $file
								
#	sed -i 's/whsasf.com/\$newdomain/g' $file
	
done