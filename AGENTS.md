# LED滚动字幕 - Agent工作约束

## 项目边界

- **项目类型**：纯鸿蒙 Stage 模型应用
- **设备目标**：phone, tablet, 2in1
- **源代码**：entry/src/main/ets/ 下的 pages/、components/、services/、models/、common/
- **资源**：entry/src/main/resources/
- **不可修改**：签名配置、bundleName、versionCode（除非用户明确要求）

## 标准工作流

1. 开始前阅读本文件和 tasks.md
2. 注册任务到 tasks.md
3. 保持改动与用户需求对齐
4. 可见变更需更新 design.md
5. 执行静态检查 + 构建 + 设备验证
6. 完成前回填 changes.md 和 design-qa.md

## ArkTS 和 ArkUI 规则

- 声明式 UI，明确类型
- 页面负责组合和交互，组件负责展示
- 共享颜色/间距/常量集中在 common/
- 状态更新必须触发 UI 刷新
- 路由和资源名必须与资源目录匹配

## 多设备和设计

- 使用断点/相对尺寸/安全区域
- 交互控件需清晰且提供状态反馈

## 验证命令

```powershell
# 标准检查
.\scripts\check-standard.ps1

# 构建
.\scripts\build-harmony.ps1
```

## 安全

- 不将签名密码、私钥、token、用户隐私复制到代码/文档/日志/截图
- 不修改包名、应用ID、版本、签名标识、AGC元数据（除非用户明确要求）
- 不提交构建缓存、IDE本地配置、临时文件
