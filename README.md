# Cursor Team Marketplace：虚拟研发团队

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
- 新项目使用agent 务必参考`team-pipeline-docs` 文件夹中，初始化模板和目录




## 参考

- [Plugins reference — Multi-plugin repositories](https://cursor.com/docs/reference/plugins.md)
