---
name: svn-code-review
description: >-
  Performs SVN pre-commit AI code review on a diff file or working copy changes.
  Outputs a structured Markdown report with severity markers. Use when the user
  mentions SVN 提交前审查, code review before commit, svn diff review, or
  /team:svn-review.
---

# SVN Code Review

## Goal

对 **本次待提交的 SVN 变更** 做只读 AI 审查，输出结构化 Markdown 报告，供开发者确认后再提交。

## Inputs

- **Diff 文件路径**（Hook / 脚本传入），或
- **待审查文件列表** + 工作区根目录（由脚本 `svn diff` 生成 diff）

可选：**提交说明**（commit message 文本）

## Outputs

- 报告写入：`<workspace>/.review/reports/review-{yyyyMMdd-HHmmss}.md`
- **不修改**任何源代码；仅写报告文件

## Review Dimensions

按优先级检查（结合项目 `.cursor/rules`）：

1. **正确性**：逻辑错误、空引用、边界条件、资源泄漏
2. **C# 规范**：nullable、禁止空 `catch`、async 方法 `Async` 后缀、禁止 `.Result`/`.Wait()`
3. **架构**：依赖方向 `Client -> Api -> Domain -> Infrastructure`；禁止 `Domain -> Api`
4. **落点**：新功能应在 `Exoscope.DeskTop.App`，非遗留 `src/Exoscope.Desktop`
5. **WPF/MVVM**：ViewModel 职责、绑定、线程/UI 调度
6. **设备初始化**：不阻塞登录 UI；串口/设备失败需日志与降级路径
7. **安全与健壮性**：外部输入校验、敏感信息、异常上下文日志

## Severity Markers（脚本解析用，必须严格使用）

每条问题必须以以下前缀之一开头（便于 Hook 门禁解析）：

| 标记 | 含义 |
|------|------|
| `🔴 必须修复` | Bug、安全、架构违规、必现崩溃 — 硬门禁依据 |
| `🟡 建议修复` | 质量、命名、可维护性 |
| `🟢 优化建议` | 可选改进 |

## Report Template

```markdown
# SVN 代码审查报告

- **时间**：{ISO8601}
- **工作区**：{workspace}
- **变更文件数**：{count}
- **提交说明**：{message 或「无」}

## 概要

{1-3 句话总结变更性质与整体风险}

## 变更文件

| 文件 | 变更类型 |
|------|----------|
| ... | 修改/新增/删除 |

## 问题列表

### 🔴 必须修复

- 🔴 必须修复 | `{file}:{line}` | {描述} | 建议：{修复方向}

（无则写「无」）

### 🟡 建议修复

- 🟡 建议修复 | `{file}` | {描述}

（无则写「无」）

### 🟢 优化建议

- 🟢 优化建议 | `{file}` | {描述}

（无则写「无」）

## 统计

| 级别 | 数量 |
|------|------|
| 🔴 必须修复 | {n} |
| 🟡 建议修复 | {n} |
| 🟢 优化建议 | {n} |

## 结论

{以下三选一}

- **通过**：无必须修复项，可提交
- **有条件通过**：存在建议项，修复后提交更佳
- **不建议提交**：存在必须修复项，请先修复
```

## Workflow

1. 读取 diff 内容与（若有）提交说明
2. 若 diff 为空或仅 whitespace/属性变更 → 报告写「无文本变更，跳过深度审查」，结论 **通过**
3. 对照 `.cursor/rules` 与上述维度逐文件审查
4. 每条问题必须包含：**文件路径**、**问题描述**、**修复建议**
5. 将完整报告写入指定 `$reportPath`
6. 回复中给出摘要：各级别数量 + 结论

## Guardrails

- **只读**：禁止修改源代码、禁止执行 svn commit
- **范围**：仅审查 diff 中可见变更，不顺带大范围重构建议
- **误报控制**：不确定的问题降级为 🟡，避免过度 🔴
- **大 diff**：若变更过大，优先审查高风险文件（Service、Api、ViewModel、初始化路径）

## Integration

- **TortoiseSVN Hook**：`scripts/svn-ai-review/review-pre-commit.ps1` 自动调用本 Skill
- **IDE 手动**：`/team:svn-review` 或运行 `Invoke-SvnAiReview.ps1`
- **开发 Handoff**：`developer-agent` 实现完成后建议执行本审查再提交
