# Iperf 测试套件说明

此仓库包含一系列 Shell 脚本，旨在自动化使用 Iperf 进行网络性能测试的过程。这些脚本帮助在多个源（`srcip`）和目标（`dstip`）主机之间，通过指定端口和协议启动 Iperf 服务器及执行客户端测试，并记录测试结果。

## 脚本概览

### 1. `iperf_client_test.sh`

- **用途**：在指定的源IP到目标IP之间执行Iperf客户端测试，支持TCP和UDP协议。

- **使用方法**：`./iperf_client_test.sh <源IP> <目标IP> <端口> <协议> [持续时间] [并发流数]`

- 特性

  ：

  - 将测试结果记录到按源目标IP对及时间戳命名的日志文件中。
  - 支持自定义测试持续时间和并发流数以进行更细致的测试。

### 2. `iperf_server_start.sh`

- **用途**：在指定的目标IP和端口上远程启动Iperf服务器。

- **使用方法**：`./iperf_server_start.sh <目标IP> <端口>`

- 特性

  ：

  - 静默在目标主机后台启动Iperf服务器。

### 3. `run_all_iperf.sh`

- **用途**：全面组织并执行源IP列表和目标IP列表之间的所有Iperf测试。

- **使用方法**：`./run_all_iperf.sh <源IP列表文件> <目标IP列表文件> <端口> <协议>`

- 特性

  ：

  - 自动在所有目标IP上启动Iperf服务器。
  - 执行源到目标及目标到源的双向测试。
  - 内部调用`iperf_client_test.sh`和`iperf_server_start.sh`脚本。
  - 启动服务器后等待5秒，确保服务器准备就绪再开始测试。

### 使用前须知

- 确保所有参与测试的主机已安装Iperf。
- 从控制主机到所有测试主机需具备SSH免密登录权限（以root用户身份）。
- 确保SSH `known_hosts` 配置正确，以避免连接时出现未知主机警告。

### 示例用法

1. **启动Iperf服务器**：编辑或创建包含目标IP的文件，如`dst_ip_list.txt`，然后运行`./iperf_server_start.sh dst_ip_list.txt <端口>`。
2. **执行单向测试**：直接使用`iperf_client_test.sh`脚本，提供源IP、目标IP、端口和协议，如`./iperf_client_test.sh 10.131.102.6 10.131.102.68 5201 tcp`。
3. **全面测试**：准备源IP列表和目标IP列表文件，然后运行`./run_all_iperf.sh src_ip_list.txt dst_ip_list.txt 5201 tcp`，以自动执行所有双向测试。

通过以上脚本的配合使用，您可以高效地完成网络性能的批量测试与分析。