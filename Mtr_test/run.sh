#!/bin/bash

IP_LIST=(172.18.0.4 172.18.0.11)
MAIN_LOG_FILE="all_mtr_results.log"

for srcip in "${IP_LIST[@]}"
do
    for dstip in "${IP_LIST[@]}"
    do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi
        ./mtr_temp_file.sh "$srcip" "$dstip" >> $MAIN_LOG_FILE
    done
done
