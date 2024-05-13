#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <dstip> "
    exit 1
fi

dstip="$1"

ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$dstip" "lagscope  -r &>/dev/null &"
echo "lagscope server started on $dstip:6001"
