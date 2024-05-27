#!/bin/bash

set -x

# 函数注释：设置默认启动内核
set_default_kernel() {
    local kernel="$1"
    echo "当前默认启动内核将被修改为：$kernel"
    if grub2-set-default "$kernel"; then
            echo "默认启动内核已成功修改为：$kernel"
    else
            echo "修改默认启动内核失败，请检查grub配置。"
            return 1
    fi
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi

    # 在这里指定内核名称
    local kernel='CentOS Linux (4.18.0-193.28.1.el8_2.x86_64) 8 (Core)'
    set_default_kernel "$kernel"
}

# 确保脚本以正确方式执行
main "$@"
