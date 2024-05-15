#!/bin/bash

set -e

# 函数注释：准备系统环境
prepare_system() {
    echo "开始系统准备..."

    # 关闭防火墙和SELinux
    systemctl stop firewalld && systemctl disable firewalld
    setenforce 0
    sed -i 's/SELINUX=Permissive/SELINUX=disabled/g' /etc/selinux/config
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    echo "已关闭防火墙和SELinux。检查状态：cat /etc/selinux/config | grep SELINUX 或 getenforce"

    # 安装依赖包
    local packages="createrepo net-tools tar dmidecode quota gssproxy userspace-rcu ctdb libaio libaio-devel fio nvme-cli smartmontools bash-completion unzip vim telnet numactl mysql-libs mysql-devel mariadb"
    yum -y install --disablerepo=* --enablerepo=rhel-source "${packages}"

    # 创建目录
    mkdir -p /export

    # 设置主机名
    read -p "请输入主机名称（如node1）：" name
    hostnamectl set-hostname "$name"
    hostnamectl status | grep -qF "$name" || { echo "设置主机名失败，请检查！"; exit 1; }

    echo "主机名设置成功。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    prepare_system
}

# 确保脚本以正确方式执行
main "$@"
