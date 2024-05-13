#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <dstip> <port>"
    exit 1
fi

dstip="$1"
port="$2"

ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$dstip" "iperf -s -p $port &>/dev/null &"
echo "iperf server started on $dstip:$port"
