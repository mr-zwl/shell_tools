#!/usr/bin/bash
# Author: zwl

# 安装chrony服务,修改配置
install(){
apt-get -y install chrony &>/dev/null
sed -i 's/^server/#server/g'  /etc/chrony.conf
}

# 帮助手册
helps(){
echo "############################################################"
echo "# 该脚本用于安装chronyc时间服务器,分别安装服务端和客户端       #"
echo "# 执行参数为: [sh chronyc.sh service||client]               #"
echo "# service参数安装服务端client安装客户端使用时注意修改IP       #"
echo "############################################################"
}

case $1 in
service)
install
cat >>/etc/chrony.conf<<EOF
# Start custom config
# add time server address  # ntp服务器
server time1.aliyun.com iburst
server time2.aliyun.com iburst
server time3.aliyun.com iburst
server time4.aliyun.com iburst
server time5.aliyun.com iburst
server time6.aliyun.com iburst
server time7.aliyun.com iburst

# Allow NTP client access from local network
allow 192.168.144.0/16 # 客户端网段 
# End custom config        
EOF

# 启动服务
systemctl start chronyd && systemctl enable chronyd
chronyc sources
hwclock -w
;;

client)
install
cat >>/etc/chrony.conf<<EOF
# Start custom config
# add time server address
server 192.168.144.10 iburst # ntp服务器
EOF

# 启动服务
systemctl start chronyd && systemctl enable chronyd
chronyc sources
hwclock -w
;;



*)
   helps
;;
esac

