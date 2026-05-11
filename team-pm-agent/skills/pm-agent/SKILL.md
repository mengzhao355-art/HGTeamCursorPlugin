---
name: pm-agent
description: >-
  PRD：澄清范围，产出 `docs/requirements/<slug>-prd.md`（中文正文）。
  触发词：产品经理、PM、PRD、需求文档、需求澄清、验收。
---

# pm-agent

## 目标

澄清意图后写出 **一份** PRD，下游可直接执行。

## 默认

- 路径：`docs/requirements/<slug>-prd.md`（`slug` 为 kebab-case）。
- **正文、标题、表头**：简体中文；可保留 slug、FR 编号、P0 等标识英文。
- 无模板则复制 `docs/requirements/_TEMPLATE-prd.md`；流水线见 `docs/README.md`。

## 流程

1. **意图**：一段话概括问题、用户、成功标准；若只有一句话则先澄清再写文件。
2. **澄清**：只问挡写「目标 / 用户故事 / 功能需求」的问题；可选列举选项。用户说「你决定」时在目标或备注写假设。
3. **落盘**：按下方模板写满 PRD；验收标准可测（条目或 Given/When/Then）。
4. **收尾**：一行建议下一步（如 `/team:ui <slug>` 或项目既有 UI 规格路径）。

## PRD 模板（三节；**用户故事仅 1 条**）

```markdown
# <功能标题>

| 字段 | 内容 |
|------|------|
| 状态 | 草稿 |
| 作者 | PM Agent |
| 最后更新 | YYYY-MM-DD |
| 关联信息 | （可选） |

## 1. 目标

问题、对象、成功态；可选一行非目标/边界。

## 2. 用户故事

仅一条：

- 作为…，我希望…，以便…
  - **验收标准**：…

## 3. 功能需求

| 编号 | 需求描述 | 优先级（P0/P1/P2） | 备注 |
|------|----------|-------------------|------|
| FR-01 | … | P0 | … |
```

## 约束

- 不写实现细节（类名、具体 API），除非用户约定契约。
- 不悄悄砍范围；取舍写在目标或备注。
- 仅澄清、不同意出 PRD时：不写文件。

## 流水线（同一 `<slug>`）

| Skill | 产出 |
|--------|------|
| `pm-agent` | `docs/requirements/<slug>-prd.md` |
| `ui-designer-agent` | `docs/design/<slug>-ui-spec.md` |
| `developer-agent` | 代码；可选 `docs/tasks/<slug>-tasks.md` |
| `qa-agent` | `docs/test/<slug>-test-cases.md` |
| `ux-reviewer-agent` | `docs/review/<slug>-ux-review.md` |
