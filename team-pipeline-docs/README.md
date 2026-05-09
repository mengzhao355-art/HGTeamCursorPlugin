# 虚拟研发流水线 — 文档契约（第二层）

本目录约定 **产品 → UI → 开发 → 测试 → 交互验收** 之间的传递格式。同一功能使用同一 **`<feature-slug>`**（小写英文、kebab-case，例如 `login-with-phone-otp`）。

**文档语言**：各 Agent 写入本目录下正式契约文件（非 `_TEMPLATE-*`）时，**默认简体中文**（标题、段落、表格说明）；文件名中的 slug、需求编号（如 `FR-01`）、视图 ID（如 `V-01`）、路径与必要技术缩写可保留英文。

## 个人目录同步（跨项目复用）

本仓库的模板可同步到用户目录 **`%USERPROFILE%\.cursor\team-pipeline-docs\`**（与全局 `/team:*`、个人 `~/.cursor/skills` 配套）。新仓库将其中内容合并复制到项目根目录的 `docs/` 即可。更新副本步骤见该目录下的 **`SYNC.md`**。

## 路径与角色

| 阶段 | 对应 Skill | 契约文件（复制模板后重命名） |
|------|------------|------------------------------|
| 产品需求 | `pm-agent` | `requirements/<slug>-prd.md` |
| UI 设计 | `ui-designer-agent` | `design/<slug>-ui-spec.md` + `design/prototypes/<slug>-main.html`（HTML 线框原型） |
| 开发（可选任务清单） | `developer-agent` | `tasks/<slug>-tasks.md` |
| 测试 | `qa-agent` | `test/<slug>-test-cases.md` |
| 交互验收 | `ux-reviewer-agent` | `review/<slug>-ux-review.md` |

## 使用方式

1. 在对应子目录复制 `_TEMPLATE-*.md`，改名为上表中的目标文件名（把 `<slug>` 换成实际 slug）。
2. 与 Cursor 对话时指明 slug 或 `@` 相关文件，各 Agent Skill 按路径读取/写入。

## 模板文件

- `requirements/_TEMPLATE-prd.md`（精简：**目标**、**用户故事**、**功能需求** 三节）
- `design/_TEMPLATE-ui-spec.md`（并约定 `design/prototypes/<slug>-main.html` 等）
- `tasks/_TEMPLATE-tasks.md`
- `test/_TEMPLATE-test-cases.md`
- `review/_TEMPLATE-ux-review.md`

以 `_` 开头的模板仅作脚手架，**不**作为某次需求的正式交付物命名。

## 第三层：命令触发（编排）

流水线 **不** 通过全局 Rule 自动套用；在 Cursor 聊天中输入以下 **斜杠命令**（与现有 `/opsx:*` 相同机制，定义在 `.cursor/commands/`）时，再按对应 Skill 执行该阶段：

| 命令 | 作用 |
|------|------|
| `/team:flow` | 说明阶段顺序、slug 约定与本表；不代写 PRD |
| `/team:pm` | 产品经理 / PRD → `requirements/<slug>-prd.md` |
| `/team:ui` | UI 规格 → `design/<slug>-ui-spec.md` |
| `/team:dev` | 开发实现（读 PRD + UI 规格） |
| `/team:bugfix` | 缺陷修复（`BUGFIX/` + TAPD；多 ID 连续修；末尾**本轮总清单** + **交付说明**（仅版本与修改摘要），见 `tapd-bugfix-agent`） |
| `/team:qa` | 测试用例与执行 → `test/<slug>-test-cases.md` |
| `/team:ux` | 交互验收报告 → `review/<slug>-ux-review.md` |

建议在命令中带上 **slug**，例如：`/team:pm my-feature-slug`。未带时由 Agent 询问后再继续。
