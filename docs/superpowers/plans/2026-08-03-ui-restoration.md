# LED 滚动字幕 UI 还原 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将用户提供的五页 UI 与应用图标还原为可交互的原生 HarmonyOS 应用。

**Architecture:** 通过集中主题常量和可复用 LED 面板统一视觉，页面保留现有服务与路由，只替换展示结构并补齐交互状态。源码合同脚本先固定必须存在的页面文案、主题令牌与组件引用，再进入实现。

**Tech Stack:** ArkTS、ArkUI Stage 模型、PowerShell 验证脚本、Hvigor

---

### Task 1: UI 合同与主题基础

**Files:**
- Create: `scripts/test-ui-contract.ps1`
- Create: `entry/src/main/ets/common/Theme.ets`
- Create: `entry/src/main/ets/components/LedPanel.ets`

- [ ] 编写失败的 UI 合同检查，要求主题、LED 面板、五页关键文案和首页组件引用存在。
- [ ] 运行 `powershell -ExecutionPolicy Bypass -File scripts/test-ui-contract.ps1`，确认因主题与组件缺失而失败。
- [ ] 实现 `Theme` 的背景、面板、主色、文字、圆角常量，以及接受文本、颜色、高度和字号参数的 `LedPanel`。
- [ ] 再次运行合同检查，确认基础合同通过。

### Task 2: 首页与颜色页

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`

- [ ] 重构首页为标题、LED 预览、文本输入、8 模式、11 色样、两滑杆、三开关、主按钮和四项底栏。
- [ ] 保持 `buildConfig()`、保存历史和 `DisplayPage` 路由不变，并使视觉状态随配置同步。
- [ ] 重构颜色页为预览、十六进制值、HSV、RGB、最近使用和确认按钮；保持 HSV/RGB 双向更新。
- [ ] 运行 UI 合同检查和 ArkTS 构建，修正所有类型错误。

### Task 3: 模板、历史与计数器

**Files:**
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`
- Modify: `entry/src/main/ets/services/TemplateService.ets`

- [ ] 将模板页改为分类胶囊与响应式双列 LED 卡片，并补齐设计稿中首屏 8 条模板数据和使用次数展示。
- [ ] 将历史页改为点阵预览记录卡和圆形删除操作，保留清空确认与恢复播放。
- [ ] 将计数器改为发光点阵数字面板以及红/绿圆形按钮，保留全屏常亮管理。
- [ ] 运行 UI 合同检查和 ArkTS 构建，确认路由与类型通过。

### Task 4: 图标、文档与最终验收

**Files:**
- Modify: `entry/src/main/resources/base/media/startIcon.png`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`

- [ ] 从用户提供的方形图标设计源图生成应用图标资源，保持正方形 PNG 与可识别的 LED 主体。
- [ ] 更新设计、变更、QA 和任务状态，记录实际验证证据与未测项。
- [ ] 运行 `scripts/test-ui-contract.ps1`、`scripts/check-standard.ps1`、`scripts/build-harmony.ps1`。
- [ ] 检查模拟器连接；若在线则安装、启动并逐页验证，若离线则如实记录。
- [ ] 在全部可执行验证结束后安排 Windows 自动关机。
