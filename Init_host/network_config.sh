#!/bin/bash

set -x

# 函数注释：配置网络
ifcfg() {
    echo "检查GRUB配置..."
    if grep -q 'net.ifnames=0 biosdevname=0' /etc/default/grub; then
        echo "GRUB配置已应用，继续网络配置..."
    else
        echo "请先运行grub_config_eth.sh并重启系统。"
        exit 1
    fi

    echo "配置网络..."
    [ ! -d "/etc/sysconfig/network-scripts/bak" ] && mkdir -p /etc/sysconfig/network-scripts/bak

    local bond_opts="mode=4 miimon=100 lacp_rate=1 xmit_hash_policy=layer3+4"
    local ip="192.168.124.19"
    local netmask="255.255.255.0"
    local gateway="192.168.124.2"
    local dns="114.114.114.114"

    printf "TYPE=Bond\nBOOTPROTO=static\nNAME=bond0\nDEVICE=bond0\nONBOOT=yes\nBONDING_MASTER=yes\nBONDING_OPTS=\"%s\"\nIPADDR=%s\nNETMASK=%s\nGATEWAY=%s\nDNS1=%s\n" \
        "$bond_opts" "$ip" "$netmask" "$gateway" "$dns" > /etc/sysconfig/network-scripts/ifcfg-bond0

    printf "TYPE=Ethernet\nBOOTPROTO=static\nNAME=eth0\nDEVICE=eth0\nONBOOT=yes\nMASTER=bond0\nUSERCTL=no\nSLAVE=yes\n" > /etc/sysconfig/network-scripts/ifcfg-eth0

    printf "TYPE=Ethernet\nBOOTPROTO=static\nNAME=eth1\nDEVICE=eth1\nONBOOT=yes\nMASTER=bond0\nUSERCTL=no\nSLAVE=yes\n" > /etc/sysconfig/network-scripts/ifcfg-eth1

    systemctl enable NetworkManager
    nmcli connection reload && nmcli connection up bond0

    echo "网络配置已完成，重启系统以应用更改。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    ifcfg
}

# 确保脚本以正确方式执行
main "$@"
