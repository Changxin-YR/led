# 任务追踪

状态定义：`pending` | `in_progress` | `done` | `blocked`

---

## T-20260803-001

- **状态**：`done`
- **目标**：项目搭建和基础框架
- **范围**：配置文件、数据模型、服务层、通用模块、EntryAbility

### 检查清单
- [x] 创建项目目录结构
- [x] app.json5 / module.json5 / build-profile.json5 / oh-package.json5
- [x] main_pages.json 路由配置
- [x] 数据模型（BannerConfig, ColorScheme, Template, HistoryRecord）
- [x] 服务层（StorageService, ScreenService, AnimationService, TemplateService）
- [x] 通用模块（Constants, Utils）
- [x] EntryAbility / EntryBackupAbility

---

## T-20260803-002

- **状态**：`done`
- **目标**：核心页面实现
- **范围**：6个主要页面全部实现

### 检查清单
- [x] Index.ets 首页（输入+配置+预览+底部导航）
- [x] DisplayPage.ets 全屏LED显示（8种模式动画）
- [x] TemplatePage.ets 模板选择页
- [x] HistoryPage.ets 历史记录页
- [x] ColorPickerPage.ets 颜色选择页（HSV+RGB）
- [x] CounterPage.ets 计数器页

---

## T-20260803-003

- **状态**：`done`
- **目标**：显示效果组件
- **范围**：独立动画组件

### 检查清单
- [x] ScrollingText.ets
- [x] BlinkingText.ets
- [x] BreathingText.ets
- [x] BarrageText.ets
- [x] NeonText.ets
- [x] BorderEffect.ets

---

## T-20260803-004

- **状态**：`done`
- **目标**：构建验证和设备测试
- **范围**：通过标准检查和实际构建

### 检查清单
- [x] 通过 check-standard.ps1（0 错误，1 个 README.md 缺失警告）
- [x] 通过 build-harmony.ps1 构建（debug HAP）
- [x] 在模拟器安装并启动应用
- [x] 核心功能交互验证（首页、输入预览、模式/预设颜色、全屏静态显示）

### 验证与遗留覆盖

- HAP 已生成：`entry/build/default/outputs/default/entry-default-unsigned.hap`，并成功安装、启动于 DevEco Emulator。
- 构建无错误，但仍有 target SDK 配置与 ArkTS 过时 API/可能抛异常提示；本轮未修改其行为。
- 模板、历史、计数器、HSV/RGB、自适应设备和其余动画模式尚未逐项完成模拟器复测。

---

## T-20260803-005

- **状态**：`done`
- **目标**：按用户提供的三张视觉稿全方位还原 LED 滚动字幕应用 UI
- **范围**：首页、自定义颜色、场景模板、历史记录、计数器、应用图标、公共视觉组件与多设备布局

### 检查清单

- [x] 建立深黑蓝、青色霓虹、点阵纹理的统一视觉系统
- [x] 还原首页预览、输入、模式、配色、滑杆、设置与底部导航
- [x] 还原自定义颜色页 HSV/RGB、最近使用与确认操作
- [x] 还原场景模板双列卡片、分类筛选与模板使用流程
- [x] 还原历史记录预览卡片、删除与清空流程
- [x] 还原计数器点阵面板、重置、加减按钮
- [x] 使用参考图更新应用图标
- [x] 完成静态检查、构建和可用设备验证
- [x] 回填 changes.md、design.md、design-qa.md
## T-20260804-001

- **Status**: `done`
- **Goal**: Connect the existing LED banner project to the Gitee repository and commit the current project state.
- **Scope**: Initialize local Git metadata, preserve the remote master README, add project source and documentation, and exclude generated caches and local IDE state.

### Checklist
- [x] Initialize the local repository and connect the Gitee remote
- [x] Review and stage only source, project configuration, and intentional documentation
- [x] Run the required static check and build
- [x] Commit and push to `origin/master`

---

## T-20260804-002

- **状态**：`in_progress`
- **目标**：在 LED 展示页实现可靠的横屏显示，并将常规页面调整为不侵入系统栏的沉浸式深色布局。
- **范围**：窗口方向与系统栏状态管理、主题色常量、DisplayPage 生命周期、静态回归检查、构建与设备验证。

### 检查清单

- [ ] 首页和配置页保留状态栏、导航栏与安全区，系统栏颜色与应用主题一致
- [ ] LED 展示页按“横屏显示”配置进入横屏全屏；关闭时保持竖屏全屏
- [ ] 从展示页返回后恢复竖屏、系统栏、常亮和亮度状态
- [ ] 先完成窗口状态回归测试的红绿验证
- [ ] 完成静态检查、构建和可用设备验证
- [ ] 回填 design.md、changes.md、design-qa.md 并提交
