# 常见问题解答 (FAQ)

> A-Termux-Integration-Toolbox 常见问题解答

## 📑 快速导航

- [安装问题](#安装问题)
- [使用问题](#使用问题)
- [Termux 专区](#termux-专区)
- [Linux 部署问题](#linux-部署问题)
- [自定义脚本问题](#自定义脚本问题)
- [远程脚本问题](#远程脚本问题)
- [性能问题](#性能问题)
- [其他问题](#其他问题)

---

## 安装问题

### Q1: 运行 ATT.sh 时提示 "Permission denied" 怎么办？

**A:** 这是因为脚本没有执行权限，添加执行权限即可：

```bash
chmod +x ATT.sh

# 或者
chmod 755 ATT.sh
```

### Q2: 提示 "未安装 curl 或 wget" 怎么办？

**A:** 根据您的系统安装相应工具：

```bash
# Termux
pkg install curl wget

# Debian/Ubuntu
apt update && apt install curl wget

# CentOS/RHEL/Fedora
yum install curl wget
# 或
dnf install curl wget

# macOS
brew install curl wget

# Arch Linux
pacman -S curl wget
```

### Q3: 首次运行时初始化失败？

**A:** 可能的原因和解决方法：

1. **存储空间不足**
   ```bash
   df -h
   # 确保有足够的可用空间（建议至少 100MB）
   ```

2. **权限问题**
   ```bash
   # 检查 HOME 目录权限
   ls -ld $HOME

   # 确保有写入权限
   chmod 755 $HOME
   ```

3. **手动创建目录**
   ```bash
   mkdir -p ~/.ATT/{custom_scripts/{python,shell,go,other},remote_scripts,linux_deploy,logs,temp}
   mkdir -p ~/.config/ATT
   ```

### Q4: 可以在 Windows 上运行吗？

**A:** 可以通过以下方式在 Windows 上运行：

1. **WSL (推荐)** - Windows Subsystem for Linux
   ```bash
   # 在 WSL 中运行
   ./ATT.sh
   ```

2. **Git Bash** - 部分功能可用，但 Linux 部署功能不可用

3. **Cygwin/MSYS2** - 支持基本功能

4. **虚拟机** - VirtualBox/VMware 运行 Linux

**注意：** Termux 专属功能（Linux 部署）仅在 Termux 环境中可用。

---

## 使用问题

### Q5: 菜单显示乱码或颜色异常？

**A:** 可能是终端不支持 ANSI 颜色代码：

```bash
# 检查终端类型
echo $TERM

# 尝试设置支持颜色的终端类型
export TERM=xterm-256color

# 或者禁用颜色（修改脚本）
# 在脚本开头添加：
export NO_COLOR=1
```

### Q6: 如何查看工具箱日志？

**A:** 日志文件位于 `~/.ATT/logs/toolkit.log`：

```bash
# 查看完整日志
cat ~/.ATT/logs/toolkit.log

# 查看最近 50 行
tail -n 50 ~/.ATT/logs/toolkit.log

# 实时查看
tail -f ~/.ATT/logs/toolkit.log

# 在工具箱内查看
# [4] 工具箱管理 -> [1] 查看日志
```

### Q7: 如何备份我的配置？

**A:** 有两种方式：

**方式一：使用工具箱内置功能**
```
[4] 工具箱管理 -> [3] 备份配置
# 生成 toolkit_backup_YYYYMMDD_HHMMSS.tar.gz
```

**方式二：手动备份**
```bash
# 备份整个配置目录
tar -czvf ATT_backup_$(date +%Y%m%d).tar.gz ~/.ATT ~/.config/ATT

# 仅备份自定义脚本
tar -czvf scripts_backup.tar.gz ~/.ATT/custom_scripts/
```

### Q8: 如何完全卸载工具箱？

**A:** 执行以下命令：

```bash
# 1. 删除工具箱目录
rm -rf ~/.ATT
rm -rf ~/.config/ATT

# 2. 删除 bashrc 中的容器入口（如有）
# 编辑 ~/.bashrc，删除 Shell Toolkit 相关的函数和别名

# 3. 删除脚本（如果在特定位置）
rm -f ~/ATT.sh
```

---

## Termux 专区

### Q9: 为什么其他系统看不到 "Termux 专区" 的功能？

**A:** "Termux 专区" 的 Linux 部署功能是 Termux 环境专属的，需要：
- Android 设备
- Termux 应用
- proot/proot-distro 工具

在其他系统（Linux/macOS/WSL）上，进入专区会显示预留信息。

### Q10: Termux 提示 "proot-distro: command not found"？

**A:** 需要安装 proot-distro：

```bash
pkg install proot-distro

# 或者通过工具箱安装
# [5] Termux专区 -> [4] 安装部署工具
```

### Q11: Chroot 部署为什么需要 Root？

**A:** Chroot 是 Linux 系统调用，需要 root 权限才能执行。在 Termux 中需要：

1. **设备已 Root** - 获取超级用户权限
2. **安装 tsu** - Termux 的 su 包装器
   ```bash
   pkg install tsu
   ```
3. **使用 tsu 运行**
   ```bash
   tsu -c "bash /path/to/start-chroot.sh"
   ```

**建议：** 如果设备未 Root，请使用 Proot 部署方式。

---

## Linux 部署问题

### Q12: Linux 部署下载速度很慢或失败？

**A:** 可能的解决方案：

1. **更换网络环境** - 尝试使用不同的 WiFi 或移动数据

2. **使用镜像源** - 手动修改脚本中的下载 URL：
   ```bash
   # 编辑 ATT.sh，找到 get_rootfs_url 函数
   # 将官方源替换为镜像源
   # 例如：清华镜像、中科大镜像等
   ```

3. **手动下载** - 先手动下载 rootfs，然后放置到正确位置：
   ```bash
   # 下载到工具箱下载目录
   wget https://.../rootfs.tar.gz -P ~/.ATT/linux_deploy/.downloads/

   # 然后重新运行部署，选择不重新下载
   ```

4. **检查存储空间**
   ```bash
   df -h
   # 确保有至少 2GB 可用空间
   ```

### Q13: 部署后无法进入 Linux 系统？

**A:** 常见原因和解决方法：

1. **DNS 配置问题**
   ```bash
   # 进入容器后检查 DNS
   cat /etc/resolv.conf

   # 手动添加 DNS
   echo "nameserver 8.8.8.8" >> /etc/resolv.conf
   echo "nameserver 114.114.114.114" >> /etc/resolv.conf
   ```

2. **权限问题（Proot）**
   ```bash
   # 检查 proot 是否正确安装
   which proot

   # 重新安装 proot
   pkg install proot
   ```

3. **rootfs 损坏**
   ```bash
   # 删除并重新部署
   rm -rf ~/.ATT/linux_deploy/{container-name}
   # 然后重新运行部署流程
   ```

### Q14: 如何给部署的 Linux 安装图形界面？

**A:** 可以通过以下步骤安装：

```bash
# 1. 进入 Linux 容器
proot-distro login ubuntu

# 2. 更新系统
apt update && apt upgrade -y

# 3. 安装图形界面（以 XFCE 为例）
apt install xfce4 xfce4-goodies -y

# 4. 安装 VNC 服务器
apt install tigervnc-standalone-server -y

# 5. 设置 VNC 密码
vncpasswd

# 6. 启动 VNC 服务器
vncserver :1 -geometry 1280x720 -depth 24

# 7. 在 Android 上安装 VNC Viewer 应用连接
```

### Q15: 部署的 Linux 如何访问 Termux 的文件？

**A:** 文件访问方式：

**Proot 方式：**
- 默认已绑定 `/sdcard` 目录
- 在容器内访问：`/sdcard/`
- 或者：`/data/data/com.termux/files/home/`

**Chroot 方式：**
- 需要手动挂载
- 启动脚本中已包含基本绑定

**自定义绑定：**
```bash
# 编辑启动脚本，添加绑定
-b /data/data/com.termux/files/home:/mnt/termux
```

---

## 自定义脚本问题

### Q16: 导入的脚本为什么不显示在菜单中？

**A:** 检查以下几点：

1. **文件扩展名** - 确保是支持的格式（.py, .sh, .go, .bash）

2. **文件位置** - 确保在正确的子目录：
   ```
   ~/.ATT/custom_scripts/
   ├── python/     # .py 文件
   ├── shell/      # .sh, .bash 文件
   ├── go/         # .go 文件
   └── other/      # 其他类型
   ```

3. **刷新列表** - 在自定义工具菜单按 `R` 刷新

4. **文件权限** - 确保文件可读：
   ```bash
   chmod 644 ~/.ATT/custom_scripts/shell/myscript.sh
   ```

### Q17: 脚本执行时提示 "command not found"？

**A:** 可能的原因：

1. **缺少解释器**
   ```bash
   # Python 脚本
   pkg install python

   # Go 程序
   pkg install golang
   ```

2. **Shebang 行错误**
   ```bash
   # 确保脚本第一行正确
   #!/bin/bash
   #!/usr/bin/env python3
   ```

3. **Windows 换行符问题**
   ```bash
   # 转换换行符
   dos2unix script.sh
   # 或
   sed -i 's/\r$//' script.sh
   ```

### Q18: 如何设置脚本自动运行？

**A:** 使用 Termux 的定时任务或启动脚本：

```bash
# 方式一：使用 cron (需要安装 crontab)
pkg install cronie
# 编辑 crontab
crontab -e
# 添加：
0 8 * * * /data/data/com.termux/files/home/.ATT/custom_scripts/shell/myscript.sh

# 方式二：Termux 启动时运行
# 编辑 ~/.bashrc，添加：
bash /data/data/com.termux/files/home/.ATT/custom_scripts/shell/myscript.sh
```

---

## 远程脚本问题

### Q19: 远程脚本下载失败？

**A:** 可能的原因：

1. **网络问题** - 检查网络连接
   ```bash
   ping raw.githubusercontent.com
   ```

2. **SSL 证书问题**
   ```bash
   # 更新证书
   pkg install ca-certificates

   # 或者使用 -k 选项跳过证书验证（不推荐）
   curl -k https://...
   ```

3. **URL 错误** - 确保 URL 可以直接访问

4. **防火墙限制** - 检查是否被防火墙阻止

### Q20: 如何添加私有仓库的脚本？

**A:** 配置私有远程源：

```bash
# 编辑配置文件
nano ~/.config/ATT/remote_sources.conf

# 添加私有源（需要认证的）
MyPrivateRepo|https://username:token@github.com/user/repo/main/scripts/|私有脚本

# 或者使用 GitHub Personal Access Token
MyRepo|https://TOKEN@raw.githubusercontent.com/user/repo/main/scripts/|说明
```

**注意：** 请妥善保管您的 Token，不要将其提交到公开仓库。

---

## 性能问题

### Q21: 工具箱运行很慢？

**A:** 优化建议：

1. **清理日志**
   ```
   [4] 工具箱管理 -> [2] 清理缓存
   ```

2. **减少自定义脚本数量**
   - 删除不需要的脚本
   - 合并相关功能的脚本

3. **检查存储空间**
   ```bash
   df -h
   # 确保存储空间充足
   ```

4. **关闭不必要的日志记录**
   - 修改脚本中的日志级别

### Q22: Linux 部署后占用空间太大？

**A:** 优化空间使用：

```bash
# 1. 删除下载的压缩包
rm ~/.ATT/linux_deploy/.downloads/*.tar.gz

# 2. 清理包管理器缓存（在容器内执行）
apt clean        # Debian/Ubuntu
yum clean all    # CentOS/RHEL

# 3. 删除不必要的包
apt autoremove   # Debian/Ubuntu

# 4. 备份后删除不常用的容器
```

### Q23: Proot 运行速度很慢？

**A:** Proot 的性能优化：

1. **使用 Chroot** - 如果设备已 Root，Chroot 性能更好

2. **减少绑定目录** - 编辑启动脚本，移除不必要的绑定

3. **使用轻量级发行版** - Alpine Linux 比 Ubuntu 更轻量

4. **关闭不必要的服务** - 在容器内禁用不需要的系统服务

---

## 其他问题

### Q24: 如何更新工具箱到最新版本？

**A:** 更新方法：

```bash
# 方式一：通过 Git 更新
cd A-Termux-integration-Toolbox
git pull origin main

# 方式二：重新下载
# 下载最新版本的 ATT.sh 并替换旧文件

# 方式三：使用工具箱内置检查（如有）
# [4] 工具箱管理 -> [6] 检查更新
```

**注意：** 更新前建议备份配置：
```
[4] 工具箱管理 -> [3] 备份配置
```

### Q25: 发现 Bug 如何报告？

**A:** 请按照以下步骤报告：

1. **搜索现有 Issue** - 避免重复报告

2. **收集信息**：
   - 工具箱版本
   - 操作系统和版本
   - 复现步骤
   - 错误信息（截图或文本）

3. **创建 Issue** - 使用 Bug 报告模板

4. **等待回复** - 维护者会尽快处理

### Q26: 可以为项目做贡献吗？

**A:** 非常欢迎！请参考 [CONTRIBUTING.md](CONTRIBUTING.md) 了解：
- 如何提交 Bug 报告
- 如何建议新功能
- 代码贡献流程
- 代码规范

### Q27: 工具箱会收集我的数据吗？

**A:** 不会。ATT 工具箱：
- ❌ 不上传任何数据到远程服务器
- ❌ 不收集用户行为信息
- ❌ 不包含追踪代码
- ✅ 所有操作在本地完成
- ✅ 日志仅保存在本地 `~/.ATT/logs/`

### Q28: 如何联系维护者？

**A:** 联系方式：
- **GitHub Issues** - 技术问题和 Bug 报告
- **GitHub Discussions** - 一般性讨论
- **Pull Requests** - 代码贡献

---

## 故障排除流程图

```
遇到问题
    ↓
查看日志 → ~/.ATT/logs/toolkit.log
    ↓
搜索 FAQ → 本文档
    ↓
搜索 Issues → GitHub Issues
    ↓
创建 Issue → 使用模板提交
```

---

## 相关链接

- [详细教程](TUTORIAL.md) - 完整使用指南
- [贡献指南](CONTRIBUTING.md) - 如何参与项目
- [行为准则](CODE_OF_CONDUCT.md) - 社区规范
- [GitHub Issues](https://github.com/laninenterline/A-Termux-integration-Toolbox/issues) - 问题追踪

---

**最后更新：2026-03-29**

如果这里没有您的问题，请在 [GitHub Issues](https://github.com/laninenterline/A-Termux-integration-Toolbox/issues) 中提问！
