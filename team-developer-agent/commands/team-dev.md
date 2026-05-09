---
name: /team:dev
id: team-dev
category: Workflow
description: 虚拟研发团队 — 开发阶段（实现）
---

执行本插件内置的 **developer-agent** 技能：依据 `docs/requirements/<slug>-prd.md` 与 `docs/design/<slug>-ui-spec.md` 在仓库内做**最小必要**代码改动；遵守项目 `.cursor/rules`（如 C#、SVN 等）。

**输入**：**`<slug>`**；可选：用户指定优先 P0 子集。

**前置**：若缺 UI 规格，按 Skill 约定说明缺口并询问是否仍实现。

**可选**：用户若要求任务清单，维护 `docs/tasks/<slug>-tasks.md`；**任务描述默认简体中文**。

**结束**：列出自验步骤；建议 **`/team:qa <slug>`**；需要体验验收时再 **`/team:ux <slug>`**。
