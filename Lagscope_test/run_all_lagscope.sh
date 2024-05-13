#!/bin/bash

usage() {
    echo "Usage: $0 <src_ip_list> <dst_ip_list>"
    echo "    e.g. $0 src_ip_list.txt dst_ip_list.txt"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

src_ips=$(cat "$1")
dst_ips=$(cat "$2")

# Start LAGSCOPE servers on dst_ips
for dstip in $dst_ips; do
    ./lagscope_server_start.sh "$dstip"
done

for srcip in $src_ips; do
    ./lagscope_server_start.sh "$srcip"
done
# Create a flag file to indicate when all forward tests are done
forward_test_completed_flag="forward_tests_completed"

# Perform LAGSCOPE tests from src_ips to dst_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi

        ./lagscope_client_test.sh "$srcip" "$dstip" > /dev/null 2>&1
    done
done > "$forward_test_completed_flag"  # Redirect output to the flag file

# Wait until the forward tests are completed
while [[ ! -f "$forward_test_completed_flag" ]]; do
    sleep 1
done
rm "$forward_test_completed_flag"  # Remove the flag file once it's detected

# Perform LAGSCOPE tests from dst_ips to src_ips
for srcip in $src_ips; do
    for dstip in $dst_ips; do
        if [[ "$srcip" == "$dstip" ]]; then
            continue
        fi

        ./lagscope_client_test.sh "$dstip" "$srcip" > /dev/null 2>&1
    done
done

# Stop LAGSCOPE servers (Add your own cleanup logic here)
