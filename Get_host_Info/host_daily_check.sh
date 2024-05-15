#!/bin/bash

#日志相关
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
[ -f $PROGPATH ] && PROGPATH="."
LOGPATH="$PROGPATH/log"
[ -e $LOGPATH ] || mkdir $LOGPATH
RESULTFILE="$LOGPATH/HostDailyCheck-$IPADDR-`date +%Y%m%d`.txt"


function getCpuStatus(){
echo ""
echo ""
echo "############################ CPU检查 #############################"
Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
CPU_Arch=$(uname -m)
echo "物理CPU个数:$Physical_CPUs"
echo "逻辑CPU个数:$Virt_CPUs"
echo "每CPU核心数:$CPU_Kernels"
echo " CPU型号:$CPU_Type"
echo " CPU架构:$CPU_Arch"
}

function getBoradStatus(){
echo ""
echo ""
echo "############################ 主板信息检查 #############################"
Manufacturer_Board=$(dmidecode -t1 |grep Manufacturer |awk -F ':' '{print $2}')
Product_Borad=$(dmidecode -t1 |grep Product |awk -F ':' '{print $2}')
Version_Board=$(dmidecode -t1 |grep Version |awk -F ':' '{print $2}')
Serial_Board=$(dmidecode -t1 |grep Serial |awk -F ':' '{print $2}')
echo "制造商:$Manufacturer_Board"
echo "产品型号:$Product_Borad"
echo "版本:$Version_Board"
echo " 主板序列:$Serial_Board"
}


function getSystemStatus(){
echo ""
echo ""
echo "############################ 系统检查 ############################"
#Release=$(cat /etc/.productinfo |grep -i release 2>/dev/null)
if [[ -f /etc/os-release ]]; then
    Release=$(source /etc/os-release && echo "${PRETTY_NAME:-Unknown}")
else
    Release="Unknown"
fi
Kernel=$(uname -r)
OS=$(uname -o)
Hostname=$(uname -n)
SELinux=$(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')
sed -i 's/SELINUX=Permissive/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0  &>/dev/null
LastReboot=$(who -b | awk '{print $3,$4}')
uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
yum=$(yum -y install  telnet > /dev/null && echo $?)
Firewalld=$(systemctl disable firewalld && systemctl stop firewalld  |systemctl status firewalld  2>/dev/null   |grep Active |awk -F : '{print "当前状态:" $2}')
echo " 系统：$OS"
echo " 发行版本：$Release"
echo " 内核：$Kernel"
echo " 主机名：$Hostname"
echo " SELinux：$SELinux"
echo " Firewalld：$Firewalld" 
echo " 当前时间：$(date +'%F %T')"
echo " 最后启动：$LastReboot"
echo " 运行时间：$uptime"
if [ $yum -eq 0 ];then
    echo " 当前yum源可用"
else
    echo " 当前yum源不可用,请检查yum.repo配置"
fi
}


function getDiskStatus(){
    echo ""
    echo ""
    echo "############################ 磁盘检查 ############################"
    echo "磁盘设备名称，容量(GB)，类型，厂商，型号"
    
    for device in /dev/sd* /dev/nvme*n1 /dev/vd*; do
        if [[ -b "$device" ]]; then
            size=$(blockdev --getsize64 "$device" | awk '{print $1/1024/1024/1024}')
            type=$(lsblk -dno TYPE "$device")
            
            if [[ "$type" == "disk" ]]; then
                vendor_model=$(smartctl -i "$device" 2>&1)
                if [[ $? -eq 0 ]]; then
                    vendor=$(echo "$vendor_model" |grep 'Vendor' |awk -F ':' '{print $2}')
                    model=$(echo "$vendor_model" | grep 'Model'|awk -F ':' '{print $2}')
                    
                    # 更精确的SSD/HDD判断逻辑，特别是针对NVMe
                    if [[ "$device" =~ ^/dev/nvme ]]; then
                        # 对于NVMe设备，可以通过型号信息或其他特定SMART属性来判断
                        is_ssd=$(echo "$model" | grep -qi 'SSD' && echo "SSD" || echo "未知类型")
                    else
                        is_ssd=$(smartctl -A "$device" 2>/dev/null | grep -q "^230" && echo "SSD" || echo "HDD")
                    fi
                    echo "$device, $size, $is_ssd, $vendor, $model"
                    
                else
                    echo "$device, $size, 未知类型, 信息获取失败"
                fi
            else
                echo "$device, $size"
            fi
        fi
    done

    # 检查export目录空间
    Export_info=$(df -Th | awk -F ' ' '$7 == "/export"{print $1, $3}')
    IFS=' ' read -r device size <<< "$Export_info"
    
    if [[ -z $size ]]; then
        echo "无法找到/export分区"
    else
        size=${size//G/}  # 移除G单位
        if (( size >= 500 )); then
            echo "export分区空间足够 ($device)"
        else
            echo "export分区空间不足500G，有风险需要调整 ($device)"
        fi
    fi
}
#function getDiskStatus(){
#echo ""
#echo ""
#echo "############################ 磁盘检查 ############################"
#Export_dirdf=$(df -TH |grep export |awk '{print $3}')
#Exp_dir=$(echo $Export_dirdf |awk -F 'G' '{print $1}') 
#Blk_id=$(lsblk  -f|grep -v NAME  |grep xfs |awk  '{print $1,$3}' && lsblk  -f|grep -v NAME |grep ext4|awk  '{print $1,$3}')
#
#echo "当前系统分区uuid为: " && echo "$Blk_id"
#echo "当前磁盘个数 ` lsblk  |awk '{print $1}' |grep -v NAME   |grep -v '─' |wc -l`"
#echo "磁盘设备名称以及物理容量"：&& echo "`lsblk  |awk '{print $1,$4}' |grep -v NAME   |grep -v '─' `"
#echo "export目录空间: $Export_dirdf"
#if [ $Exp_dir -ge 500 ];then
#    echo "export分区空间足够"
#else
#    echo "exprot分区空间不足500G，有风险需要调整"
#fi
#}


function getNetworkStatus(){
echo ""
echo ""
echo "############################ 网络检查 ############################"
#ip a
for i in $(ip link | grep BROADCAST | awk -F: '{print $2}');do ip add show $i | grep -E "BROADCAST|global"| awk '{print $2}' | tr '\n' ' ' ;echo "" ;done
Network_card=$(lspci | grep -i network)
GATEWAY=$(ip route | grep default | awk '{print $3}')
DNS=$(grep nameserver /etc/resolv.conf| grep -v "#" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
echo "网卡类型：$Network_card"
echo "网关：$GATEWAY "
echo " DNS：$DNS"
if [[ -d /proc/net/bonding ]]; then
    for bond_file in /proc/net/bonding/*; do
        if [[ -f "$bond_file" ]]; then
            bond_name=$(basename "$bond_file")
            Bond_Policy=$(cat "$bond_file" | grep Policy | awk -F ":" '{print $2}')
            Bond_Mode=$(grep Mode "$bond_file" | awk -F ":" '{print $2}')
            Bond_Speed=$(ethtool "$bond_name" | grep Speed | awk '{print $2}')
            echo "bond$bond_name 模式： $Bond_Mode"
            echo "bond$bond_name 策略： $Bond_Policy"
            echo "bond$bond_name 速率： $Bond_Speed"
        fi
    done
fi
}

function getMemStatus(){
echo ""
echo ""
echo "############################ 内存检查 ############################"
Free_Total=$(grep MemTotal /proc/meminfo  |awk '{print $2/1024/1024}')
Free=$(free | grep Mem | awk '{print $3/$2 * 100}')
echo "内存总量：$Free_Total G"
echo "内存当前使用率：$Free %"

}
function check(){
getCpuStatus
getBoradStatus
getSystemStatus
getNetworkStatus
getMemStatus
getDiskStatus
}


#执行检查并保存检查结果
check > $RESULTFILE

echo "检查结果：$RESULTFILE"
echo -e "$Hostname`date "+%Y-%m-%d %H:%M:%S"`.log"
