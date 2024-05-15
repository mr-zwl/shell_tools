#!/bin/bash

set -e

# 函数注释：安装MFT
install_mft() {
    local mft_tar="/root/yunhai/net_rpm/mft-4.18.0-106-x86_64-rpm.tgz"
    local mft_dir="/root/yunhai/mft-4.18.0-106-x86_64-rpm"

    # 检查MFT RPM包是否存在
    if [ ! -f "$mft_tar" ]; then
        echo "MFT安装包$mft_tar不存在，请确保文件已放置在正确位置。"
        exit 1
    fi

    # 安装依赖包
    yum -y install rpm-build kernel-devel-4.18.0-193.el8.x86_64 elfutils-libelf-devel

    # 解压MFT RPM包
    cd /root/yunhai/net_rpm
    tar -xf "$mft_tar"

    # 安装MFT
    cd "$mft_dir"
    ./install.sh

    echo "########################################################################################"
    echo "MFT已安装。请手动启动：mst start"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    install_mft
}

# 确保脚本以正确方式执行
main "$@"
