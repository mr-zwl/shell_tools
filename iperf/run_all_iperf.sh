#!/bin/bash

usage() {
    echo "Usage: $0 <src_ip_list> <dst_ip_list> <port> <protocol>"
    echo "    e.g. $0 src_ip_list.txt dst_ip_list.txt 5201 tcp"
    exit 1
}

if [[ $# -ne 4 ]]; then
    usage
fi

src_ips="$(cat "$1")"
dst_ips="$(cat "$2")"
port="$3"
protocol="$4"

# Start IPERF servers on dst_ips
for dstip in $dst_ips; do
     ./iperf_server_start.sh $dstip  $port 
done

sleep 5  # Wait for servers to start

# Perform IPERF tests from src_ips to dst_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi

        ./iperf_client_test.sh $srcip $dstip $port $protocol 10
    done
done
# Perform IPERF tests from dst_ips to src_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi
        ./iperf_client_test.sh $dstip $srcip $port $protocol 10
    done
done

# Stop IPERF servers (Add your own cleanup logic here)
