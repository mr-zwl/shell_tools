#!/bin/bash

usage() {
    echo "Usage: $0 <srcip> <dstip> "
    echo "    e.g. $0 10.131.102.6 10.131.102.68  "
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

srcip="$1"
dstip="$2"

log_file="lagscope_results_${srcip}-${dstip}.log"


echo "########################### From $srcip To $dstip:6001 at $(date)" >> $log_file
ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$srcip" "lagscope -s$dstip -H -a10 -l1 -c98" >> $log_file
