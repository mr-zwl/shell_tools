#!/bin/bash

set -x

# 函数注释：升级内核
upgrade_kernel() {
    local kernel_dir="/root/yunhai/kernel_rpm/"

    # 检查内核包是否存在
    if [ ! -f "/root/yunhai/x86-centos8.2-kernel_rpm.zip" ]; then
        echo "内核包(kernel_rpm.zip)不存在，请确保已将其放在/root/yunhai/目录下。"
        exit 1
    fi

    # 删除旧的解压目录，如果存在
    if [ -d "$kernel_dir" ]; then
        rm -rf "$kernel_dir"
    fi


    # 解压内核包
    unzip /root/yunhai/x86-centos8.2-kernel_rpm.zip -d /root/yunhai/
    # 安装内核包
    local kernel_packages=( "$kernel_dir"kernel* )
    for package in "${kernel_packages[@]}"; do
            if [ -f "$package" ]; then
                    echo "正在安装: $package"
                    rpm -i  "$package" --force --nodeps  > /dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo "安装成功: $package"
                    else
                        echo "安装失败: $package"
                    fi
            else
                    echo "跳过非文件项: $package"
            fi
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
