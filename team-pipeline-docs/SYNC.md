# team-pipeline-docs 使用说明

本目录为 **虚拟研发流水线** 的 `docs` 契约模板副本，与仓库 `docs/` 中模板保持同步（从项目拷贝更新即可）。

## 在新项目中启用

将本目录下内容 **合并复制** 到项目根目录的 `docs/`（保留子目录结构）：

- `README.md` → `docs/README.md`
- `requirements/_TEMPLATE-prd.md` → `docs/requirements/`
- `design/_TEMPLATE-ui-spec.md` → `docs/design/`
- `design/assets/.gitkeep` → `docs/design/assets/`（可选；若需存截图等）
- `design/prototypes/.gitkeep` → `docs/design/prototypes/`（HTML 线框原型输出目录，Agent 会生成 `<slug>-main.html` 等）
- `tasks/`、`test/`、`review/` 下各 `_TEMPLATE-*.md`

复制后在新仓库执行 `/team:flow` 或按 `docs/README.md` 使用 `/team:*` 命令。

## 从仓库更新本副本（Windows PowerShell）

将 `<REPO_ROOT>` 替换为你的模板源仓库根路径后执行：

```powershell
$repoDocs = '<REPO_ROOT>\docs'
$here = Join-Path $env:USERPROFILE '.cursor\team-pipeline-docs'
Copy-Item (Join-Path $repoDocs 'README.md') (Join-Path $here 'README.md') -Force
Copy-Item (Join-Path $repoDocs 'requirements\_TEMPLATE-prd.md') (Join-Path $here 'requirements\_TEMPLATE-prd.md') -Force
Copy-Item (Join-Path $repoDocs 'design\_TEMPLATE-ui-spec.md') (Join-Path $here 'design\_TEMPLATE-ui-spec.md') -Force
Copy-Item (Join-Path $repoDocs 'tasks\_TEMPLATE-tasks.md') (Join-Path $here 'tasks\_TEMPLATE-tasks.md') -Force
Copy-Item (Join-Path $repoDocs 'test\_TEMPLATE-test-cases.md') (Join-Path $here 'test\_TEMPLATE-test-cases.md') -Force
Copy-Item (Join-Path $repoDocs 'review\_TEMPLATE-ux-review.md') (Join-Path $here 'review\_TEMPLATE-ux-review.md') -Force
New-Item -ItemType Directory -Force -Path (Join-Path $here 'design\prototypes') | Out-Null
if (Test-Path (Join-Path $repoDocs 'design\prototypes\.gitkeep')) {
  Copy-Item (Join-Path $repoDocs 'design\prototypes\.gitkeep') (Join-Path $here 'design\prototypes\.gitkeep') -Force
}
```

最后更新：2026-04-22
