#!/bin/bash

set -e

# 函数注释：配置本地yum源
yum_source() {
    local yum_iso_dir="/root/yunhai"
    local tmp_mount_dir="/mnt/yumsource_temp"
    local tmp_extract_dir="/mnt/yumextract"

    # 检查yum源目录是否存在
    [ -d "$yum_iso_dir" ] || { echo "yum源目录不存在，请检查！"; exit 1; }

    # 遍历ISO文件
    for iso_file in "$yum_iso_dir"/*.iso; do
        [ -f "$iso_file" ] || continue

        echo "处理ISO文件: $iso_file"

        # 创建临时挂载目录
        mkdir -p "$tmp_mount_dir"
        
        # 挂载ISO为只读（因为ISO本身是只读的）
        mount -t iso9660 -o loop,ro "$iso_file" "$tmp_mount_dir"
        
        # 创建并清空临时提取目录
        rm -rf "$tmp_extract_dir"
        mkdir -p "$tmp_extract_dir"
        cp -r "$tmp_mount_dir"/* "$tmp_extract_dir"
        mkdir -p /etc/yum.repos.d/bak/ &>/dev/null
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/


        # 检查ISO内是否存在多个仓库
        repos=("$tmp_mount_dir"/AppStream "$tmp_mount_dir"/BaseOS) # 替换为ISO内的实际仓库路径
        for repo in "${repos[@]}"; do
            if [ -d "$repo" ]; then
                repo_name=$(basename "$repo")
                repo_config="/etc/yum.repos.d/local-${repo_name}.repo"
                echo "[${repo_name}]" > "$repo_config"
                echo "name=Local ${repo_name} yum source" >> "$repo_config"
                echo "baseurl=file://$tmp_extract_dir/$repo_name" >> "$repo_config"
                echo "enabled=1" >> "$repo_config"
                echo "gpgcheck=0" >> "$repo_config"
                echo "已配置本地yum源，仓库: ${repo_name}"
            fi
        done

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
