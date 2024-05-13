#!/bin/bash

usage() {
    echo "Usage: $0 <srcip> <dstip> <port> <protocol> [duration] [parallel_streams]"
    echo "    e.g. $0 10.131.102.6 10.131.102.68 5201 tcp 10 "
    exit 1
}

if [[ $# -lt 4 || $# -gt 6 ]]; then
    usage
fi

srcip="$1"
dstip="$2"
port="$3"
protocol="$4"
streams="${5:-1}"

log_file="iperf_results_${srcip}-${dstip}.log"

if [[ "$protocol" != "tcp" && "$protocol" != "udp" ]]; then
    echo "Invalid protocol, must be 'tcp' or 'udp'"
    exit 1
fi

echo "########################### From $srcip To $dstip:$port at $(date)" >> $log_file

if [[ "$protocol" == "tcp" ]]; then
    ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$srcip" "iperf -c $dstip -p $port  -P $streams -i 1 -f M" >> $log_file
elif [[ "$protocol" == "udp" ]]; then
    ssh -l root -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 22 "$srcip" "iperf -c $dstip -p $port -u  -b 0M -P $streams -i 1 -f M" >> $log_file
else
    echo "Invalid protocol, unable to execute command"
fi
