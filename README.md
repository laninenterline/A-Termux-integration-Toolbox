```markdown
# A-Termux-Integration-Toolbox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Version](https://img.shields.io/badge/bash-3.2+-4EAA25.svg?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Linux%20%7C%20macOS-lightgrey)]()

一个功能强大的全平台Shell集成工具箱，专为Termux、Linux和macOS设计。集成系统管理、自定义脚本运行、远程脚本拉取和Linux发行版部署等功能。

## ✨ 特性

- **全平台支持**：完美运行于Termux（Android）、主流Linux发行版、macOS、WSL
- **基础工具模块**：系统信息查看、进程管理、网络诊断、系统维护、依赖安装
- **自定义脚本管理**：支持Python、Shell、Go脚本的导入、编辑、执行
- **远程脚本**：从URL直接下载脚本，支持预设源快速获取
- **Termux专属功能**：一键部署Ubuntu、Debian、Arch等Linux发行版（chroot/proot）
- **智能包管理器集成**：自动识别apt/dnf/yum/brew/pkg等并安装依赖
- **彩色终端界面**：直观的菜单和状态提示

## 📦 安装

### 方法1：直接运行（推荐）
```bash
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/ATT.sh -o ATT.sh
chmod +x ATT.sh
./ATT.sh
```

方法2：克隆仓库

```bash
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox
chmod +x ATT.sh
./ATT.sh
```

🚀 快速开始

运行脚本后，主菜单提供以下功能：

选项 功能 说明
1 基础工具 系统信息、进程管理、网络工具、系统维护、依赖安装
2 自定义工具 运行/管理/导入自定义脚本（Python/Shell/Go）
3 远程脚本 从URL或预设源下载并执行脚本
4 工具箱管理 配置、更新、日志查看（待扩展）
5 系统专区 显示当前系统（Termux/Linux/macOS）专属工具
0 退出 退出工具箱

基础工具演示

· 系统信息：查看OS版本、硬件架构、内存和存储使用情况
· 进程管理：列出进程、按资源排序、搜索、终止/强杀进程
· 网络工具：接口信息、Ping测试、端口扫描、连接状态、下载测速
· 依赖安装：一键安装常用工具（curl/git/htop等）或自定义包

自定义脚本示例

1. 导入脚本：从本地路径或URL导入
2. 新建脚本：选择Python/Shell/Go模板，自动生成基础代码
3. 执行脚本：从列表中选择脚本直接运行，自动检测类型

Termux专区（仅Termux）

· 部署Linux发行版：支持Ubuntu/Debian/Alpine/Arch/Kali/Fedora
· 两种部署方式：
  · Chroot：需要root权限，性能更好
  · Proot：无需root，兼容性强（使用proot-distro）
· 容器管理：自动添加bashrc入口，输入容器名即可进入

📂 目录结构

首次运行后自动创建以下结构：

```
~/.ATT/
├── custom_scripts/        # 自定义脚本存放目录
│   ├── python/
│   ├── shell/
│   ├── go/
│   └── other/
├── remote_scripts/        # 远程下载脚本缓存
├── logs/                  # 运行日志
│   └── toolkit.log
├── temp/                  # 临时文件
└── linux_deploy/          # Termux Linux部署目录
    └── {container}-chroot/
        ├── rootfs/        # 根文件系统
        └── start-chroot.sh

~/.config/ATT/             # 配置文件
└── remote_sources.conf    # 远程脚本源配置
```

🔧 依赖要求

依赖 用途 备注
bash (>=3.2) 脚本解释器 必需
curl 或 wget 下载脚本 必需
python3 运行Python脚本 可选，如需使用
go 运行Go脚本 可选，如需使用
TSU Termux下获取root权限可选，chroot部署需要
Proot/Proot-distro Termux下运行Linux可选，proot部署需要

🛠️  配置

远程脚本源

编辑~/.config/ATT/remote_sources.conf，每行格式：

```
名称|基础URL|描述
```

例如：

```
实用脚本|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
```

日志

日志文件位于~/.ATT/logs/toolkit.log，可通过尾部-f实时查看。

🤝   贡献

欢迎提交ISSUE和pull Request！

1.叉子本仓库
2.创建功能分支(git校验-b功能/惊人功能)
3.提交更改(git提交-m'添加一些惊人功能')
4.推送到分支(git推送原点功能/惊人功能)
5.打开拉取请求

📄           许可证

本项目基于MIT许可证开源。详见LICENSE文件。

👤       作者

阿塞拜疆-laniniterline

🙏 致谢

· 感谢所有贡献者
·感谢proot-distro、Termux社区提供的技术支持

---

提示：详细教程请查看TUTORIAL.md

```
