#!/bin/bash

set -e

# 函数注释：升级内核
upgrade_kernel() {
    local kernel_dir="/root/yunhai/kernel_rpm"

    # 检查内核包是否存在
    if [ ! -f "/root/yunhai/kernel_rpm.zip" ]; then
        echo "内核包(kernel_rpm.zip)不存在，请确保已将其放在/root/yunhai/目录下。"
        exit 1
    fi

    # 创建存放目录
    mkdir -p /root/yunhai

    # 解压内核包
    unzip /root/yunhai/kernel_rpm.zip -d "$kernel_dir"

    # 安装内核包
    local kernel_packages=( "$kernel_dir"/kernel* )
    for package in "${kernel_packages[@]}"; do
        [ -f "$package" ] || continue
        yum -y install "$package"
    done

    echo "内核包已安装，重启生效。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    upgrade_kernel
}

# 确保脚本以正确方式执行
main "$@"
