---
name: /team:svn-review
id: team-svn-review
category: Workflow
description: 虚拟研发团队 — SVN 提交前 AI 代码审查
---

执行本插件内置的 **svn-code-review** 技能：

- 对当前工作区 SVN 本地变更（或用户指定文件）生成 diff
- 按团队审查规范输出 Markdown 报告到 `.review/reports/`
- **只读审查，不修改源代码**

**输入**：可选文件路径列表；无则审查 `svn status` 中所有已修改/新增/删除的文本文件。

**前置**：需已安装 Cursor CLI 且 `agent status` 可用。

**脚本路径**（手动 CLI 审查）：插件内 `scripts/svn-ai-review/Invoke-SvnAiReview.ps1`

**结束**：展示报告摘要；确认无 `🔴 必须修复` 项后再 SVN 提交。TortoiseSVN 用户可运行 `install-tortoisesvn-hook.ps1` 注册 Pre-commit Hook 自动审查。
