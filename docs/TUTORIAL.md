# A-Termux-Integration-Toolbox 使用教程

**文档版本**：v1.0  
**更新时间**：2026-03-29  
**适用脚本**：`ATT.sh`（主程序）

本教程将手把手带你从零开始，完整掌握 **A-Termux-Integration-Toolbox** 的所有功能。无论你是 Termux 新手还是老鸟，都能快速上手。

---

## 📋 目录

- [1. 安装与首次运行](#1-安装与首次运行)
- [2. 主菜单概览](#2-主菜单概览)
- [3. 基础工具（菜单 1）](#3-基础工具菜单-1)
- [4. 自定义工具（菜单 2）](#4-自定义工具菜单-2)
- [5. 远程脚本（菜单 3）](#5-远程脚本菜单-3)
- [6. 工具箱管理（菜单 4）](#6-工具箱管理菜单-4)
- [7. 系统专区（菜单 5）—— Termux Linux 部署中心](#7-系统专区菜单-5-termux-linux-部署中心)
- [8. 常见问题与故障排除](#8-常见问题与故障排除)
- [9. 进阶技巧](#9-进阶技巧)

---

## 1. 安装与首次运行

### 推荐一键安装

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/laninenterline/A-Termux-integration-Toolbox/main/ATT.sh -o ATT.sh

# 添加执行权限
chmod +x ATT.sh

# 首次运行（会自动初始化目录和配置）
./ATT.sh
或者通过 Git 安装
git clone https://github.com/laninenterline/A-Termux-integration-Toolbox.git
cd A-Termux-integration-Toolbox
chmod +x ATT.sh
./ATT.sh
首次运行会自动完成：
创建 \~/.ATT/ 主目录
创建 custom_scripts/、remote_scripts/、logs/ 等子目录
生成 \~/.config/ATT/remote_sources.conf 远程源配置文件
2. 主菜单概览
运行 ./ATT.sh 后会看到彩色主菜单：
══════════════════════════════════════════════
          A-Termux-Integration-Toolbox
══════════════════════════════════════════════
1. 基础工具
2. 自定义工具
3. 远程脚本
4. 工具箱管理
5. 系统专区
0. 退出
请输入选项 [0-5]：
选项
功能
适用场景
1
基础工具
日常系统运维、网络诊断
2
自定义工具
管理自己的 Python/Shell/Go 脚本
3
远程脚本
一键拉取网络上的实用脚本
4
工具箱管理
配置、备份、日志、更新
5
系统专区
Termux 专属 Linux 容器部署
3. 基础工具（菜单 1）
进入后会显示二级菜单，包含：
系统信息：查看 OS、CPU、内存、存储、IP 等
进程管理：查看/搜索/终止进程（支持 top、kill、kill -9）
网络工具：ip addr、ping、端口扫描、下载速度测试
系统维护：更新包、升级系统、查看日志、定时任务
依赖安装：一键安装常用工具（git、vim、python3、nodejs、ffmpeg 等）
示例：安装开发环境
选择「依赖安装」→「安装开发工具」即可自动安装 gcc g++ make cmake python3 等。
4. 自定义工具（菜单 2）
这是最强大的功能之一！你可以把自己的脚本全部集中管理。
目录结构（自动创建）
\~/.ATT/custom_scripts/
├── python/     # .py 文件
├── shell/      # .sh 文件
├── go/         # .go 文件
└── other/      # 其他类型
常用操作流程
新建脚本
选择「新建脚本」→ 选择类型（Python/Shell/Go）→ 输入文件名
脚本会自动带上 # DESC:  描述模板，方便后面显示。
导入脚本
从本地文件复制
从 URL 下载导入（支持 GitHub raw 链接）
运行脚本
工具会自动识别文件类型并执行（python3 / bash / go run）。
管理脚本
查看、编辑（nano/vim）、删除、批量操作。
小贴士：脚本第一行写上 # DESC: 你的脚本描述，运行时会显示在列表中，更直观。
5. 远程脚本（菜单 3）
从网络一键下载并执行脚本。
配置远程源（推荐先做这一步）
编辑配置文件：
nano \~/.config/ATT/remote_sources.conf
默认格式：
实用脚本|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
我的脚本|https://example.com/scripts/|个人脚本仓库
使用流程
选择「从预设源快速下载」
选择一个源
输入脚本相对路径（如 install-nginx.sh）
下载后可立即执行或保存到 remote_scripts/ 目录
6. 工具箱管理（菜单 4）
查看日志（最近 50 行）
清理缓存和旧日志
备份/恢复整个配置（支持 Termux 分享备份文件）
显示工具箱详细信息（版本、目录、脚本数量等）
检查更新（当前为占位，后续会实现自动更新）
7. 系统专区（菜单 5）—— Termux Linux 部署中心
仅在 Termux 环境下可用，这是本工具箱最亮眼的功能！
支持的 Linux 发行版
Ubuntu（24.04/22.04/20.04）
Debian（12/11/10）
Alpine（3.19/3.18/3.17）
Arch Linux
Kali Linux
Fedora（40/39）
两种部署模式
模式
是否需要 Root
性能
推荐场景
Chroot
需要（tsu）
★★★★★
高性能需求
Proot
无需
★★★★☆
普通用户（最推荐）
部署完整步骤（以 Ubuntu 为例）
进入「系统专区」→「部署 Linux 发行版」
选择发行版 → 选择版本
输入容器名称（如 myubuntu）
选择部署模式（Proot 推荐）
工具自动：
下载官方 rootfs
解压到 \~/.ATT/linux_deploy/
配置 DNS
生成启动脚本 start-proot-myubuntu.sh
部署完成后会提示是否加入 \~/.bashrc 快捷入口
启动容器：
# 方式一：直接运行启动脚本
\~/.ATT/linux_deploy/start-proot-myubuntu.sh

# 方式二：通过工具箱管理已部署系统
管理已部署系统：
列出所有容器
启动 / 备份 / 删除 / 彻底清理
8. 常见问题与故障排除
Q1：运行时提示缺少 curl/wget？
→ 进入「基础工具」→「依赖安装」一键安装。
Q2：Proot 部署失败？
→ 确保 Termux 已安装 proot-distro：
pkg install proot-distro
Q3：Chroot 模式无法使用？
→ 需要安装 tsu 并授予 root 权限（Termux:root 环境）。
Q4：脚本卡住或报错？
→ 查看日志：菜单 4 → 查看日志，或检查 \~/.ATT/logs/toolkit.log
9. 进阶技巧
一键启动常用容器：部署完成后把启动命令加入 \~/.bashrc：
alias ubuntu='\~/.ATT/linux_deploy/start-proot-myubuntu.sh'
批量导入脚本：把多个脚本放到一个文件夹，用「导入脚本」→「从本地路径导入」功能一次性导入。
自定义远程源：可以添加自己的私有 GitHub 仓库，实现团队脚本共享。
日志分析：所有操作都有详细日志记录，方便排查问题。
教程完结 🎉
现在你已经掌握了 A-Termux-Integration-Toolbox 的全部核心功能！
建议边看教程边实际操作，10 分钟就能上手。
有任何疑问或功能建议，欢迎在 GitHub Issues 提出。
项目地址：https://github.com/laninenterline/A-Termux-integration-Toolbox
本教程随工具箱同步更新，建议定期使用「工具箱管理」→「检查更新」保持最新。
