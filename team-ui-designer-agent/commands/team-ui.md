---
name: /team:ui
id: team-ui
category: Workflow
description: 虚拟研发团队 — UI 设计阶段（UI 规格）
---

执行本插件内置的 **ui-designer-agent** 技能：读取 `docs/requirements/<slug>-prd.md`，产出/更新 `docs/design/<slug>-ui-spec.md`。**UI 规格默认简体中文**。至少产出 1 个 **HTML 线框原型**：`docs/design/prototypes/<slug>-main.html`（详见 Skill）。

**输入**：命令参数 **`<slug>`**；若未提供则从对话推断，无法唯一确定则询问。

**前置**：若缺少对应 PRD，说明缺失并建议先 **`/team:pm <slug>`**。

**模板**：若仓库存在，使用 `docs/design/_TEMPLATE-ui-spec.md`。

**结束**：建议下一步 **`/team:dev <slug>`**（需已安装开发插件）。
