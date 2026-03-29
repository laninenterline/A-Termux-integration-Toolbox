```markdown
# A-Termux-Integration-Toolbox 使用教程

> 一个功能强大的全平台Shell集成工具箱，支持Termux、Linux、macOS系统

## 📖 项目简介

ATT（A-Termux-Integration-Toolbox）是一个用Bash编写的多功能Shell工具箱，集成了系统管理、自定义脚本运行、远程脚本管理等功能。特别针对Termux环境进行了优化，同时完美支持主流Linux发行版和macOS系统。

### ✨ 主要特性

- 🎯 **全平台支持**：Termux、Linux、macOS、WSL等
- 📦 **基础工具模块**：系统信息、进程管理、网络工具、系统维护
- 🔧 **自定义脚本管理**：支持Python、Shell、Go脚本的导入、编辑和执行
- 🌐 **远程脚本**：从URL下载或预设源获取脚本
- 🐧 **Termux Linux部署**：在Termux上部署Ubuntu、Debian、Arch等发行版
- 📊 **包管理器集成**：自动识别系统包管理器并安装依赖

---

## 🚀 快速开始

### 环境要求

- **Bash** 3.2+
- **curl** 或 **wget**（用于下载脚本）
- 推荐：`python3`、`go`（用于运行相应脚本）

### 安装方法

#### 方法1：直接运行（推荐）

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/ATT.sh -o ATT.sh

# 添加执行权限
chmod +x ATT.sh

# 运行工具箱
./ATT.sh
```

方法2：克隆仓库

```bash
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox
chmod +x ATT.sh
./ATT.sh
```

首次运行

首次运行时会自动创建以下目录结构：

```
~/.ATT/
├── custom_scripts/    # 自定义脚本存放目录
│   ├── python/
│   ├── shell/
│   ├── go/
│   └── other/
├── remote_scripts/    # 远程下载脚本缓存
├── logs/              # 运行日志
└── temp/              # 临时文件
```

---

📋 主菜单功能说明

运行脚本后，会显示主菜单：

```
╔══════════════════════════════════════════════════════════╗
║   Shell Toolkit v1.0.0
║   [Termux模式]
╚══════════════════════════════════════════════════════════╝

  ▶ 主菜单

  [1 ] 基础工具         系统管理、进程管理、网络工具
  [2 ] 自定义工具       运行本地自定义脚本(Python/Go/Shell)
  [3 ] 远程脚本         从指定网站拉取并执行脚本
  [4 ] 工具箱管理       配置、更新、日志查看
  [5 ] Termux专区       Termux专属工具
  [0 ] 退出             退出工具箱
```

---

🛠️ 基础工具模块详解

1. 系统信息

显示详细的系统信息，包括：

· 操作系统版本
· 硬件架构和内核版本
· 内存使用情况
· 存储空间使用情况

2. 进程管理

提供完整的进程管理功能：

· 查看进程列表：显示所有运行中的进程
· 资源占用TOP：按CPU/内存排序显示
· 搜索进程：根据名称查找进程
· 终止进程：安全结束进程（SIGTERM）
· 杀死进程：强制结束进程（SIGKILL）

3. 网络工具

包含常用网络诊断工具：

· 查看网络接口：显示所有网络接口信息
· 测试网络连通：Ping测试功能
· 端口扫描：扫描指定主机的开放端口
· 查看连接：显示网络连接状态
· 下载测试：测试下载速度

4. 系统维护

系统管理和维护功能：

· 更新软件包：更新软件包列表
· 系统升级：执行完整系统升级
· 查看日志：查看系统日志
· 服务管理：管理系统服务（非Termux环境）
· 定时任务：查看和管理crontab

5. 依赖安装

智能包管理器集成，支持多种系统：

· 基础工具：curl、wget、git、vim、nano
· 开发工具：gcc、g++、make、cmake、python3
· 网络工具：net-tools、nmap、tcpdump
· 系统工具：htop、tree、jq、unzip
· Python环境：python3、pip、venv
· Node.js环境：nodejs、npm
· 自定义安装：手动输入包名

---

📝 自定义工具模块

支持的脚本类型

类型 扩展名 执行方式 图标
Python .py python3 script.py 🐍
Shell .sh、.bash bash script.sh 📜
Go .go go run script.go 🚀
其他 任意 直接执行或bash运行 📄

主要功能

导入脚本

· 从本地路径导入：复制外部脚本到工具箱
· 从URL下载导入：从网络下载脚本并导入

新建脚本

提供三种类型的脚本模板：

· Python模板（包含标准结构）
· Shell模板（包含基本功能）
· Go模板（包含main函数）

管理脚本

· 查看脚本内容：显示脚本源代码
· 编辑脚本：使用nano/vim编辑
· 删除脚本：删除单个脚本
· 清空全部：删除所有自定义脚本

脚本命名规范

脚本名称只能包含字母、数字、下划线和连字符，例如：

· my_script.py
· backup-tool.sh
· hello-world.go

---

🌐 远程脚本模块

配置远程源

远程源配置文件位于：~/.config/ATT/remote_sources.conf

配置格式：

```
名称|基础URL|描述
```

示例：

```
Useful Scripts|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
```

使用方式

1. 从URL下载：直接输入脚本URL下载
2. 快速下载：从预设的源列表中选择
3. 管理已下载：查看、删除已缓存的远程脚本

下载的脚本会自动保存到~/.ATT/remote_scripts/目录，并可选择立即执行。

---

🐧 Termux专区

部署Linux发行版

支持在Termux上部署多种Linux发行版：

发行版 特点 支持版本
Ubuntu 官方长期支持版本 24.04, 22.04, 20.04
Debian 稳定可靠的通用发行版 12, 11, 10
Alpine 轻量级安全发行版 3.19, 3.18, 3.17
Arch Linux 滚动更新 latest
Kali Linux 渗透测试专用 latest
Fedora 红帽系创新发行版 40, 39

部署方式

Chroot部署

· 需要root权限（需安装tsu）
· 性能更好，更接近原生体验
· 适用于需要完整系统功能的场景

Proot部署

· 无需root权限
· 兼容性好，适合普通用户
· 使用proot-distro官方工具

部署流程示例

以部署Ubuntu 22.04为例：

1. 在主菜单选择5进入Termux专区
2. 选择1（部署Linux发行版）
3. 输入1选择Ubuntu
4. 选择部署方式：C（Chroot）或P（Proot）
5. 选择版本（如2选择22.04）
6. 设置容器名称（可自定义）
7. 确认部署，等待下载和安装

容器管理

· 启动容器：直接运行容器名称命令（如已添加到bashrc）
· 查看入口：在Termux专区选择2（管理Bashrc入口）
· 删除入口：可从bashrc中移除容器入口

---

🗂️ 目录结构说明

```
~/.ATT/                          # 工具箱主目录
├── custom_scripts/              # 自定义脚本目录
│   ├── python/                  # Python脚本
│   ├── shell/                   # Shell脚本
│   ├── go/                      # Go脚本
│   └── other/                   # 其他类型脚本
├── remote_scripts/              # 远程脚本缓存
├── logs/                        # 运行日志
│   └── toolkit.log              # 主日志文件
├── temp/                        # 临时文件
└── linux_deploy/                # Linux部署目录（Termux）
    └── {container-name}-chroot/ # Chroot容器目录
        ├── rootfs/              # 根文件系统
        └── start-chroot.sh      # 启动脚本
```

---

❓ 常见问题

1. 在Termux中运行时提示权限错误？

某些功能（如chroot部署）需要root权限。请安装tsu：

```猛击
pkg install tsu
```

然后使用tsu获取root权限后运行工具箱。

2. 无法下载远程脚本？

确保已安装curl或wget：

```猛击
#Termux
包装安装卷曲wget

#Ubuntu/Debian
sudo apt安装curl wget

#macOS
brew安装卷曲wget
```

3. 如何更新工具箱？

工具箱本身没有内置更新功能，但可以重新下载最新版本：

```猛击
curl-fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/ATT.sh-o附件.sh
chmod+x ATT.sh
```

4. 自定义脚本执行失败？

检查以下几点：

· 脚本是否有执行权限（会自动添加）
· Python脚本是否安装了所需依赖
· Go脚本是否已安装Go环境
· 脚本路径是否包含特殊字符

5.日志文件在哪？

日志文件位于：~/.ATT/logs/toolkit.log
可用以下命令查看：

```猛击
Tail-f~/.ATT/logs/toolkit.log
```

---

🤝 贡献与支持

·项目仓库：GitHub
·问题反馈：请在GitHub提交ISSUE
·功能建议：欢迎提交拉取请求

sudo apt安装curl wget

📄       许可证

本项目采用MIT许可证，详见项目仓库中的LICENSE文件。

---

提示：首次使用建议先浏览各模块功能，熟悉后再进行高级操作。如在Termux中使用，建议先安装proot-distro以获得更好的Linux部署体验。

```
