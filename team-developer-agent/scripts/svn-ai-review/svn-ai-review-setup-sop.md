# SVN AI 代码审查 — 团队成员安装指南

审查规则与脚本由 **team-developer-agent** 插件提供，本项目无需维护额外脚本。

## 「稳定启动器」是什么？

Cursor 插件安装在本机缓存目录，路径里带随机 hash，例如：

```
C:\Users\你\.cursor\plugins\cache\team-plugins\team-developer-agent\7c40c13a...\scripts\svn-ai-review\
```

插件一更新，这个 hash 路径就可能变。**TortoiseSVN Hook 必须填固定路径**，不能每次更新后改配置。

`install-tortoisesvn-hook.ps1` 会在本机创建一个**固定目录**（稳定启动器）：

```
C:\Users\你\AppData\Local\ExoscopeTeam\svn-ai-review\
```

并通过 Windows 目录联接（junction）指向插件里最新的脚本。TortoiseSVN 始终调用这个固定路径，插件更新后一般**无需改 Hook 配置**。

---

## 团队成员：3 步完成配置（约 5 分钟）

### 第 1 步：安装 Cursor CLI 并登录

在 PowerShell 中执行（只需一次）：

```powershell
irm 'https://cursor.com/install?win32=true' | iex
agent login
agent status
```

看到已登录状态即可。

### 第 2 步：安装 team-developer-agent 插件

在 Cursor：**Settings → Plugins → Team Marketplaces**，确保已安装 **team-developer-agent**（团队 Marketplace 导入后安装）。

### 第 3 步：运行安装脚本 + 配置 TortoiseSVN

**3a. 运行稳定启动器安装脚本**（只需一次）

在 PowerShell 中执行（复制整段即可）：

```powershell
$pluginScript = Get-ChildItem "$env:USERPROFILE\.cursor\plugins\cache\team-plugins" -Recurse -Filter "install-tortoisesvn-hook.ps1" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $pluginScript) { Write-Error "未找到插件，请先在 Cursor 安装 team-developer-agent"; return }
& $pluginScript.FullName
```

脚本会输出 **Hook 命令行**，请使用 **PowerShell 直接调用**（推荐）。
TortoiseSVN 会自动按 `PATH DEPTH MESSAGEFILE CWD` 顺序追加参数，**Command Line 中不要手写 `%PATH%` 等占位符**：

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\你\AppData\Local\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1"
```

**3b. 在 TortoiseSVN 里粘贴 Hook**（必须用 TortoiseSVN 右键提交）

1. 资源管理器 → **TortoiseSVN** → **Settings** → **Hook Scripts** → **Add**
2. 填写：

| 字段 | 值 |
|------|-----|
| Hook Type | **Pre-commit**（勿选 Manual Pre-commit） |
| Working Copy Path | **`E:\project`**（SVN 工作副本根，不是 zmDevelop 子目录） |
| Command Line | 上一步 **powershell.exe ... review-pre-commit.ps1** 整行（不要附加 `%PATH%` 等参数） |
| Wait for the script to finish | **勾选** |

3. 提交方式：必须在资源管理器用 **TortoiseSVN → Commit**。

**切勿**在 Command Line 中手写 `%PATH%` / `%DEPTH%` / `%MESSAGEFILE%` / `%CWD%`：TortoiseSVN 会自动追加这些参数，手写后可能作为普通字符串传入脚本，报「未替换 PATH」。

**若报错 `PATH 文件不存在: %PATH%` 或 `TortoiseSVN 未替换 %PATH%`**：删除 Command Line 末尾手写的 `%PATH% %DEPTH% %MESSAGEFILE% %CWD%`，只保留 `powershell.exe ... review-pre-commit.ps1`。

### 可选：项目 svn:ignore

在工作副本根目录的 svn:ignore 中加入（避免审查报告被误提交）：

```
.review
review-config.local.json
```

### 可选：个人门禁配置

复制项目根目录的 `review-config.local.json.example` 为 `review-config.local.json`，例如改为硬门禁：

```json
{ "gateMode": "block_critical" }
```

---

## 日常使用

| 方式 | 何时用 |
|------|--------|
| **TortoiseSVN 提交** | 点 OK 后自动审查，弹窗确认后提交 |
| **`/team:svn-review`** | 提交前在 Cursor 里手动预检 |
| **`review-manual.ps1`** | 命令行手动预检 |

审查报告保存在：`.review/reports/review-{时间}.md`

---

## 常见问题

**Q：提交 svn:ignore 等属性变更时报「参数错误」？**  
A：旧版 Hook 脚本用 `param()` 接收 TortoiseSVN 的 `%DEPTH%`（常为 `-2`），PowerShell 会误解析为开关参数。请更新 team-developer-agent 插件，或重新运行安装脚本；新版已改用 `$args` 接收参数，属性变更会自动跳过 AI 审查。

**Q：插件更新后 Hook 还能用吗？**  
A：junction 模式下通常自动指向新脚本。若异常，重新执行第 3a 步安装脚本即可。

**Q：没有装 TortoiseSVN 怎么办？**  
A：用 `/team:svn-review` 或 `review-manual.ps1` 手动审查，审查通过后再用你习惯的 SVN 客户端提交。

**Q：审查太慢或超时？**  
A：在 `review-config.local.json` 中增大 `"agentTimeoutSeconds": 300`。

**Q：CLI 未登录会怎样？**  
A：Hook 会阻止提交并提示先执行 `agent login`。

**Q：审查报告中文乱码？**  
A：旧版用 Ask 模式无法写文件，stdout 经 Job 捕获后编码错误。请更新脚本后重新审查；新报告以 **UTF-8 BOM** 写入。可删除 `.review/reports/` 下乱码文件后重跑。

**Q：手动运行报 `ConvertFrom-Json` / 传入的对象无效？**  
A：`plugin.json` 含中文，旧版脚本未用 UTF-8 读取导致乱码。请重新运行 `install-tortoisesvn-hook.ps1 -Force` 部署最新脚本，或更新 team-developer-agent 插件。

**Q：报错 `anaconda3\condabin` 拒绝访问，或 `%PATH%` 未替换？**  
A：Hook 命令行手写了 `%PATH%` 等占位符，或经过 `.cmd` 被当成系统 PATH 环境变量。请改为直接调用 `review-pre-commit.ps1`，并且不要在命令行末尾追加任何参数。

**Q：修改代码后 TortoiseSVN 提交未触发审查？**  
A：常见原因：① 未用 TortoiseSVN 提交（IDE/命令行不会触发 Hook）；② Hook 的 **Working Copy Path** 与 SVN 根不一致（本仓库根为 `E:\project`，建议填 `E:\project` 或 `...\zmDevelop` 并确认已勾选 Wait）；③ 仅提交属性变更（svn:ignore）会自动跳过。
