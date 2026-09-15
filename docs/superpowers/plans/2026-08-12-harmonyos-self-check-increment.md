# 鸿蒙自检增量能力实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 只将用户提供且尚未覆盖的华为上架检查知识增量加入全局 `harmonyos-self-check` skill。

**Architecture:** 使用项目内 PowerShell 契约对任意 skill 根目录执行同一组结构和语义检查。先让契约在旧安装版上按预期失败，再复制到项目忽略目录形成可写工作副本，增量修改一个新 reference、`SKILL.md` 和 `openai.yaml`；全部验证通过后才覆盖全局安装目录。项目记录只描述 skill 变更与验证，不改应用运行时文件。

**Tech Stack:** Markdown skill/reference、YAML metadata、PowerShell contract、Python `quick_validate.py`、HarmonyOS 项目检查和构建脚本。

---

### Task 1: 增量契约 RED

**Files:**
- Create: `scripts/test-harmonyos-self-check-skill.ps1`
- Test: `C:\Users\27363\.agents\skills\harmonyos-self-check`

- [x] **Step 1: 创建参数化契约脚本**

脚本必须检查：新 reference 存在并由 `SKILL.md` 精确路由；description 覆盖分类、标签、备案、资质、深色模式、系统栏/安全区域；正文包含五类底部导航遮挡场景、实际 inset 复核、布局五类判退信号、深色完整表面、状态栏、分类匹配、APP 备案和资质入口；新 reference 不重复 `3:1`、`4.5:1` 或 13 章审核表。

- [x] **Step 2: 对旧安装版运行并验证按预期失败**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-harmonyos-self-check-skill.ps1 -SkillRoot C:\Users\27363\.agents\skills\harmonyos-self-check
```

Expected: 非零退出，失败原因至少包含缺少 `references/release-preflight-cases.md` 或缺少该 reference 路由。

### Task 2: 工作副本 GREEN

**Files:**
- Modify: `.superpowers/harmonyos-self-check-next/SKILL.md`
- Modify: `.superpowers/harmonyos-self-check-next/agents/openai.yaml`
- Create: `.superpowers/harmonyos-self-check-next/references/release-preflight-cases.md`

- [x] **Step 1: 复制旧安装版为工作副本**

Run:

```powershell
Copy-Item C:\Users\27363\.agents\skills\harmonyos-self-check .superpowers\harmonyos-self-check-next -Recurse
```

Expected: 工作副本包含旧版的五个文件，原安装目录未改变。

- [x] **Step 2: 写入最小增量 reference**

只写案例、证据和发布前决策流程；为每个来源记录标题、最终 URL、页面日期/捕获日期和权威边界。`28vp` 必须标记为 FAQ 操作指引，并要求以实际系统 inset 和最新标准复核。

- [x] **Step 3: 更新 skill 路由与 metadata**

在 description 中增加触发语义；在 Required Reference 和 Workflow 中路由新 reference。`openai.yaml` 保持 `鸿蒙自检` 和内部 ID 不变，只扩展短描述与默认审查提示。

- [x] **Step 4: 运行契约和结构验证**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-harmonyos-self-check-skill.ps1 -SkillRoot .superpowers\harmonyos-self-check-next
$env:PYTHONUTF8='1'; python C:\Users\27363\.agents\skills\skill-creator\scripts\quick_validate.py .superpowers\harmonyos-self-check-next
```

Expected: 契约输出所有断言通过；validator 输出 `Skill is valid!`。

### Task 3: 安装与安装后复验

**Files:**
- Replace from validated copy: `C:\Users\27363\.agents\skills\harmonyos-self-check\SKILL.md`
- Replace from validated copy: `C:\Users\27363\.agents\skills\harmonyos-self-check\agents\openai.yaml`
- Create from validated copy: `C:\Users\27363\.agents\skills\harmonyos-self-check\references\release-preflight-cases.md`

- [x] **Step 1: 计算工作副本清单并覆盖安装目录**

只复制上述三个变化文件，不删除或改写其他 reference。

- [x] **Step 2: 校验安装版与工作副本**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-harmonyos-self-check-skill.ps1 -SkillRoot C:\Users\27363\.agents\skills\harmonyos-self-check
$env:PYTHONUTF8='1'; python C:\Users\27363\.agents\skills\skill-creator\scripts\quick_validate.py C:\Users\27363\.agents\skills\harmonyos-self-check
Get-FileHash .superpowers\harmonyos-self-check-next\SKILL.md, C:\Users\27363\.agents\skills\harmonyos-self-check\SKILL.md
```

Expected: 契约与 validator 通过，三个变化文件的工作副本/安装版 SHA-256 成对一致。

### Task 4: 项目记录和全量验证

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design.md`
- Modify: `design-qa.md`
- Test: `scripts/test-harmonyos-self-check-skill.ps1`

- [x] **Step 1: 回填来源处置和验证结果**

记录已新增、因已有覆盖而省略、404、无正文和粘连 URL 拆分结果；明确应用运行时未改变，设备 UI 验证不适用。

- [x] **Step 2: 运行最终 skill 验证**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-harmonyos-self-check-skill.ps1
$env:PYTHONUTF8='1'; python C:\Users\27363\.agents\skills\skill-creator\scripts\quick_validate.py C:\Users\27363\.agents\skills\harmonyos-self-check
```

Expected: 全部通过。

- [x] **Step 3: 运行项目标准检查和构建**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1
```

Expected: 记录真实退出码和已知的工作区既有签名材料阻断；构建须输出 `BUILD SUCCESSFUL` 才能宣称构建通过。

- [x] **Step 4: 最终差异审查**

Run:

```powershell
git diff --check
git status --short
```

Expected: 本任务新增/修改范围仅包括计划、skill 契约和四份工作流记录；其他工作区改动保持原样。
