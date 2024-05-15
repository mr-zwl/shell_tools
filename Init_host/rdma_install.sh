#!/bin/bash

set -e

# 函数注释：安装指定版本的RDMA库
install_rdma() {
    local full_version
    local rpm_name="librdma-ofs-wrapper-$full_version-Linux.rpm"
    local rpm_path="/root/yunhai/net_rpm/$rpm_name"

    # 提示用户输入完整版本号（包括小版本号，如56103.3.1）
    read -p "请输入您想安装的RDMA库完整版本号（包括小版本号，例如：56103.3.1）: " full_version

    # 检查指定版本的RPM文件是否存在
    if [ ! -f "$rpm_path" ]; then
        echo "指定版本的RPM文件不存在，请确保$rpm_name位于/root/yunhai/net_rpm/目录中。"
        exit 1
    fi

    # 安装RDMA库
    rpm -ivh --force --nodeps "$rpm_path"

    echo "###########################################################################################"
    echo "RDMA库已安装。使用命令 'rpm -qa | grep librdma' 检查安装情况。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi

    install_rdma
}

# 确保脚本以正确方式执行
main "$@"
