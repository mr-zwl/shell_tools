# MTR 路由探测脚本

这是一个用于多主机间 MTR (My Traceroute) 路由探测的 Shell 脚本，旨在帮助您分析网络延迟和丢包情况。请在具有所有目标主机免密登录权限的控制主机上运行此脚本。

## 安装与使用

1. **配置 IP 列表**：在 `run.sh` 文件中，更新 `IP_LIST` 变量，包含需要进行 MTR 探测的主机 IP 地址，如：

```
bash

   IP_LIST=(172.18.0.4 172.18.0.11)
```

1. **设置执行权限**：确保 `mtr_temp_file.sh` 脚本可执行：

```
bash

   chmod +x mtr_temp_file.sh
```

1. **运行脚本**：配置完成后，在控制主机上执行 `run.sh`：

```
bash

   bash run.sh
```

1. **查看结果**：脚本执行完毕后，会生成包含所有 MTR 测试结果的综合日志文件：

```
bash

   cat all_mtr_results.log
```

## 脚本功能

`mtr_temp_file.sh` 脚本负责执行单一的 MTR 测试，从指定的源 IP 到目标 IP。它会将输出格式化并附加当前时间戳。`run.sh` 脚本则遍历所有组合的源 IP 和目标 IP，调用 `mtr_temp_file.sh` 并将结果汇总到 `all_mtr_results.log` 文件中。

通过这些脚本，您可以轻松地对多个主机之间的网络连接质量进行全面的路由探测和分析。