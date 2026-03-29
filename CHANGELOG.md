# 更新日志

> 所有 notable 的更改都将记录在此文件中。
>
> 格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
> 并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 计划中的功能
- 🚀 支持插件系统
- 📱 添加 Web UI 管理界面
- 🔧 支持更多 Linux 发行版（Gentoo、openSUSE）
- 🌐 多语言支持（i18n）
- 📊 系统资源监控面板

---

## [1.0.0] - 2024-03-29

### ✨ 新增功能

#### 核心功能
- **跨平台支持** - 智能识别 Termux/Linux/macOS/WSL 环境
- **彩色终端界面** - 美观的交互式菜单系统
- **日志系统** - 完整的操作日志记录
- **配置管理** - 自动创建和管理配置文件

#### 基础工具模块
- **系统信息** - 显示操作系统、硬件、内存、存储信息
- **进程管理** - 进程列表、资源占用、搜索、终止/杀死进程
- **网络工具** - 网络接口查看、Ping 测试、端口扫描、连接查看、下载测试
- **系统维护** - 软件包更新、系统升级、日志查看、服务管理、定时任务
- **依赖安装** - 智能识别包管理器，支持分组安装（基础/开发/网络/系统/Python/Node.js/其他）

#### 自定义脚本模块
- **脚本管理** - 支持 Python/Shell/Go 脚本
- **自动分类** - 根据扩展名和 Shebang 自动识别脚本类型
- **导入功能** - 支持本地路径导入和 URL 下载导入
- **新建脚本** - 提供模板快速创建脚本
- **脚本描述** - 自动提取脚本头部的 DESC 注释

#### 远程脚本模块
- **URL 下载** - 直接从 URL 下载脚本
- **远程源配置** - 支持配置多个远程脚本源
- **快速下载** - 从预设源快速获取脚本
- **缓存管理** - 管理已下载的远程脚本

#### Termux Linux 部署模块
- **发行版支持** - Ubuntu、Debian、Alpine、Arch、Kali、Fedora
- **部署方式** - 支持 Proot（无需 Root）和 Chroot（需要 Root）
- **版本选择** - 支持选择特定版本或使用最新版
- **自定义名称** - 支持自定义容器名称
- **Bashrc 集成** - 一键添加容器入口到 .bashrc
- **系统管理** - 启动、备份、删除、清理已部署的系统
- **DNS 配置** - 自动配置容器 DNS

#### 工具箱管理模块
- **日志查看** - 查看工具箱运行日志
- **缓存清理** - 清理临时文件和过期日志
- **配置备份** - 打包备份所有配置和脚本
- **配置恢复** - 从备份文件恢复配置
- **系统信息** - 显示工具箱环境详情
- **更新检查** - 检查工具箱更新

### 🔧 技术细节

#### 架构设计
- 模块化设计，各功能模块独立
- 统一的菜单显示系统
- 环境自适应（自动检测 Termux/Linux/macOS）
- 错误处理和日志记录机制

#### 代码规范
- 遵循 Bash 最佳实践
- 使用 `shellcheck` 兼容的语法
- 统一的命名规范和注释风格
- 支持 `set -euo pipefail` 错误处理

### 📝 文档
- [README.md](README.md) - 项目介绍和快速开始
- [TUTORIAL.md](docs/TUTORIAL.md) - 详细使用教程
- [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - 行为准则
- [FAQ.md](docs/FAQ.md) - 常见问题解答

### 🐛 已知问题
- 在某些旧版本 Termux 上可能出现显示问题
- Chroot 部署需要设备已 Root
- 部分网络功能需要 root 权限才能完整运行

### 🔒 安全性
- 所有操作在本地完成，不上传数据
- 脚本执行前需要用户确认
- 敏感操作（删除、清理）需要二次确认
- 日志中不包含敏感信息

---

## 版本历史格式说明

### 版本号格式
`MAJOR.MINOR.PATCH`

- **MAJOR** - 不兼容的 API 更改
- **MINOR** - 向后兼容的功能添加
- **PATCH** - 向后兼容的问题修复

### 变更类型标签

| 标签 | 说明 |
|------|------|
| ✨ `Added` | 新功能 |
| 🔧 `Changed` | 现有功能的变更 |
| 🗑️ `Deprecated` | 已弃用的功能 |
| 🗑️ `Removed` | 已移除的功能 |
| 🐛 `Fixed` | Bug 修复 |
| 🔒 `Security` | 安全相关的修复 |

---

## 如何阅读此日志

### 用户视角
关注 `[Added]` 和 `[Fixed]` 部分：
- 了解新功能
- 了解已修复的问题
- 决定是否需要更新

### 开发者视角
关注所有变更类型：
- 了解 API 变化
- 了解弃用通知
- 了解架构变更

---

## 更新建议

### 从早期版本更新

```bash
# 1. 备份现有配置
./ATT.sh
# [4] 工具箱管理 -> [3] 备份配置

# 2. 下载新版本
cd A-Termux-integration-Toolbox
git pull origin main

# 3. 测试新版本
./ATT.sh

# 4. 如有问题，恢复配置
# [4] 工具箱管理 -> [4] 恢复配置
```

### 版本兼容性

| 版本 | 兼容性 | 说明 |
|------|--------|------|
| 1.0.0 | ✅ 完全兼容 | 初始版本 |

---

## 贡献者

感谢所有为这个项目做出贡献的人！

### 核心维护者
- @laninenterline - 项目创建者和主要维护者

### 特别感谢
- [Termux 团队](https://termux.dev/) - 提供优秀的终端环境
- [proot-distro 团队](https://github.com/termux/proot-distro) - Linux 部署工具
- 所有提交 Issue 和 PR 的社区成员

---

## 相关链接

- [项目主页](https://github.com/laninenterline/A-Termux-integration-Toolbox)
- [发布页面](https://github.com/laninenterline/A-Termux-integration-Toolbox/releases)
- [问题追踪](https://github.com/laninenterline/A-Termux-integration-Toolbox/issues)
- [讨论区](https://github.com/laninenterline/A-Termux-integration-Toolbox/discussions)

---

**最后更新：2026-03-29**

[未发布]: https://github.com/laninenterline/A-Termux-integration-Toolbox/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/laninenterline/A-Termux-integration-Toolbox/releases/tag/v1.0.0
