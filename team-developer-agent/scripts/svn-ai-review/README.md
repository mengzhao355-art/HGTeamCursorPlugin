# SVN AI 代码审查脚本

TortoiseSVN Pre-commit Hook 与手动审查共用，随 `team-developer-agent` 插件发布。

## 快速开始

### 1. 安装 Cursor CLI

```powershell
irm 'https://cursor.com/install?win32=true' | iex
agent login
agent status
```

### 2. 一键部署到本机稳定路径（推荐）

插件已安装后，在本目录执行：

```powershell
cd team-developer-agent\scripts\svn-ai-review
.\Deploy-SvnAiReview.ps1
# 或指定工作副本：
.\Deploy-SvnAiReview.ps1 -WorkingCopyPath "E:\project"
```

脚本会：

1. 自动定位已安装的 `team-developer-agent` / `hgteamcursorplugin` 脚本源
2. 复制到 `%LOCALAPPDATA%\ExoscopeTeam\svn-ai-review`（各机器路径不同，属正常）
3. 检查 Cursor CLI
4. 打印**本机** TortoiseSVN Pre-commit Hook 配置

亦可调用兼容入口：

```powershell
.\install-tortoisesvn-hook.ps1 -WorkingCopyPath "E:\your\svn\working\copy" -Force
```

按输出说明在 TortoiseSVN → Settings → Hook Scripts 注册 **Pre-commit** Hook。

**Command Line 示例**（不要手写 `%PATH%` 等参数，TortoiseSVN 会自动追加）：

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\你\AppData\Local\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1"
```

| 字段 | 值 |
|------|-----|
| Hook Type | **Pre-commit** |
| Wait for the script to finish | **勾选** |
| 提交方式 | 资源管理器 **TortoiseSVN → Commit** |

**说明**：Hook 配置在本机 Tortoise（注册表），不会随 SVN 提交共享；每人各自配置，无团队路径冲突。

**常见错误**：Command Line 末尾手写 `%PATH% %DEPTH% %MESSAGEFILE% %CWD%`，会报「TortoiseSVN 未替换 PATH」。删除这些占位符即可。

### 3. 手动审查（可选）

```powershell
& "$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\Invoke-SvnAiReview.ps1" `
  -WorkspacePath "E:\your\svn\working\copy"
```

或在 Cursor IDE 中使用 **`/team:svn-review`**。

## 项目侧配置

| 文件/目录 | 说明 |
|-----------|------|
| `.review/` | 运行时 diff 与报告，加入 **svn:ignore** |
| `review-config.local.json` | 个人覆盖配置（可选，加入 svn:ignore） |

`review-config.local.json` 示例：

```json
{
  "gateMode": "block_critical",
  "openReportAfterReview": true
}
```

## gateMode

| 值 | 行为 |
|----|------|
| `advisory`（默认） | 弹窗确认，用户可取消提交 |
| `block_critical` | 含 `🔴 必须修复` 时默认阻止，可 override |
| `block_all_issues` | 有任何问题即阻止 |

## 文件说明

| 文件 | 用途 |
|------|------|
| `Deploy-SvnAiReview.ps1` | **一键部署**（定位插件、拷贝稳定目录、打印本机 Hook） |
| `review-pre-commit.ps1` | TortoiseSVN Hook 入口 |
| `Invoke-SvnAiReview.ps1` | 核心审查逻辑 |
| `Resolve-PluginRoot.ps1` | 定位插件安装路径 |
| `Show-ReviewDialog.ps1` | 审查结果确认对话框 |
| `install-tortoisesvn-hook.ps1` | 部署入口（优先转调 Deploy-SvnAiReview.ps1） |
| `review-config.json` | 团队默认配置 |
| `svn-ai-review-setup-sop.md` | 团队安装 SOP |