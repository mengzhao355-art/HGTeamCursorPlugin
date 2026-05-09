---
name: /team:ux
id: team-ux
category: Workflow
description: 虚拟研发团队 — 交互验收阶段（UX 审查报告）
---

执行本插件内置的 **ux-reviewer-agent** 技能：对照 PRD 与 UI 规格审查实现（阅读相关代码或用户提供的说明），产出/更新 `docs/review/<slug>-ux-review.md`。**审查报告默认简体中文**；结论：**通过** / **通过（有问题）** / **不通过**。

**输入**：**`<slug>`**；若需固定基准，请用户说明分支/commit 或当前工作区即可。

**模板**：若仓库存在，`docs/review/_TEMPLATE-ux-review.md`。

**结束**：按报告中的严重级别给出后续建议（回开发 / 回产品或 UI 改文档）。
