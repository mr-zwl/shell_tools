#!/bin/bash

usage() {
    echo "Usage: $0 <src_ip_list> <dst_ip_list> <port> <protocol>"
    echo "    e.g. $0 src_ip_list.txt dst_ip_list.txt 5201 tcp"
    exit 1
}

if [[ $# -ne 4 ]]; then
    usage
fi

src_ips=$(cat "$1")
dst_ips=$(cat "$2")
port="$3"
protocol="$4"

# Start IPERF servers on dst_ips
for dstip in $dst_ips; do
    ./iperf_server_start.sh "$dstip" "$port"
done


for srcip in $src_ips; do
    ./iperf_server_start.sh "$srcip" "$port"
done

# Create a flag file to indicate when all forward tests are done
forward_test_completed_flag="forward_tests_completed"

# Perform IPERF tests from src_ips to dst_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi

        ./iperf_client_test.sh "$srcip" "$dstip" "$port" "$protocol" 10
    done
done > "$forward_test_completed_flag"  # Redirect output to the flag file

# Wait until the forward tests are completed
while [[ ! -f "$forward_test_completed_flag" ]]; do
    sleep 1
done
rm "$forward_test_completed_flag"  # Remove the flag file once it's detected

# Perform IPERF tests from dst_ips to src_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi

        ./iperf_client_test.sh "$dstip" "$srcip" "$port" "$protocol" 10
    done
done

# Stop IPERF servers (Add your own cleanup logic here)
