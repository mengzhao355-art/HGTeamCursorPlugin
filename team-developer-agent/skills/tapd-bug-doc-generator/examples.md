# Examples

## Example: 外视镜项目（当前用户）

### Input intent

- “在 TAPD 外视镜项目里，筛选处理人=当前登录用户，状态=新/接受处理/重新打开；把筛选后的每条 Bug 详情抓出来，输出成结构化 Markdown 文档。”

### 自动启动 Chrome（先执行）

```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%USERPROFILE%\.chrome-debug-profile"
```

### 工具与输出

- **工具**：Chrome DevTools MCP（打开 Chrome、导航、点击、`take_snapshot` 解析）。
- **输出**：仅一份文档，路径为工作区根目录下 **BUGFIX** 文件夹；若 BUGFIX 不存在则先创建。
- **文件名**：`外视镜项目-当前用户-Bug详情-YYYY-MM-DD.md`（示例：`外视镜项目-当前用户-Bug详情-2026-03-18.md`）。

### Example: 单条 Bug 详情块（摘录）

```markdown
### Bug #1：3D外视镜图像分配错误

| 项目 | 内容 |
|------|------|
| **TAPD ID** | 1002194 |
| **状态** | 新 |
| **发现版本** | 版本1 |
| **优先级** | 高 |
| **严重程度** | 严重 |
| **处理人** | 赵猛_20240423072302 |
| **创建人** | 郑军 |
| **创建时间** | 2026-03-14 16:31:07 |

**前置条件：**
/

**测试步骤：**
1. ...
2. ...
```

### Notes

- 若页面中“接受/处理”拆分为两个状态，统一在文档里合并写作“接受/处理”，并在“说明”里注明口径。
