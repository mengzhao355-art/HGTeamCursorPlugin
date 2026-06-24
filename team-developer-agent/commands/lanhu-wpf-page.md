# 蓝湖 WPF 页面（MVVM 全流程）

在聊天中输入 **`/lanhu-wpf-page`** 并附上蓝湖设计稿链接（可选：画板名称或英文 `PageSegment`）。

## 执行顺序（以 Skill 为准）

严格遵循 **`.cursor/skills/lanhu-wpf-mvvm-workflow/SKILL.md`** 全文，按章节 **0 → 1 → 2 → 3 → 4 → 5** 执行，不得跳过登记与差异清单。

### 要点索引（详见 Skill）

| 步骤 | 动作 |
|------|------|
| 0 | 仅 `Exoscope.DeskTop.App`；邀请链先 `lanhu_resolve_invite_link` |
| 1 | `lanhu_design`：`analyze`，`detailDetach` 用 `design_names: all`，`include` 含 `html,tokens,layout,layers,slices,image`；更新 `docs/design/lanhu-mapping.md` |
| 2 | `Views/Lanhu/<PageSegment>/` + `*LanhuPrototypeView` / `*LanhuPrototypeViewModel`；透明 Button 模板、Grid 底栏；图标 csproj `Resource`；`Lanhu*` 仅原型 |
| 3 | 叠图 + 差异表 + `dotnet build` |
| 4 | 交付文件清单、导航名、验证方式 |
| 5 | 说明原型升格计划或「仅原型」 |

## 输出（必须）

- 新建/修改文件路径（含 csproj）
- `PageSegment`、Prism 导航名、蓝湖画板中文名
- **差异清单表**（稿值 / 实现值 / 原因）
- `lanhu-mapping.md` 是否已更新
