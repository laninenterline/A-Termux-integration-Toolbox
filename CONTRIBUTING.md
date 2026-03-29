# 贡献指南

首先，感谢您考虑为 A-Termux-Integration-Toolbox 做出贡献！正是像您这样的贡献者让这个项目变得更好。

## 📋 目录

- [行为准则](#行为准则)
- [我可以如何贡献？](#我可以如何贡献)
- [开发工作流程](#开发工作流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [测试指南](#测试指南)
- [文档贡献](#文档贡献)
- [发布流程](#发布流程)
- [社区](#社区)

---

## 行为准则

本项目要求所有参与者遵守我们的 [行为准则](CODE_OF_CONDUCT.md)。请阅读全文，确保您了解可接受的行为标准。

---

## 我可以如何贡献？

### 🐛 报告 Bug

如果您发现了 bug，请先检查是否已经在 [Issues](https://github.com/laninenterline/A-Termux-integration-Toolbox/issues) 中被报告过。

如果没有，请创建一个新的 Issue，并包含以下信息：

- **问题描述**：清晰简洁地描述 bug 是什么
- **复现步骤**：详细说明如何复现该问题
- **预期行为**：描述您期望发生的行为
- **实际行为**：描述实际发生的行为
- **环境信息**：
  - 操作系统及版本（如 Android 14 + Termux 0.118）
  - Bash 版本（运行 `bash --version`）
  - 工具箱版本
- **截图**：如果适用，添加截图帮助解释问题
- **附加信息**：任何其他相关信息

**Bug 报告模板：**
```markdown
**描述**
简要描述 bug。

**复现步骤**
1. 进入 '...'
2. 选择 '....'
3. 滚动到 '....'
4. 出现错误

**预期行为**
清晰描述您期望发生的情况。

**环境信息**
- OS: [如 Android 14]
- Termux: [如 0.118]
- Bash: [如 5.2.15]
- 工具箱版本: [如 1.0.0]

**截图**
如有需要，添加截图。

**附加信息**
其他相关信息。
```

### 💡 建议新功能

我们欢迎新功能的建议！请创建 Issue 并：

- 使用清晰的标题描述功能
- 详细描述该功能的工作原理
- 解释为什么这个功能对项目有价值
- 如果可能，提供实现思路或示例代码

### 🔧 提交代码贡献

#### 准备工作流程

1. **Fork 仓库**
   ```bash
   # 点击 GitHub 上的 Fork 按钮
   ```

2. **克隆您的 Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/A-Termux-integration-Toolbox.git
   cd A-Termux-integration-Toolbox
   ```

3. **添加上游仓库**
   ```bash
   git remote add upstream https://github.com/laninenterline/A-Termux-integration-Toolbox.git
   ```

4. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix-name
   ```

---

## 开发工作流程

### 分支命名规范

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| 新功能 | `feature/功能描述` | `feature/linux-deployment` |
| Bug 修复 | `fix/问题描述` | `fix/process-kill-error` |
| 文档 | `docs/文档描述` | `docs/tutorial-update` |
| 重构 | `refactor/重构描述` | `refactor/menu-system` |
| 性能优化 | `perf/优化描述` | `perf/script-loading` |
| 测试 | `test/测试描述` | `test/network-tools` |

### 开发步骤

1. **保持与上游同步**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **进行您的修改**
   - 编写代码
   - 更新文档
   - 添加测试（如适用）

3. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   ```

4. **推送到您的 Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **创建 Pull Request**
   - 前往原仓库创建 PR
   - 填写 PR 模板
   - 等待审核

---

## 代码规范

### Bash 脚本规范

#### 代码风格

```bash
#!/bin/bash
#===============================================================================
# 模块名称 - 简短描述
#===============================================================================
# 作者: 您的名字
# 日期: YYYY-MM-DD
#===============================================================================

set -o pipefail

# 常量使用大写 + 下划线
readonly MAX_RETRIES=3
readonly TIMEOUT=30

# 变量使用小写 + 下划线
local user_input=""
local script_path=""

# 函数命名使用小写 + 下划线
my_function() {
    local param1="$1"
    local param2="$2"

    # 函数体缩进 4 空格
    if [[ -n "$param1" ]]; then
        echo "处理: $param1"
    fi
}

# 错误处理
if ! some_command; then
    log_error "命令执行失败"
    return 1
fi
```

#### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 常量 | `全大写 + 下划线` | `readonly MAX_COUNT=100` |
| 全局变量 | `全大写` | `SCRIPT_NAME="ATT"` |
| 局部变量 | `小写 + 下划线` | `local file_path=""` |
| 函数 | `小写 + 下划线` | `show_menu()` |
| 私有函数 | `_前缀` | `_internal_helper()` |

#### 注释规范

```bash
# 单行注释前有空格

#-------------------------------------------------------------------------------
# 函数说明
# 参数:
#   $1 - 参数1说明
#   $2 - 参数2说明
# 返回:
#   0 - 成功
#   1 - 失败
#-------------------------------------------------------------------------------
my_function() {
    # 代码...
}

# TODO: 待办事项说明
# FIXME: 需要修复的问题
# NOTE: 重要说明
# HACK: 临时解决方案
```

#### 错误处理

```bash
# 使用 set 选项
set -o errexit   # 命令失败时退出
set -o nounset   # 使用未定义变量时报错
set -o pipefail  # 管道中任何命令失败时退出

# 或使用
set -euo pipefail

# 错误处理函数
handle_error() {
    local line=$1
    log_error "脚本在第 $line 行发生错误"
    exit 1
}
trap 'handle_error $LINENO' ERR
```

### 代码结构

```bash
#!/bin/bash

#===============================================================================
# 头部信息
#===============================================================================

#-------------------------------------------------------------------------------
# 配置和常量
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 工具函数
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 核心功能
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 主程序
#-------------------------------------------------------------------------------

main() {
    init
    run
    cleanup
}

main "$@"
```

---

## 提交规范

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type（必须）

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 仅文档更改 |
| `style` | 不影响代码含义的更改（空格、格式化、分号等） |
| `refactor` | 既不修复 bug 也不添加功能的代码更改 |
| `perf` | 提升性能的代码更改 |
| `test` | 添加缺失的测试或更正现有测试 |
| `chore` | 构建过程或辅助工具的变动 |
| `ci` | CI 配置更改 |

#### Scope（可选）

指定更改的范围：

- `core` - 核心功能
- `menu` - 菜单系统
- `tools` - 工具模块
- `deploy` - Linux 部署
- `scripts` - 脚本管理
- `docs` - 文档
- `deps` - 依赖

#### Subject（必须）

- 使用祈使语气（"添加" 而不是 "添加了"）
- 首字母不大写
- 末尾不加句号
- 不超过 50 个字符

#### Body（可选）

- 使用祈使语气
- 解释 **为什么** 做此更改，而不是 **怎么** 做的
- 可以有多行
- 每行不超过 72 个字符

#### Footer（可选）

- 引用 Issue 或 PR: `Closes #123`, `Fixes #456`
- 破坏性更改: `BREAKING CHANGE: 描述`

### 提交示例

```bash
# 新功能
feat(deploy): 添加 Alpine Linux 支持

添加 Alpine Linux 3.19 和 3.18 版本的部署支持。
包括 proot 和 chroot 两种部署方式。

Closes #42

# Bug 修复
fix(tools): 修复进程列表显示错误

在 Termux 环境下，ps 命令参数与标准 Linux 不同，
添加环境检测以使用正确的参数。

Fixes #55

# 文档
docs: 更新 Linux 部署教程

添加关于自定义容器名称的说明，
以及 bashrc 快捷入口的使用方法。

# 重构
refactor(menu): 重构主菜单系统

将菜单显示逻辑提取为独立函数，
提高代码可读性和可维护性。
```

---

## 测试指南

### 手动测试清单

在提交 PR 之前，请确保：

- [ ] 代码在 Termux 环境测试通过
- [ ] 代码在标准 Linux 环境测试通过
- [ ] 所有菜单选项可以正常导航
- [ ] 新功能可以正常工作
- [ ] 没有引入新的 bug
- [ ] 错误处理正常工作
- [ ] 日志记录正常

### 测试环境

**Termux 测试：**
```bash
# 安装 Termux 从 F-Droid
# 安装必要依赖
pkg update
pkg install bash curl wget git

# 运行工具箱
./ATT.sh
```

**Linux 测试：**
```bash
# 在 Docker 中测试不同发行版
docker run -it -v $(pwd):/workspace ubuntu:22.04 bash
docker run -it -v $(pwd):/workspace debian:12 bash
```

---

## 文档贡献

### 文档类型

- **README.md** - 项目主页，包含基本信息
- **docs/TUTORIAL.md** - 详细使用教程
- **docs/API.md** - API 文档（如适用）
- **docs/FAQ.md** - 常见问题解答
- **CHANGELOG.md** - 版本更新日志

### 文档规范

- 使用 Markdown 格式
- 代码块指定语言类型
- 使用中文或英文（保持与现有文档一致）
- 添加适当的标题层级
- 使用表格展示结构化信息

---

## 发布流程

### 版本号规范

使用 [语义化版本](https://semver.org/lang/zh-CN/)：

- `MAJOR.MINOR.PATCH`
- `MAJOR` - 不兼容的 API 更改
- `MINOR` - 向后兼容的功能添加
- `PATCH` - 向后兼容的问题修复

### 发布步骤

1. 更新 `CHANGELOG.md`
2. 更新版本号（脚本中的 `VERSION` 变量）
3. 创建 Git 标签
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```
4. 在 GitHub 创建 Release

---

## 社区

### 沟通渠道

- **GitHub Issues** - Bug 报告和功能建议
- **GitHub Discussions** - 一般性讨论和问答
- **Pull Requests** - 代码审查和贡献

### 成为维护者

长期贡献者可以申请成为项目维护者。维护者职责包括：

- 审查和合并 PR
- 管理 Issues
- 发布新版本
- 维护文档

---

## 常见问题

### Q: 我没有编程经验，可以贡献吗？

**A:** 当然可以！您可以：
- 报告 bug
- 改进文档
- 翻译内容
- 提供使用反馈
- 帮助回答其他用户的问题

### Q: 我的 PR 多久会被审查？

**A:** 通常在 3-7 天内会有初步反馈。请耐心等待，维护者都是志愿者。

### Q: 我可以提交不完整的代码吗？

**A:** 可以，但请在 PR 标题中添加 `[WIP]`（Work In Progress）标记，并在完成后移除。

### Q: 代码风格必须严格遵守吗？

**A:** 是的，统一的代码风格有助于维护。但如果是小的风格问题，维护者可能会在合并时帮助修复。

---

## 致谢

再次感谢您为 A-Termux-Integration-Toolbox 做出的贡献！

如果您有任何问题，请随时在 GitHub 上创建 Issue 或 Discussion。

**Happy Coding! 🚀**

---

**最后更新：2026-03-29**
