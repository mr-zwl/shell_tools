#!/bin/bash

set -e

# 函数注释：配置本地yum源
yum_source() {
    local yum_iso_dir="/root/yunhai"
    local tmp_mount_dir="/mnt/yumsource"

    # 检查yum源目录是否存在
    [ -d "$yum_iso_dir" ] || { echo "yum源目录不存在，请检查！"; exit 1; }

    # 遍历ISO文件
    for iso_file in "$yum_iso_dir"/*.iso; do
        [ -f "$iso_file" ] || continue

        echo "挂载ISO文件: $iso_file"

        # 创建临时挂载目录
        mkdir -p "$tmp_mount_dir"

        # 挂载ISO
        mount -t iso9660 -o loop "$iso_file" "$tmp_mount_dir"

        # 配置yum源
        repo_name=$(basename "$iso_file" .iso)
        echo "[${repo_name}]" >> /etc/yum.repos.d/local-${repo_name}.repo
        echo "name=Local ${repo_name} yum source" >> /etc/yum.repos.d/local-${repo_name}.repo
        echo "baseurl=file://$tmp_mount_dir" >> /etc/yum.repos.d/local-${repo_name}.repo
        echo "enabled=1" >> /etc/yum.repos.d/local-${repo_name}.repo
        echo "gpgcheck=0" >> /etc/yum.repos.d/local-${repo_name}.repo

        # 清理yum缓存
        yum clean all &>/dev/null
        yum makecache &>/dev/null

        echo "已配置本地yum源，可使用yum list测试。"

        # 卸载ISO
        umount "$tmp_mount_dir"
        rmdir "$tmp_mount_dir"
    done
}

# 主程序
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "请以root权限运行此脚本。"
        exit 1
    fi
    yum_source
}

# 确保脚本以正确方式执行
main "$@"
