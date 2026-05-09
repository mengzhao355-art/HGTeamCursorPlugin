---
name: /team:pm
id: team-pm
category: Workflow
description: 虚拟研发团队 — 产品经理阶段（PRD）
---

执行本插件内置的 **pm-agent** 技能：澄清需求并产出/更新 `docs/requirements/<slug>-prd.md`。**PRD 正文与章节标题默认简体中文**（若项目有 `docs/README.md` 可与之对齐）。

**输入**：用户在命令后附上 **`<slug>`**（kebab-case），或在一句话里说明功能 + slug。若缺少 slug，先问再写文件。

**模板**：若仓库存在，可复制 `docs/requirements/_TEMPLATE-prd.md` 为 `<slug>-prd.md`。

**结束**：说明建议下一步：运行 **`/team:ui <slug>`**（需已安装 UI 设计插件）生成 UI 规格。
