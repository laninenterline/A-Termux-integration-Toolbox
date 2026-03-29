# ATT 工具箱详细教程

> A-Termux-Integration-Toolbox 完整使用指南

## 目录

1. [入门指南](#入门指南)
2. [基础工具详解](#基础工具详解)
3. [自定义脚本管理](#自定义脚本管理)
4. [远程脚本功能](#远程脚本功能)
5. [Termux Linux 部署](#termux-linux-部署)
6. [工具箱管理](#工具箱管理)
7. [高级技巧](#高级技巧)
8. [故障排除](#故障排除)

---

## 入门指南

### 首次运行

当你第一次运行 ATT 时，工具箱会自动完成以下初始化：

```bash
./ATT.sh
```

初始化过程会创建：
- `~/.ATT/` - 主工作目录
- `~/.ATT/custom_scripts/` - 脚本存储（按类型分子目录）
- `~/.ATT/remote_scripts/` - 远程脚本缓存
- `~/.ATT/linux_deploy/` - Linux 部署目录（仅 Termux）
- `~/.ATT/logs/` - 操作日志
- `~/.config/ATT/` - 配置文件目录

### 主菜单导航

```
══════════════════════════════════════════════
 Shell Toolkit v1.0.0
══════════════════════════════════════════════

 ▶ 主菜单

 [1] 基础工具    系统管理、进程管理、网络工具
 [2] 自定义工具  运行本地自定义脚本(Python/Go/Shell)
 [3] 远程脚本    从指定网站拉取并执行脚本
 [4] 工具箱管理  配置、更新、日志查看
 [5] Termux专区  系统专属工具 (TERMUX)
 [0] 退出        退出工具箱
```

**操作提示：**
- 输入数字选择菜单项
- 按 `0` 返回上级或退出
- 支持 Ctrl+C 安全退出

---

## 基础工具详解

### 1. 系统信息

显示详细的系统和硬件信息：

- **操作系统**：名称、版本、架构
- **硬件信息**：CPU 型号、内核版本
- **内存使用**：总量、已用、可用、使用率
- **存储使用**：磁盘空间使用情况

### 2. 进程管理

功能选项：

| 选项 | 功能 | 说明 |
|------|------|------|
| 1 | 查看进程列表 | 显示所有运行中的进程 |
| 2 | 查看资源占用 | 按 CPU/内存排序显示 TOP 进程 |
| 3 | 搜索进程 | 根据名称关键词查找进程 |
| 4 | 终止进程 | 发送 SIGTERM 信号优雅结束 |
| 5 | 杀死进程 | 发送 SIGKILL 强制结束 |

**使用示例：**
```
选择操作 [0-5]: 3
输入进程名称关键词: python

# 显示所有包含 "python" 的进程
```

### 3. 网络工具

| 选项 | 功能 | 使用示例 |
|------|------|----------|
| 1 | 查看网络接口 | 显示 IP、MAC、状态 |
| 2 | Ping 测试 | 测试主机连通性 |
| 3 | 端口扫描 | 扫描指定端口范围 |
| 4 | 查看连接 | 显示当前网络连接 |
| 5 | 下载测试 | 测试下载速度 |

**端口扫描示例：**
```
输入目标主机: 192.168.1.1
输入端口范围: 1-1000

# 扫描 192.168.1.1 的 1-1000 端口
```

### 4. 系统维护

- **更新软件包**：更新软件包列表
- **系统升级**：执行完整系统升级
- **查看日志**：查看系统日志（syslog/journalctl）
- **服务管理**：查看运行中的系统服务
- **定时任务**：查看当前用户的 crontab

### 5. 依赖安装

智能识别系统包管理器（apt/dnf/yum/pkg/brew/pacman/zypper），提供分组安装：

| 分组 | 包含软件 | 用途 |
|------|----------|------|
| 基础工具 | curl, wget, git, vim, nano | 基础命令行工具 |
| 开发工具 | gcc, g++, make, cmake, python3 | 编译开发环境 |
| 网络工具 | net-tools, nmap, tcpdump, whois | 网络诊断 |
| 系统工具 | htop, tree, jq, unzip, p7zip | 系统监控和文件处理 |
| Python 环境 | python3, pip, venv | Python 开发 |
| Node.js 环境 | nodejs, npm | JavaScript 开发 |
| 其他工具 | ffmpeg, imagemagick, sqlite3 | 多媒体和数据库 |

**查看已安装包：**
- 显示前 50 个已安装包
- 支持显示全部包列表
- 显示常用工具安装状态

---

## 自定义脚本管理

### 脚本类型支持

ATT 自动识别以下脚本类型：

| 类型 | 扩展名 | 执行方式 | 图标 |
|------|--------|----------|------|
| Python | .py, .python | python3/python | 🐍 |
| Shell | .sh, .bash | bash | 📜 |
| Go | .go | go run / 编译执行 | 🚀 |
| 其他 | 任意 | 直接执行或 bash | 📄 |

### 导入脚本

**方式一：从本地路径导入**
```
[I] 导入脚本
选择: 1
输入脚本完整路径: /sdcard/myscript.py
# 自动检测类型并复制到对应目录
```

**方式二：从 URL 下载导入**
```
[I] 导入脚本
选择: 2
输入脚本URL: https://example.com/script.sh
# 下载并保存到工具箱
```

### 新建脚本

工具箱提供模板快速创建：

**Python 模板：**
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# DESC: 自定义Python脚本

import sys
import os

def main():
    print("自定义Python脚本运行中...")

if __name__ == "__main__":
    main()
```

**Shell 模板：**
```bash
#!/bin/bash
# DESC: 自定义Shell脚本

set -e

echo "自定义Shell脚本运行中..."
```

**Go 模板：**
```go
package main

// DESC: 自定义Go程序

import "fmt"

func main() {
    fmt.Println("自定义Go程序运行中...")
}
```

### 脚本描述

在脚本头部添加描述注释，ATT 会自动提取显示：

```bash
# DESC: 这是一个网络监控脚本
# Description: Network monitoring tool
# 描述: 中文描述也可以
```

### 管理脚本

在管理界面可以：
- **V** - 查看脚本内容
- **E** - 编辑脚本（自动调用 nano/vim/vi）
- **D** - 删除单个脚本
- **C** - 清空所有自定义脚本

---

## 远程脚本功能

### 配置远程源

编辑 `~/.config/ATT/remote_sources.conf`：

```
# 格式: 名称|URL|描述
Useful Scripts|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
My Scripts|https://myserver.com/scripts/|个人脚本仓库
```

### 快速下载

1. 选择已配置的源
2. 输入脚本路径（相对于基础 URL）
3. 选择是否立即执行

**示例：**
```
选择源: 1 (Useful Scripts)
输入脚本路径: setup.sh
完整 URL: https://raw.githubusercontent.com/user/repo/main/scripts/setup.sh
```

### 直接 URL 下载

输入任意 HTTP/HTTPS URL 下载脚本：
```
输入脚本URL: https://example.com/tool.sh
# 下载到 ~/.ATT/remote_scripts/
```

---

## Termux Linux 部署

> ⚠️ 此功能仅在 Termux 环境下可用

### 准备工作

首次使用前，安装必要工具：

```
[5] Termux专区 -> [4] 安装部署工具
# 自动安装: proot, tsu, wget, tar
```

或手动安装：
```bash
pkg install proot tsu wget tar
```

### 支持的发行版

| 发行版 | 版本选择 | 推荐部署方式 |
|--------|----------|--------------|
| Ubuntu | 24.04/22.04/20.04 LTS | Proot |
| Debian | 12/11/10 | Proot |
| Alpine | 3.19/3.18/3.17 | Proot/Chroot |
| Arch | latest | Proot |
| Kali | latest | Proot |
| Fedora | 40/39 | Proot |

### 部署流程

**步骤 1：选择发行版和部署方式**
```
选择发行版编号和部署方式 (如: 1C 或 2P)
1C = Ubuntu + Chroot
2P = Debian + Proot
```

**步骤 2：选择版本**
```
选择版本:
[1] 默认(proot-distro最新版) (推荐)
[2] 24.04 (LTS Noble Numbat)
[3] 22.04 (LTS Jammy Jellyfish)
```

**步骤 3：设置容器名称**
```
默认名称: ubuntu-24.04
输入自定义名称: myubuntu
# 名称只能包含字母、数字、下划线和连字符
```

**步骤 4：配置选项**
- 是否删除下载的压缩包（节省空间）
- 是否添加到 `.bashrc`（输入容器名即可进入）

### 部署方式对比

| 特性 | Proot | Chroot |
|------|-------|--------|
| Root 权限 | 不需要 | 需要 (tsu) |
| 性能 | 良好 | 更好 |
| 兼容性 | 优秀 | 一般 |
| 推荐场景 | 日常使用 | 性能敏感任务 |

### 管理已部署的系统

**启动系统：**
```
[S] 启动系统
输入编号: 1
# 直接进入 Linux 环境
```

**备份系统：**
```
[B] 备份系统
输入编号: 1
# 创建 tar.gz 备份文件
```

**删除系统：**
```
[R] 删除系统 - 保留备份
[C] 完全清理 - 删除所有数据
```

### Bashrc 快捷入口

添加到 `.bashrc` 后，可以直接输入容器名称进入：

```bash
# 部署时选择 "添加到bashrc"
$ ubuntu-2404
正在进入 ubuntu-2404...
root@localhost:~# 
```

**管理入口：**
```
[3] 管理Bashrc入口

选项:
[D] 删除入口
[V] 查看函数定义
[R] 重新加载配置
```

---

## 工具箱管理

### 查看日志

```
[4] 工具箱管理 -> [1] 查看日志
# 显示最近 50 条操作日志
```

日志位置：`~/.ATT/logs/toolkit.log`

### 清理缓存

```
[4] 工具箱管理 -> [2] 清理缓存
# 清理临时文件和 7 天前的日志
```

### 备份与恢复

**备份配置：**
```
[4] 工具箱管理 -> [3] 备份配置
# 创建 toolkit_backup_YYYYMMDD_HHMMSS.tar.gz
```

**恢复配置：**
```
[4] 工具箱管理 -> [4] 恢复配置
输入备份文件名: toolkit_backup_20240329_143000.tar.gz
# 恢复所有自定义脚本和配置
```

### 系统信息

显示工具箱环境详情：
- 版本号
- 安装路径
- 脚本统计
- 系统兼容性

---

## 高级技巧

### 1. 脚本自动分类

ATT 通过以下方式自动识别脚本类型：

1. **文件扩展名**：.py / .sh / .go
2. **Shebang 行**：`#!/usr/bin/env python3`
3. **文件内容**：关键字匹配

### 2. 批量导入脚本

将多个脚本放入临时目录，然后批量导入：
```bash
# 复制脚本到工具箱目录
cp /path/to/scripts/*.py ~/.ATT/custom_scripts/python/
cp /path/to/scripts/*.sh ~/.ATT/custom_scripts/shell/

# 重新扫描即可在菜单中看到
```

### 3. 自定义远程源

创建个人脚本仓库：

1. 在 GitHub/GitLab 创建仓库
2. 上传脚本到 `scripts/` 目录
3. 添加远程源：
```
MyRepo|https://raw.githubusercontent.com/username/repo/main/scripts/|个人脚本
```

### 4. Linux 部署高级配置

**手动修改启动脚本：**

Proot 启动脚本位置：
`~/.ATT/linux_deploy/{name}-proot/start-proot.sh`

可以添加自定义绑定：
```bash
exec proot \
    --link2symlink \
    --root-id \
    --cwd=/root \
    --rootfs="${PROOT_DIR}" \
    -b /dev -b /proc -b /sys \
    -b /sdcard:/mnt/sdcard \
    /bin/bash --login
```

### 5. 定时任务集成

将 ATT 功能加入 crontab：
```bash
# 每天凌晨清理日志
0 0 * * * /data/data/com.termux/files/home/.ATT/ATT.sh -c cleanup

# 每周备份
0 0 * * 0 /data/data/com.termux/files/home/.ATT/ATT.sh -c backup
```

---

## 故障排除

### 常见问题

#### Q1: 提示 "未安装curl或wget"

**解决：**
```bash
# Termux
pkg install curl wget

# Debian/Ubuntu
apt install curl wget

# macOS
brew install curl wget
```

#### Q2: Linux 部署下载失败

**可能原因：**
1. 网络连接问题
2. 存储空间不足
3. 下载 URL 失效

**解决：**
```bash
# 检查存储空间
df -h

# 手动下载 rootfs
wget https://.../rootfs.tar.gz -P ~/.ATT/linux_deploy/.downloads/

# 然后重新运行部署，选择不重新下载
```

#### Q3: Chroot 部署提示需要 root

**解决：**
```bash
# 安装 tsu
pkg install tsu

# 使用 tsu 获取 root
tsu

# 或者改用 Proot 部署（无需 root）
```

#### Q4: 脚本执行权限被拒绝

**解决：**
ATT 会自动尝试添加执行权限，如仍失败：
```bash
chmod +x ~/.ATT/custom_scripts/shell/myscript.sh
```

#### Q5: 自定义脚本不显示

**检查：**
1. 脚本是否在正确的子目录（python/shell/go/other）
2. 文件扩展名是否正确
3. 运行 `[R] 刷新列表` 重新扫描

### 日志调试

启用详细日志：
```bash
# 查看完整日志
cat ~/.ATT/logs/toolkit.log

# 实时查看
tail -f ~/.ATT/logs/toolkit.log
```

### 获取帮助

1. 查看工具箱内帮助信息
2. 提交 Issue 到 GitHub
3. 检查 [FAQ](docs/FAQ.md)

---

## 更新日志

### v1.0.0
- ✨ 初始版本发布
- 🚀 支持 Termux/Linux/macOS
- 📦 Linux 发行版部署功能
- 📜 自定义脚本管理
- 🌐 远程脚本支持

---

**文档版本：** 1.0.0  
**最后更新：** 2026-03-29
