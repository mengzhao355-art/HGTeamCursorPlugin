---
name: /team:qa
id: team-qa
category: Workflow
description: 虚拟研发团队 — 测试阶段（用例与执行）
---

执行本插件内置的 **qa-agent** 技能：基于 PRD（及已有 UI 规格）编写/更新 `docs/test/<slug>-test-cases.md`；在环境允许时运行相关测试并记录结果。**测试文档默认简体中文**。

**输入**：**`<slug>`**。

**模板**：若仓库存在，`docs/test/_TEMPLATE-test-cases.md`。

**结束**：若有失败项，指出对应 FR/场景并建议 **`/team:dev <slug>`** 修复；若需体验验收，建议 **`/team:ux <slug>`**。
