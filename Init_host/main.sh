#!/bin/bash

# 检查脚本执行权限
if [[ $EUID -ne 0 ]]; then
    echo "请以root权限运行此脚本。"
    exit 1
fi

pwd=$PWD
# 函数定义
function first() {
    echo "开始第一阶段初始化..."
    echo "1. 配置网络..."
    . network_config.sh
    echo "2. 配置YUM源..."
    . yum_source_config.sh
    echo "3. 准备系统环境..."
    . system_preparation.sh
    echo "4. 升级内核..."
    . kernel_upgrade.sh
    echo "5. 安装Mellanox驱动..."
    . mlx_driver_install.sh
    echo "6. 配置GRUB..."
    cd $pwd
    . set_default_kernel.sh
    # 征求用户重启许可
    read -p "是否现在重启系统以应用更改？(y/n)：" confirm_reboot
    if [[ $confirm_reboot =~ ^[yY]$ ]]; then
        echo "即将重启系统..."
        reboot
    else
        echo "系统不会自动重启。请在准备好后手动重启。"
    fi
}

function second() {
    echo "开始第二阶段初始化..."
    echo "1. 安装MFT..."
    . mft_install.sh
    echo "2. 安装RDMA软件..."
    cd $pwd
    . rdma_install.sh
    echo "第二阶段初始化完成。"
}

# 用户输入处理
read -p "请输入初始化阶段（1-第一阶段，2-第二阶段）：" stage

case $stage in
    1|one|First|FIRST)
        first ;;
    2|two|Second|SECOND)
        second ;;
    *)
        echo "输入无效。请输入1或2。" ;;
esac
