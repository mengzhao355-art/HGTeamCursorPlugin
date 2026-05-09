# Cursor Team Marketplace：虚拟研发团队（方案 B）

本仓库为 **单仓库多插件**：根目录 `.cursor-plugin/marketplace.json` 声明 5 个独立插件，供 **Cursor Team / Enterprise** 在 Dashboard → Settings → Plugins → Team Marketplaces → **Import**（粘贴本仓库 Git URL）后解析安装。

## 插件一览

| 目录 | 插件 `name` | 内含 |
|------|-------------|------|
| `team-pm-agent/` | `team-pm-agent` | Skill `pm-agent` + 命令 `/team:pm` |
| `team-ui-designer-agent/` | `team-ui-designer-agent` | Skill `ui-designer-agent` + `/team:ui` |
| `team-developer-agent/` | `team-developer-agent` | Skill `developer-agent` + `/team:dev` |
| `team-qa-agent/` | `team-qa-agent` | Skill `qa-agent` + `/team:qa` |
| `team-ux-reviewer-agent/` | `team-ux-reviewer-agent` | Skill `ux-reviewer-agent` + `/team:ux` |

## 项目侧约定

- 各 Skill 默认写入路径仍为 **`docs/requirements|design|tasks|test|review`**；新项目请先自备 `docs/` 模板（或使用你们的 `team-pipeline-docs` 副本）。
- **`/team:flow`**、**`/team:bugfix`** 未纳入本包（可按同样结构再加插件）。

## 本地验证（可选）

将某一插件目录拷到 `%USERPROFILE%\.cursor\plugins\local\<插件名>\`，或按 [Plugins 文档](https://cursor.com/docs/plugins.md) 使用 symlink，重启 Cursor / Reload Window 后检查 Skills 与 Commands 是否加载。

## 上架前请修改

- `marketplace.json` 内 **`owner.email`** 改为团队真实邮箱。
- 各 `plugin.json` 内 **`author`** 如需与法务一致可统一修改。

## 参考

- [Plugins reference — Multi-plugin repositories](https://cursor.com/docs/reference/plugins.md)
