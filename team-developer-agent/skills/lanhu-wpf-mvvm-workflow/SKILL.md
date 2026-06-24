---
name: lanhu-wpf-mvvm-workflow
description: >-
  Pulls UI from Lanhu via MCP, implements WPF prototype pages in MVVM under
  Views/Lanhu/<AsciiPageSegment>/ as *LanhuPrototypeView, registers Prism
  navigation, verifies fidelity with overlay checklist, maps tokens to global
  theme, and documents promotion to formal Views. Use for 蓝湖, Lanhu, WPF 还原,
  设计稿转界面, lanhu-wpf, or /lanhu-wpf-page with a Lanhu URL.
---

# 蓝湖 → WPF（MVVM）页面工作流

面向 **Exoscope.DeskTop.App**（Prism + `BindableBase` + `DelegateCommand`）。**不**在过渡期遗留项目 `src/Exoscope.Desktop` 落新页。执行本工作流时必须先读全篇，再按顺序落地。

## 0. 输入与适用范围

- **蓝湖设计链接**：`detailDetach` / `stage` / 含 `image_id` 或 `project_id` 的 URL。
- **邀请/分享链**：先用 MCP **`lanhu_resolve_invite_link`** 解析为带 `tid`/`pid` 等的正式 URL，再拉设计稿。
- **PRD/原型文档**（URL 含 `docId`）：可选 MCP **`lanhu_page`**（`list` / `analyze`）补充需求文案；**不替代**画板像素级 `lanhu_design`。

若用户未给链接，先请其粘贴；若已给链接，直接进入步骤 1。

## 1. 从蓝湖拉取设计信息（MCP）

1. 在 Cursor MCP 描述目录读取 **`lanhu_design.json`**（路径形如 `mcps/user-lanhu/tools/lanhu_design.json`）后再调用 **`user-lanhu` / `lanhu_design`**。
2. 推荐参数：
   - `url`：完整蓝湖 URL
   - `mode`：`analyze`
   - `design_names`：单画板用名称；**`detailDetach` 多切片必须用 `all`**
   - `include`（默认全开）：`html`、`tokens`、`layout`、`layers`、`slices`、`image`
     - `image`：base64 设计图，用于叠图验收
     - `slices`：切图/资源清单，指导 `Assets/icons` 与 csproj
3. 从返回记录：**画板标题（中文仅说明）**、画布尺寸、色值/字号、层级、文案、相对位置。
4. **登记映射**：在 `docs/design/lanhu-mapping.md` 追加一行（见该文件表头）；PR 说明中须含同一映射。

### 1.1 PageSegment 与类型命名 — 必填

**路径、文件夹、C# 命名空间禁止中文与非 ASCII。**

| 概念 | 规则 | 示例 |
|------|------|------|
| `PageSegment` | 从蓝湖标题推导 PascalCase ASCII 段名 | `02主界面-常规-手术中` → `MainRoutineDuringSurgery` |
| 蓝湖还原 View | `{Feature}LanhuPrototypeView` | `SurgeryMainLanhuPrototypeView` |
| 蓝湖还原 ViewModel | `{Feature}LanhuPrototypeViewModel` | `SurgeryMainLanhuPrototypeViewModel` |
| 正式业务页 | `{Feature}View`，放在 `Views/<业务域>/` | **不得**长期留在 `Views/Lanhu` |

- 仅 `[A-Za-z][A-Za-z0-9]*` 拼接 PascalCase；用户已指定 slug 以其为准。
- 重命名/迁移目录后执行 **`dotnet clean`** 并全量 build，避免 `obj` 残留中文路径。

## 2. 实现页面（MVVM）

设 `PageSegment` 为步骤 1 的 ASCII 段名。

### 2.1 落盘路径与命名空间（必须一致）

| 类型 | 磁盘路径 | 命名空间 |
|------|-----------|----------|
| View | `Views/Lanhu/<PageSegment>/{Feature}LanhuPrototypeView.xaml`（及 `.xaml.cs`） | `Exoscope.DeskTop.App.Views.Lanhu.<PageSegment>` |
| ViewModel | `ViewModels/Lanhu/<PageSegment>/{Feature}LanhuPrototypeViewModel.cs` | `Exoscope.DeskTop.App.ViewModels.Lanhu.<PageSegment>` |

- **`x:Class`** 与 View 命名空间一致。
- **设计时 DataContext**：`xmlns:vm="clr-namespace:Exoscope.DeskTop.App.ViewModels.Lanhu.<PageSegment>"` + `d:DesignInstance`。
- **`prism:ViewModelLocator.AutoWireViewModel="True"`**；`Views` → `ViewModels` 其余段一致即可解析 VM。

### 2.2 MVVM 约定

- ViewModel：`BindableBase`；命令：`DelegateCommand(OnXxx)` + **`private void OnXxx()`**。
- **禁止** `new DelegateCommand(() => { })` 或内联 lambda 业务；占位方法须注释 `// 占位：接入 xxx`。
- **禁止** 在 Lanhu Prototype VM 中直接引用 Domain/Infrastructure 重业务；仅 UI 状态与导航占位。
- **`App.xaml.cs`**：`RegisterForNavigation<{Feature}LanhuPrototypeView>(nameof(...))` + `using Exoscope.DeskTop.App.Views.Lanhu.<PageSegment>;`

### 2.3 布局与控件

- 根节点固定稿尺寸（如 `Width="1920"` `Height="1080"`）。
- 顶栏/工具区：**三列 `Grid`（左 Auto / 中 * / 右 Auto）**，少用魔法 `Margin` 对齐。
- 底栏贴右：同上 Grid 分区；**`ClipToBounds` 勿裁切**底栏文案。
- 工具栏 **`Button`**：使用**透明 `ControlTemplate`**，避免 WPF 系统主题浅色底板。
- 分区列宽优先从 MCP `layout`/`layers` 取值（如固定列宽 + 间距列），避免目测取整。

### 2.4 图标与 csproj

- 图标目录：**`Assets/icons`**，引用 `pack://application:,,,/Exoscope.DeskTop.App;component/Assets/icons/...`。
- **不得**用仅 `CopyToOutputDirectory` 的 `<None>` SVG 配合 `pack://application`。
- 新 SVG：在 **`Exoscope.DeskTop.App.csproj`** 增加 `<None Remove="..."/>` + `<Resource Include="..."/>`（同 `录屏.svg`、`shot.svg`）。
- 新图标文件名优先 **ASCII**，降低 pack 路径风险；已有中文名资源可沿用。

### 2.5 主题与资源（Lanhu* vs 全局）

- **`App.xaml` 已全局合并** `SkinLocal` → `ColorsDarkLocal`、HandyControl、`GeneralCustomControl`；页面**原则上不必重复**合并 `SkinLocal`，除非 Blend 设计时需要。
- 稿面专用色/Style 使用 **`Lanhu*` 前缀**，仅用于 `*LanhuPrototype*` 页。
- 与全局 token 一致时优先用 **`ColorsDarkLocal`**（如稿面主色 `#3EB0B0` → `PrimaryColor`），避免长期两套色并存。
- 滑块等与 **`ControlPanelView`** 对齐时复用 `GeneralCustomControl`（如 `TouchFriendlySlider`）。

| 稿面语义 | 优先全局键 | 仅原型可保留 |
|----------|------------|--------------|
| 主强调色 | `PrimaryColor` | `LanhuAccent` |
| 区域背景 | `RegionColor` / `SecondaryRegionColor` | `LanhuPanelBg`、`LanhuSidebarBg` |
| 主文字 | `PrimaryTextColor` | `LanhuTextPrimary` |

### 2.6 开发预览入口（非正式功能）

- 本地预览：`_regionManager.RequestNavigate("MainRegion", nameof({Feature}LanhuPrototypeView))`（当前样例从 `LoginViewModel` 进入）。
- **正式发布前**：移除预览命令，或 `#if DEBUG` 包裹；禁止将 Lanhu 原型当作产品主界面长期上线。

## 3. 还原度自检与自动修正

对照 MCP 的 **layout / tokens / html / image**：

1. **尺寸与分区**：分辨率、顶栏高度、左中右列宽。
2. **颜色与字号**：与 tokens/CSS 或上表全局键对齐。
3. **图标与底**：无系统主题浅色底；SVG `Resource` 正确。
4. **文案**：长标签不被裁切。
5. **叠图**（推荐）：用 MCP `image` 或导出 PNG，Opacity 0.3–0.5 叠运行界面，查顶栏/底栏/列宽。
6. **编译**：`dotnet build Exoscope.DeskTop.App/Exoscope.DeskTop.App.csproj`。

**差异清单**（交付必填，可贴 PR）：

| 项 | 稿值 | 实现值 | 原因（刻意简化 / 待修 / 复用控件） |
|----|------|--------|-----------------------------------|

不符合则改 XAML / csproj / VM，重复本节前 6 项直至可接受或用户叫停。

## 4. 交付

- **文件清单**（含 csproj 中新增 `Resource`）。
- **`PageSegment`**、导航注册名、蓝湖画板中文名。
- **差异清单**（上表）。
- **本地验证**：`MainRegion` + `nameof({Feature}LanhuPrototypeView)` 或团队约定的 Region。
- 更新 **`docs/design/lanhu-mapping.md`**。

## 5. 原型升格与下线（项目级）

| 阶段 | 位置 | 说明 |
|------|------|------|
| A 原型 | `Views/Lanhu/*LanhuPrototype*` | 视觉还原 + 占位命令 |
| B 抽共用 | `Resources/` 或 `GeneralCustomControl` | 评审通过的 Style/控件升格 |
| C 正式 | `Views/<业务域>/*View` + Api/VM | 接业务；下线或 DEBUG 限定预览入口 |

合并主分支前：须有升格计划（issue/任务）或 PR 标明 **「仅原型，不替代正式 MainView」**。

## 参考实现（本仓库）

- 画板：`02主界面-常规-手术中` → `PageSegment`=`MainRoutineDuringSurgery`
- View：`Views/Lanhu/MainRoutineDuringSurgery/SurgeryMainLanhuPrototypeView.xaml`
- ViewModel：`ViewModels/Lanhu/MainRoutineDuringSurgery/SurgeryMainLanhuPrototypeViewModel.cs`
- 映射表：`docs/design/lanhu-mapping.md`
