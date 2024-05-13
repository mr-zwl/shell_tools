#!/bin/bash

usage() {
    echo "Usage: $0 <srcip> <dstip>"
    echo "    e.g. $0 10.131.102.6 10.131.102.68"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

srcip="$1"
dstip="$2"
timestamp=$(date +%Y%m%d%H%M%S)

echo "########################### From $srcip To $dstip at $(date)"
ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$srcip" "mtr -a \"$srcip\" -c 10 -i 0.3 -n -r \"$dstip\"" || echo "Error executing command on $srcip"
