# A-Termux-Integration-Toolbox (ATT)

<div align="center">

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/laninenterline/A-Termux-integration-Toolbox)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Linux%20%7C%20macOS-orange.svg)](https://termux.dev)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

**全平台 Shell 集成工具箱 - 专为 Termux 优化，支持 Linux/macOS**

[English](#english) | [中文](#中文)

</div>

---

## 中文

### 📖 项目简介

A-Termux-Integration-Toolbox (ATT) 是一个功能强大的跨平台 Shell 工具箱，专为 Termux 环境优化，同时完美支持 Linux 和 macOS 系统。它提供了系统管理、进程监控、网络工具、自定义脚本管理以及 Linux 发行版部署等一站式解决方案。

### ✨ 核心特性

- 🚀 **跨平台支持** - 智能识别 Termux/Linux/macOS/WSL 环境，自动适配
- 🛠️ **基础工具集** - 系统信息、进程管理、网络诊断、依赖安装
- 📜 **自定义脚本** - 支持 Python/Shell/Go 脚本的导入、管理和执行
- 🌐 **远程脚本** - 从 URL 下载并执行远程脚本，支持源管理
- 📦 **Linux 部署** - Termux 专属：通过 Chroot/Proot 部署完整 Linux 发行版
- 🎨 **美观界面** - 彩色终端界面，友好的交互式菜单
- 📝 **日志系统** - 完整的操作日志记录，便于追踪和调试

### 🚀 快速开始

#### 安装

```bash
# 克隆仓库
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox

# 赋予执行权限
chmod +x ATT.sh

# 运行工具箱
./ATT.sh
```

#### 一键安装（Termux）

```bash
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/install.sh | bash
```

### 📋 功能模块

| 模块 | 功能描述 | 适用平台 |
|------|----------|----------|
| **基础工具** | 系统信息查看、进程管理、网络工具、系统维护 | 全平台 |
| **自定义工具** | 本地脚本管理（Python/Shell/Go）、脚本导入/新建/编辑 | 全平台 |
| **远程脚本** | URL 下载脚本、远程源配置、脚本缓存管理 | 全平台 |
| **系统专区** | Linux 发行版部署（Ubuntu/Debian/Alpine/Arch/Kali/Fedora） | Termux |
| **工具箱管理** | 日志查看、配置备份/恢复、更新检查 | 全平台 |

### 🐧 Termux Linux 部署功能

ATT 为 Termux 用户提供了强大的 Linux 发行版部署能力：

**支持的发行版：**
- Ubuntu (24.04 LTS / 22.04 LTS / 20.04 LTS)
- Debian (12 / 11 / 10)
- Alpine Linux (3.19 / 3.18 / 3.17)
- Arch Linux (latest)
- Kali Linux (latest)
- Fedora (40 / 39)

**部署方式：**
- **Proot 部署** - 无需 Root 权限，兼容性最好，推荐日常使用
- **Chroot 部署** - 需要 Root 权限（tsu），性能更好，适合高级用户

**特色功能：**
- 自定义容器名称
- 一键添加到 `.bashrc`（输入容器名即可进入）
- 自动配置 DNS
- 备份/恢复系统
- 多版本共存管理

### 📂 项目结构

```
~/.ATT/
├── custom_scripts/          # 自定义脚本存储
│   ├── python/             # Python 脚本
│   ├── shell/              # Shell 脚本
│   ├── go/                 # Go 程序
│   └── other/              # 其他类型
├── remote_scripts/         # 下载的远程脚本
├── linux_deploy/           # Linux 部署目录（Termux）
├── logs/                   # 操作日志
├── temp/                   # 临时文件
└── config/                 # 配置文件

~/.config/ATT/
└── remote_sources.conf     # 远程脚本源配置
```

### 🔧 系统要求

**必需：**
- Bash 4.0+
- curl 或 wget

**可选（增强功能）：**
- Python 3（运行 Python 脚本）
- Go（编译运行 Go 程序）
- proot / proot-distro（Termux Linux 部署）
- tsu（Termux Root 权限）

**支持的操作系统：**
- Android (Termux)
- Linux (Ubuntu, Debian, CentOS, Fedora, Arch, etc.)
- macOS
- WSL (Windows Subsystem for Linux)

### 📚 文档

- [详细教程](docs/TUTORIAL.md) - 功能详解和使用指南
- [API 文档](docs/API.md) - 开发者接口文档（计划中）
- [常见问题](docs/FAQ.md) - FAQ 和故障排除（计划中）

### 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

### 📜 许可证

本项目采用 [MIT](LICENSE) 许可证开源。

### 🙏 致谢

- [Termux](https://termux.dev/) - 强大的 Android 终端环境
- [proot-distro](https://github.com/termux/proot-distro) - Termux Linux 发行版管理工具

---

## English

### 📖 Introduction

A-Termux-Integration-Toolbox (ATT) is a powerful cross-platform Shell toolkit, optimized for Termux environment while fully supporting Linux and macOS systems. It provides one-stop solutions for system management, process monitoring, network tools, custom script management, and Linux distribution deployment.

### ✨ Features

- 🚀 **Cross-Platform** - Smart detection of Termux/Linux/macOS/WSL environments
- 🛠️ **Basic Tools** - System info, process management, network diagnostics, package installation
- 📜 **Custom Scripts** - Import, manage and execute Python/Shell/Go scripts
- 🌐 **Remote Scripts** - Download and execute scripts from URLs with source management
- 📦 **Linux Deployment** - Termux exclusive: Deploy full Linux distributions via Chroot/Proot
- 🎨 **Beautiful UI** - Colorful terminal interface with interactive menus
- 📝 **Logging** - Complete operation logs for tracking and debugging

### 🚀 Quick Start

#### Installation

```bash
# Clone repository
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox

# Make executable
chmod +x ATT.sh

# Run toolkit
./ATT.sh
```

#### One-line Install (Termux)

```bash
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/install.sh | bash
```

### 📋 Modules

| Module | Description | Platforms |
|--------|-------------|-----------|
| **Basic Tools** | System info, process management, network tools, maintenance | All |
| **Custom Tools** | Local script management (Python/Shell/Go), import/create/edit | All |
| **Remote Scripts** | URL download, remote source config, script cache management | All |
| **System Zone** | Linux distro deployment (Ubuntu/Debian/Alpine/Arch/Kali/Fedora) | Termux |
| **Management** | Log viewing, config backup/restore, update check | All |

### 🐧 Termux Linux Deployment

ATT provides powerful Linux distribution deployment for Termux users:

**Supported Distros:**
- Ubuntu (24.04 LTS / 22.04 LTS / 20.04 LTS)
- Debian (12 / 11 / 10)
- Alpine Linux (3.19 / 3.18 / 3.17)
- Arch Linux (latest)
- Kali Linux (latest)
- Fedora (40 / 39)

**Deployment Methods:**
- **Proot** - No root required, best compatibility, recommended for daily use
- **Chroot** - Requires root (tsu), better performance, for advanced users

**Features:**
- Custom container names
- One-click `.bashrc` integration (type container name to enter)
- Auto DNS configuration
- Backup/restore systems
- Multi-version coexistence management

### 📂 Project Structure

```
~/.ATT/
├── custom_scripts/          # Custom scripts storage
│   ├── python/             # Python scripts
│   ├── shell/              # Shell scripts
│   ├── go/                 # Go programs
│   └── other/              # Other types
├── remote_scripts/         # Downloaded remote scripts
├── linux_deploy/           # Linux deployment dir (Termux)
├── logs/                   # Operation logs
├── temp/                   # Temporary files
└── config/                 # Configuration files

~/.config/ATT/
└── remote_sources.conf     # Remote script sources config
```

### 🔧 Requirements

**Required:**
- Bash 4.0+
- curl or wget

**Optional (Enhanced):**
- Python 3 (for Python scripts)
- Go (for compiling Go programs)
- proot / proot-distro (for Termux Linux deployment)
- tsu (for Termux root access)

**Supported OS:**
- Android (Termux)
- Linux (Ubuntu, Debian, CentOS, Fedora, Arch, etc.)
- macOS
- WSL (Windows Subsystem for Linux)

### 📚 Documentation

- [Tutorial](docs/TUTORIAL.md) - Detailed guide and usage
- [API Docs](docs/API.md) - Developer interface docs (planned)
- [FAQ](docs/FAQ.md) - FAQ and troubleshooting (planned)

### 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### 📜 License

This project is licensed under the [MIT](LICENSE) License.

### 🙏 Acknowledgments

- [Termux](https://termux.dev/) - Powerful Android terminal environment
- [proot-distro](https://github.com/termux/proot-distro) - Termux Linux distribution management tool
