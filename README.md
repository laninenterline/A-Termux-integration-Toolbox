# A-Termux-Integration-Toolbox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Version](https://img.shields.io/badge/bash-3.2+-4EAA25.svg?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Linux%20%7C%20macOS-lightgrey)]()

**一个功能强大、界面美观的全平台 Shell 集成工具箱**，专为 **Termux（Android）**、**Linux**、**macOS** 和 **WSL** 设计。

只需一个脚本，即可快速完成系统管理、自定义脚本运行、远程脚本拉取、Termux Linux 容器部署等操作，让你在移动端或服务器上使用 Termux 时更加高效便捷。

---

## ✨ 主要特性

- **全平台兼容**：完美支持 Termux、主流 Linux 发行版、macOS、WSL
- **彩色交互菜单**：直观易用，支持终端彩色显示
- **基础工具模块**：系统信息、进程管理、网络诊断、系统维护、一键安装常用依赖
- **自定义脚本管理**：支持 Python、Shell、Go 脚本的导入、编辑、运行和分类管理
- **远程脚本拉取**：支持从任意 URL 或预设源一键下载并执行脚本
- **Termux 专属功能**（仅 Termux 环境）：
  - 一键部署 Ubuntu、Debian、Arch、Kali、Fedora、Alpine 等 Linux 发行版
  - 支持 **chroot**（需 root）和 **proot**（无需 root，使用 proot-distro）两种模式
  - 自动生成启动脚本，输入容器名即可进入
- **智能包管理**：自动识别 apt、dnf、yum、brew、pkg 等包管理器
- **日志与配置**：完整日志记录、可自定义远程脚本源

---

## 📦 安装方式

### 推荐方式（一键安装）
```bash
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/ATT.sh -o ATT.sh
chmod +x ATT.sh
./ATT.sh
通过 Git 克隆安装
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox
chmod +x ATT.sh
./ATT.sh
首次运行会自动完成环境初始化（创建目录、配置文件等）。
🚀 使用说明
运行 ./ATT.sh 后进入主菜单：
选项
功能
说明
1
基础工具
系统信息、进程管理、网络工具、依赖安装
2
自定义工具
管理并运行本地 Python/Shell/Go 脚本
3
远程脚本
从 URL 或预设源下载并执行脚本
4
工具箱管理
配置、更新工具箱、查看日志
5
系统专区
Termux/Linux/macOS 专属功能
0
退出
退出工具箱
Termux 用户特别推荐：
在「系统专区」中可一键部署完整 Linux 容器
支持 chroot（高性能）和 proot（无需 root）两种方式
📂 目录结构（首次运行后自动创建）
\~/.ATT/
├── custom_scripts/        # 自定义脚本存放目录
│   ├── python/
│   ├── shell/
│   ├── go/
│   └── other/
├── remote_scripts/        # 远程下载的脚本缓存
├── logs/                  # 运行日志
│   └── toolkit.log
├── temp/                  # 临时文件
└── linux_deploy/          # Termux Linux 部署目录

\~/.config/ATT/
└── remote_sources.conf    # 远程脚本源配置文件
🔧 配置说明
远程脚本源
编辑 \~/.config/ATT/remote_sources.conf，格式如下：
# 格式：名称|基础URL|描述
实用脚本|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
我的脚本|https://example.com/scripts/|个人脚本仓库
🛠️ 依赖要求
必需：bash、curl（或 wget）
可选：
python3（运行 Python 脚本）
go（运行 Go 脚本）
Termux 下：tsu（chroot 部署）、proot-distro（proot 部署）
📄 许可证
本项目采用 MIT License 开源。详见 LICENSE 文件。
👤 作者
Azeri（阿塞拜疆-laniniterline）
GitHub: laninenterline
🤝 贡献指南
欢迎提交 Issue 和 Pull Request！
Fork 本仓库
创建功能分支 (git checkout -b feature/awesome-feature)
提交更改 (git commit -m 'feat: 添加一些惊人功能')
推送到分支 (git push origin feature/awesome-feature)
提交 Pull Request
提示：首次使用建议直接运行脚本，工具会自动完成所有初始化工作。
有任何问题或建议，欢迎在 GitHub Issues 中提出！
项目地址：https://github.com/laninenterline/A-Termux-integration-Toolbox
