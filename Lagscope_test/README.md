# LAGSCOPE Test Suite

## 简介

这个项目提供了一组自动化脚本，用于在两个或多个远程主机之间进行 LAGSCOPE 测试，评估网络延迟和丢包率。`LAGSCOPE` 是一款用于网络性能测量的工具。

## 要求

- `LAGSCOPE` 工具应已安装在所有参与测试的主机上。
- 可以通过 SSH 无密码登录到所有目标主机。
- `src_ip` 和 `dst_ip` 文件分别包含源 IP 和目标 IP 地址列表。

## 脚本说明

- `src_ip`: 存储源 IP 地址的文本文件。
- `dst_ip`: 存储目标 IP 地址的文本文件。

### `lagscope_server_start.sh`

启动 LAGSCOPE 服务器端。此脚本需要一个参数，即目标 IP 地址。

### `lagscope_client_test.sh`

执行 LAGSCOPE 客户端测试。此脚本需要两个参数，分别是源 IP 地址和目标 IP 地址。测试结果会被记录到一个以源和目标 IP 为名的 `.log` 文件中。

### `run_all_lagscope.sh`

主脚本，负责协调整个测试过程。它需要两个参数，分别是 `src_ip` 和 `dst_ip` 文本文件的路径。脚本会依次执行以下步骤：

1. 在目标 IP 上启动 LAGSCOPE 服务器。
2. 从源 IP 列表对每个 IP 对进行正向 LAGSCOPE 测试，并将结果保存到日志文件。
3. 等待所有正向测试完成。
4. 从目标 IP 列表对每个 IP 对进行反向 LAGSCOPE 测试。
5. 停止 LAGSCOPE 服务器。

## 使用方法

1. 创建 `src_ip` 和 `dst_ip` 文件，分别包含源和目标 IP 地址。
2. 确保你的 SSH 配置允许无密码登录到所有目标主机，并且 LAGSCOPE 已安装在所有相关主机上。
3. 在项目目录中，运行 `./run_all_lagscope.sh src_ip dst_ip`。
4. 测试完成后，结果将在当前目录下的日志文件中，格式为 `lagscope_results_{srcip}-{dstip}.log`。

## 注意事项

- 脚本假定源和目标 IP 不会相同。如果它们相同，反向测试将被跳过。
- 根据你的网络环境，你可能需要调整 `lagscope_client_test.sh` 中的 LAGSCOPE 参数以适应不同的测试需求。
- 如果遇到任何问题，检查 `lagscope_server_start.sh` 和 `lagscope_client_test.sh` 的日志输出，以及 `run_all_lagscope.sh` 的输出日志文件 `forward_tests_completed`。