#!/bin/bash

for f in `seq 150`
do
	date
	manager.pl $RG_CONSOLE1_HOST $RG_CONSOLE1_PORT $RG1_PASSWORD "console configure global get rebalance progress" > cmd-output$f.txt
	grep "http://.*/pools=.*" cmd-output$f.txt && sleep 10 && continue
	echo "Rebalance done ($SECONDS)"
	exit 0
done
exit 1
