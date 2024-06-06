#!/bin/bash

set -x

# 函数注释：安装Mellanox OFED驱动
install_mlnx_ofed() {
    # 检查并处理/x86-netdriver_rpm目录
    if [ -d "/root/yunhai/x86-netdriver_rpm" ]; then
        mv /root/yunhai/x86-netdriver_rpm /mnt 
    fi
    # 可替换版本修改绝对路径即可  MLNX_OFED_LINUX-5.8-4.1.5.0-rhel8.2-x86_64
    local ofed_dir="/root/yunhai/x86-netdriver_rpm/MLNX_OFED_LINUX-5.6-1.0.3.3-rhel8.2-x86_64"

    # 检查OFED包是否存在
    if [ ! -f "/root/yunhai/x86-netdriver_rpm.zip" ]; then
        echo "OFED包(x86-netdriver_rpm.zip)不存在，请确保已将其放在/root/yunhai/目录下。"
        exit 1
    fi

    # 安装依赖包
    yum -y install perl perl-devel pciutils kernel-modules-extra tcsh tcl python36 tk lsof pkgconf-pkg-config gcc-gfortran

    # 解压OFED包
    unzip /root/yunhai/x86-netdriver_rpm.zip -d /root/yunhai
    tar -xf "$ofed_dir".tgz -C /root/yunhai/x86-netdriver_rpm/

    # 安装OFED
    cd "$ofed_dir"
    ./mlnxofedinstall

    echo "安装成功。请手动启动服务：sudo systemctl start openibd，并检查启动状态。"
    echo "安装完成后，可能需要修改内核参数并重启设备。"
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    install_mlnx_ofed
}

# 确保脚本以正确方式执行
main "$@"
