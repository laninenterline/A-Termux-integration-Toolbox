# A-Termux-Integration-Toolbox 跨平台Shell集成工具箱

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/laninenterline/A-Termux-integration-Toolbox/releases)

**A-Termux-Integration-Toolbox** 是一个功能强大的 Shell 集成工具箱，支持 Linux、macOS 和 Termux 环境。它提供了系统管理、自定义脚本运行、远程脚本拉取、Linux 发行版部署（Termux）等丰富功能，旨在简化日常运维任务。

## ✨ 特性

- **跨平台支持**：兼容 Linux、macOS、Termux（Android）以及 WSL。
- **模块化设计**：基础工具、自定义脚本、远程脚本、工具箱管理、系统专区（如 Termux Linux 部署）五大模块。
- **丰富的系统工具**：系统信息、进程管理、网络工具、系统维护、依赖安装等。
- **自定义脚本管理**：支持导入/创建 Python、Shell、Go 脚本，一键执行。
- **远程脚本支持**：从 URL 下载脚本，配置远程源，快速获取社区脚本。
- **Termux Linux 部署**：通过 chroot/proot 安装 Ubuntu、Debian、Alpine、Arch Linux、Kali、Fedora 等发行版，并支持 bashrc 快捷入口。
- **配置备份与恢复**：一键备份/恢复所有自定义脚本和配置。
- **彩色终端界面**：直观的菜单导航，支持颜色高亮。

##📋  系统要求

- **猛击** 4.0 或更高版本
- **卷曲**或**wget**（用于下载远程脚本）
- 可选依赖：`python3`、`去`（用于运行对应类型的自定义脚本）
-Termux额外依赖：`Proot`、`TSU`(用于Linux部署)

##🚀  安装

###快速安装(Linux/macOS/Termux)

```猛击
# 下载脚本
curl-fsSL https://github.com/laninenterline/A-Termux-integration-Toolbox/blob/main/ATT.sh-o附件。嘘
# 或
wget-q https://github.com/laninenterline/A-Termux-integration-Toolbox/blob/main/ATT.sh-O ATT.sh

# 赋予执行权限
chmod+x ATT.sh

# 运行
./ATT.SH
