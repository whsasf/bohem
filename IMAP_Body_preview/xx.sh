#!/bin/bash

for aa in $(find .  |grep test_run)
do
    sed -i 's/start_time_tc//g' $aa
done
