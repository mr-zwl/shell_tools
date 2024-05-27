#!/bin/bash

set -x

# 函数注释：配置GRUB以固定网卡名称
grub_eth() {
    echo "配置GRUB以固定网卡名称..."
    cp /etc/default/grub /etc/default/grub.bak
    sed -i 's/quiet/& net.ifnames=0 biosdevname=0/' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    echo "GRUB配置已完成，请重启系统以应用更改。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    grub_eth
}

# 确保脚本以正确方式执行
main "$@"
