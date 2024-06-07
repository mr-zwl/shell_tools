# Main Initialization Script (main.sh) README

## Overview

`main.sh` 脚本作为系统初始化流程的中央控制器，旨在高效地引导用户完成Linux服务器的配置工作，分为两个有序阶段：第一阶段聚焦于基础系统配置与核心组件升级，第二阶段则致力于高性能网络与附加服务的部署。该脚本确保了从网络配置到最终服务安装的全过程自动化，显著简化了管理员的工作负担。

## Prerequisites

- **Root Access**: 必须以root用户身份运行此脚本，以执行系统级别的配置更改。
- **Dependency Scripts**: 确保与`main.sh`同目录下的所有辅助脚本（如`network_config.sh`, `yum_source_config.sh`等）均可用且兼容当前系统环境。

## Usage

1. **导航至脚本所在目录**:

```
bash

   cd /path/to/your/script/directory
```

2. **赋予执行权限**（如果尚未设置）:

```
bash
   chmod +x ./*.sh

```

3.   **修改小脚本中参数**

   ```
   1. 安装包或镜像绝对路径设置
   2. IP 网卡名配置
   3. 安装包版本号指定
   ⚡也可以使用我脚本中指定的路径进行存放
   ```

   

4. **运行脚本**:

```
bash

   ./main.sh
```

按照提示输入初始化阶段（1 或 2），以启动相应的配置流程。

## Initialization Phases

### Phase 1: System Foundation

#### Steps

1. **Network Configuration**: 调用`network_config.sh`配置网络接口，包括Bonding设置、静态IP分配等。
2. **YUM Source Setup**: 执行`yum_source_config.sh`以配置本地YUM源，提升软件包安装效率。
3. **System Preparation**: 通过`system_preparation.sh`关闭防火墙、调整SELinux策略、安装基础工具包等。
4. **Kernel Upgrade**: 运行`kernel_upgrade.sh`自动升级内核至最新版本。
5. **Mellanox Driver Installation**: 使用`mlx_driver_install.sh`安装Mellanox网络驱动，增强网络性能。
6. **GRUB Configuration**: 应用`set_default_kernel.sh`配置GRUB，固定内核命名并设置默认启动项。完成后询问用户是否立即重启系统。

### Phase 2: Advanced Features Deployment

#### Steps

1. **MFT Installation**: 调用`mft_install.sh`安装多功能传输(MFT)软件，优化网络数据传输。
2. **RDMA Software Installation**: 通过`rdma_install.sh`部署RDMA相关软件，为高性能计算和数据中心提供低延迟通信。

## Note

- **Reboot Prompt**: 第一阶段结束后，脚本会询问是否重启系统。某些更改（如内核升级）仅在重启后生效。
- **Flexibility**: 用户可根据实际需求选择执行任一阶段，提供了高度的灵活性和可选性。
- **Error Handling**: 各辅助脚本内部应包含基本错误处理逻辑，以应对执行过程中可能出现的问题。

## Conclusion

`main.sh` 是一套全面而灵活的系统初始化解决方案，旨在简化复杂配置过程，提高运维效率。无论是搭建新的服务器环境还是进行大规模系统升级，此脚本都是理想的自动化工具。