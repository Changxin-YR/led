# LED滚动字幕 - 鸿蒙应用开发文档

## 一、产品概述

### 1.1 产品定位

**LED滚动字幕**是一款纯鸿蒙本地应用，将手机屏幕变为LED滚动显示屏，适用于演唱会应援、接机举牌、表白告白、店铺广告、课堂通知、聚会互动等场景。无需登录、无需联网，即开即用。

### 1.2 目标用户

| 用户群体 | 核心场景 | 使用频次 |
|---------|---------|--------|
| 追星粉丝 | 演唱会/粉丝见面会应援 | 高频（活动期间每日使用） |
| 年轻情侣 | 表白/纪念日/求婚 | 中频 |
| 接送人员 | 机场/车站举牌接人 | 中频 |
| 小商户 | 店铺促销/摆摊广告 | 高频（每日使用） |
| 学生/老师 | 课堂通知/活动标语 | 中频 |
| 聚会活动 | 生日/派对/游戏互动 | 低频但传播强 |

### 1.3 核心竞争力

- **零门槛**：不登录、不联网、不收费，打开即用
- **高颜值**：丰富的预设主题和动画效果
- **多模式**：滚动、闪烁、呼吸、弹幕、翻页等
- **实用性强**：亮度最大化、常亮模式、全屏沉浸
- **分享传播**：模板一键复制，口口相传

### 1.4 月活增长策略

**目标：一个月达到400月活**

| 策略 | 方式 | 预期效果 |
|------|------|--------|
| 场景驱动 | 演唱会/节日/开学季 关键词优化 | 自然搜索流量 |
| 社交裂变 | 模板分享功能，引导下载 | 老带新 |
| 极致体验 | 零门槛使用，3秒出效果 | 高留存 |
| 高频场景 | 小商户每日使用促销 | 稳定日活 |
| 应用商店优化 | ASO关键词：LED、字幕、应援、举牌 | 搜索排名 |

---

## 二、功能清单

### 2.1 核心功能模块

| 模块 | 功能 | 优先级 |
|------|------|-------|
| 文字输入 | 支持中英文输入、多行文本、表情符号 | P0 |
| 滚动显示 | 水平滚动（左到右、右到左）、垂直滚动 | P0 |
| 颜色设置 | 文字颜色、背景颜色、预设配色方案 | P0 |
| 字体大小 | 可调节字号、自适应屏幕 | P0 |
| 滚动速度 | 5档速度可调 | P0 |
| 全屏显示 | 沉浸式全屏、隐藏状态栏 | P0 |
| 屏幕常亮 | 显示期间保持屏幕不息屏 | P0 |
| 显示模式 | 滚动/静态/闪烁/呼吸/弹幕/翻页/霓虹 | P0 |
| 预设模板 | 演唱会应援/接机/表白/促销等场景模板 | P1 |
| 历史记录 | 本地保存最近使用的文字和配置 | P1 |
| 镜像翻转 | 水平镜像（适合透过玻璃展示） | P1 |
| LED点阵风格 | 模拟真实LED点阵显示效果 | P1 |
| 边框装饰 | 可选闪烁边框、霓虹灯效果 | P2 |
| 多行弹幕 | 多条文字同时弹幕式滚动 | P2 |
| 计数器模式 | 点击屏幕+1/-1计数显示 | P2 |
| 倒计时模式 | 大字体倒计时显示 | P2 |
| 横屏支持 | 自动旋转适配横屏 | P1 |

### 2.2 功能详细说明

#### 2.2.1 文字输入模块
- 支持中文、英文、数字、标点、Emoji
- 最大支持200字符输入
- 支持多行文本（最多5行）
- 实时预览效果

#### 2.2.2 显示模式

| 模式 | 说明 | 动画 |
|------|------|------|
| 水平滚动 | 文字从右到左/从左到右匀速滚动 | translateX动画循环 |
| 垂直滚动 | 文字从下到上/从上到下匀速滚动 | translateY动画循环 |
| 静态显示 | 文字居中静止显示 | 无 |
| 闪烁模式 | 文字以固定频率闪烁 | opacity 0到1循环 |
| 呼吸模式 | 文字亮度渐变呼吸灯效果 | opacity渐变循环 |
| 弹幕模式 | 多条相同文字随机位置滚动 | 多实例translateX |
| 翻页模式 | 多行文字逐行翻页显示 | 逐行显示切换 |
| 霓虹模式 | 文字颜色渐变流动 | 色相渐变动画 |

#### 2.2.3 颜色系统

**预设配色方案（12套）：**
1. 经典绿 - 绿字黑底（经典LED风格）
2. 热情红 - 红字黑底（演唱会应援）
3. 纯净白 - 白字黑底（通用）
4. 浪漫粉 - 粉字黑底（表白）
5. 活力橙 - 橙字黑底（促销）
6. 科技蓝 - 蓝字黑底（科技感）
7. 土豪金 - 金字黑底（高端）
8. 荧光黄 - 黄字黑底（警示/醒目）
9. 梦幻紫 - 紫字黑底（梦幻）
10. 反转白 - 黑字白底（白天可见）
11. 彩虹渐变 - 渐变色字黑底
12. 自定义 - 用户自选文字色+背景色

**自定义颜色：**
- 色盘选择器（HSV色轮）
- RGB数值输入
- 最近使用的颜色记录（最多10个）

#### 2.2.4 预设模板

| 分类 | 模板名称 | 预设文字 | 配色 | 模式 |
|------|---------|---------|------|------|
| 应援 | 演唱会应援 | "[爱豆名] 我爱你" | 热情红 | 水平滚动 |
| 应援 | 粉丝加油 | "[爱豆名] fighting!" | 梦幻紫 | 闪烁 |
| 接机 | 接人举牌 | "接 [姓名]" | 纯净白 | 静态 |
| 接机 | 欢迎到来 | "欢迎 [姓名] 回家" | 活力橙 | 呼吸 |
| 表白 | 浪漫告白 | "[名字] 我喜欢你" | 浪漫粉 | 呼吸 |
| 表白 | 求婚 | "嫁给我好吗？" | 土豪金 | 闪烁 |
| 促销 | 店铺促销 | "全场 [X] 折" | 活力橙 | 水平滚动 |
| 促销 | 开业大吉 | "盛大开业 欢迎光临" | 热情红 | 水平滚动 |
| 通知 | 课堂通知 | "请保持安静" | 科技蓝 | 静态 |
| 通知 | 排队叫号 | "请 [X] 号到前台" | 经典绿 | 闪烁 |
| 互动 | 聚会游戏 | "真心话大冒险" | 彩虹渐变 | 霓虹 |
| 互动 | 生日快乐 | "生日快乐 [名字]" | 土豪金 | 呼吸 |

#### 2.2.5 历史记录
- 自动保存最近20条使用记录
- 记录包含：文字内容、配色方案、显示模式、速度、字体大小
- 支持一键恢复历史配置
- 支持删除单条/清空全部

---

## 三、技术架构

### 3.1 技术栈

| 项目 | 技术选型 |
|------|--------|
| 开发语言 | ArkTS 5.0 |
| UI框架 | ArkUI声明式 |
| SDK版本 | HarmonyOS SDK API 16 |
| 最低兼容 | API 12 |
| 构建工具 | Hvigor |
| 开发工具 | DevEco Studio 5.0+ |
| 目标设备 | phone, tablet, 2in1 |

### 3.2 系统依赖

```typescript
import { window } from '@kit.ArkUI'                    // 窗口管理（全屏、常亮、亮度）
import { display } from '@kit.ArkUI'                   // 屏幕信息
import { preferences } from '@kit.ArkData'             // 本地数据持久化
import { router } from '@kit.ArkUI'                    // 页面路由
import { promptAction } from '@kit.ArkUI'              // 弹窗提示
import { mediaquery } from '@kit.ArkUI'                // 媒体查询（横竖屏）
import { curves } from '@kit.ArkUI'                    // 动画曲线
```

### 3.3 应用架构

```
+------------------------------------------+
|              UI Layer (Pages)             |
|  HomePage | DisplayPage | SettingsPage   |
+------------------------------------------+
|           ViewModel Layer                |
|  BannerViewModel | HistoryViewModel      |
+------------------------------------------+
|           Service Layer                  |
|  AnimationService | StorageService       |
|  ScreenService   | TemplateService       |
+------------------------------------------+
|           Data Layer                     |
|  PreferencesRepository | Models          |
+------------------------------------------+
```

### 3.4 项目目录结构

```
led-banner/
├── AppScope/
│   ├── app.json5
│   └── resources/
│       └── base/
│           ├── element/
│           │   └── string.json
│           └── media/
│               └── app_icon.png          // 占位图标
├── entry/
│   ├── src/
│   │   └── main/
│   │       ├── ets/
│   │       │   ├── entryability/
│   │       │   │   └── EntryAbility.ets
│   │       │   ├── entrybackupability/
│   │       │   │   └── EntryBackupAbility.ets
│   │       │   ├── pages/
│   │       │   │   ├── Index.ets              // 首页（输入+配置）
│   │       │   │   ├── DisplayPage.ets        // 全屏LED显示
│   │       │   │   ├── TemplatePage.ets       // 模板选择页
│   │       │   │   ├── HistoryPage.ets        // 历史记录页
│   │       │   │   ├── ColorPickerPage.ets    // 颜色选择页
│   │       │   │   └── CounterPage.ets        // 计数器页
│   │       │   ├── components/
│   │       │   │   ├── TextInputCard.ets      // 文字输入组件
│   │       │   │   ├── ModeSelector.ets       // 模式选择器
│   │       │   │   ├── SpeedSlider.ets        // 速度滑块
│   │       │   │   ├── ColorPresets.ets       // 预设配色组件
│   │       │   │   ├── FontSizeSlider.ets     // 字号滑块
│   │       │   │   ├── PreviewCard.ets        // 实时预览卡片
│   │       │   │   ├── TemplateCard.ets       // 模板卡片
│   │       │   │   ├── HistoryItem.ets        // 历史记录项
│   │       │   │   ├── ColorWheel.ets         // 色轮选择器
│   │       │   │   ├── LEDText.ets            // LED文字渲染组件
│   │       │   │   ├── ScrollingText.ets      // 滚动文字组件
│   │       │   │   ├── BlinkingText.ets       // 闪烁文字组件
│   │       │   │   ├── BreathingText.ets      // 呼吸文字组件
│   │       │   │   ├── BarrageText.ets        // 弹幕文字组件
│   │       │   │   ├── NeonText.ets           // 霓虹文字组件
│   │       │   │   └── BorderEffect.ets       // 边框效果组件
│   │       │   ├── services/
│   │       │   │   ├── StorageService.ets     // 本地存储服务
│   │       │   │   ├── ScreenService.ets      // 屏幕控制服务
│   │       │   │   ├── TemplateService.ets    // 模板数据服务
│   │       │   │   └── AnimationService.ets   // 动画参数服务
│   │       │   ├── models/
│   │       │   │   ├── BannerConfig.ets       // 配置数据模型
│   │       │   │   ├── Template.ets           // 模板数据模型
│   │       │   │   ├── HistoryRecord.ets      // 历史记录模型
│   │       │   │   └── ColorScheme.ets        // 配色方案模型
│   │       │   └── common/
│   │       │       ├── Constants.ets          // 全局常量
│   │       │       ├── ColorPresets.ets       // 预设配色数据
│   │       │       └── Utils.ets              // 工具函数
│   │       ├── resources/
│   │       │   └── base/
│   │       │       ├── element/
│   │       │       │   ├── string.json
│   │       │       │   ├── color.json
│   │       │       │   └── float.json
│   │       │       ├── media/
│   │       │       │   ├── icon.png           // 占位图标
│   │       │       │   ├── startIcon.png      // 占位启动图标
│   │       │       │   └── background.png     // 占位背景
│   │       │       └── profile/
│   │       │           └── main_pages.json
│   │       └── module.json5
│   ├── hvigorfile.ts
│   └── oh-package.json5
├── hvigorfile.ts
├── build-profile.json5
├── oh-package.json5
├── AGENTS.md
├── tasks.md
├── changes.md
├── design.md
├── design-qa.md
├── docs/
│   └── qa/
│       └── README.md
└── scripts/
    ├── check-standard.ps1
    └── build-harmony.ps1
```

---

## 四、核心配置文件

### 4.1 app.json5

```json5
{
  "app": {
    "bundleName": "com.ledscroll.banner",
    "vendor": "LedScrollDev",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name",
    "minAPIVersion": 12,
    "targetAPIVersion": 16,
    "apiReleaseType": "Release"
  }
}
```

### 4.2 module.json5

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone",
      "tablet",
      "2in1"
    ],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:startIcon",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": [
              "entity.system.home"
            ],
            "actions": [
              "action.system.home"
            ]
          }
        ]
      }
    ],
    "extensionAbilities": [
      {
        "name": "EntryBackupAbility",
        "srcEntry": "./ets/entrybackupability/EntryBackupAbility.ets",
        "type": "backup",
        "exported": false,
        "metadata": [
          {
            "name": "ohos.extension.backup",
            "resource": "$profile:backup_config"
          }
        ]
      }
    ],
    "requestPermissions": []
  }
}
```

### 4.3 main_pages.json

```json
{
  "src": [
    "pages/Index",
    "pages/DisplayPage",
    "pages/TemplatePage",
    "pages/HistoryPage",
    "pages/ColorPickerPage",
    "pages/CounterPage"
  ]
}
```

---

## 五、核心数据模型

### 5.1 BannerConfig.ets

```typescript
// 显示模式枚举
export enum DisplayMode {
  SCROLL_HORIZONTAL = 'scroll_h',
  SCROLL_VERTICAL = 'scroll_v',
  STATIC = 'static',
  BLINK = 'blink',
  BREATH = 'breath',
  BARRAGE = 'barrage',
  FLIP = 'flip',
  NEON = 'neon'
}

// 滚动方向
export enum ScrollDirection {
  LEFT_TO_RIGHT = 'ltr',
  RIGHT_TO_LEFT = 'rtl',
  TOP_TO_BOTTOM = 'ttb',
  BOTTOM_TO_TOP = 'btt'
}

// 速度等级
export enum SpeedLevel {
  VERY_SLOW = 1,
  SLOW = 2,
  NORMAL = 3,
  FAST = 4,
  VERY_FAST = 5
}

// LED风格
export enum LEDStyle {
  SOLID = 'solid',
  DOT_MATRIX = 'dot',
  OUTLINE = 'outline'
}

// Banner配置模型
export interface BannerConfig {
  id: string
  text: string
  textColor: string
  backgroundColor: string
  fontSize: number
  displayMode: DisplayMode
  scrollDirection: ScrollDirection
  speedLevel: SpeedLevel
  ledStyle: LEDStyle
  isMirrored: boolean
  showBorder: boolean
  borderColor: string
  isLandscape: boolean
  createdAt: number
}

// 默认配置
export const DEFAULT_CONFIG: BannerConfig = {
  id: '',
  text: 'Hello World',
  textColor: '#00FF00',
  backgroundColor: '#000000',
  fontSize: 80,
  displayMode: DisplayMode.SCROLL_HORIZONTAL,
  scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
  speedLevel: SpeedLevel.NORMAL,
  ledStyle: LEDStyle.SOLID,
  isMirrored: false,
  showBorder: false,
  borderColor: '#00FF00',
  isLandscape: false,
  createdAt: 0
}
```

### 5.2 ColorScheme.ets

```typescript
export interface ColorScheme {
  id: string
  name: string
  textColor: string
  backgroundColor: string
  category: string
}

export const COLOR_PRESETS: ColorScheme[] = [
  { id: '1', name: '经典绿', textColor: '#00FF00', backgroundColor: '#000000', category: '经典' },
  { id: '2', name: '热情红', textColor: '#FF0000', backgroundColor: '#000000', category: '应援' },
  { id: '3', name: '纯净白', textColor: '#FFFFFF', backgroundColor: '#000000', category: '通用' },
  { id: '4', name: '浪漫粉', textColor: '#FF69B4', backgroundColor: '#000000', category: '表白' },
  { id: '5', name: '活力橙', textColor: '#FF8C00', backgroundColor: '#000000', category: '促销' },
  { id: '6', name: '科技蓝', textColor: '#00BFFF', backgroundColor: '#000000', category: '科技' },
  { id: '7', name: '土豪金', textColor: '#FFD700', backgroundColor: '#000000', category: '高端' },
  { id: '8', name: '荧光黄', textColor: '#FFFF00', backgroundColor: '#000000', category: '醒目' },
  { id: '9', name: '梦幻紫', textColor: '#9B59B6', backgroundColor: '#000000', category: '梦幻' },
  { id: '10', name: '反转白', textColor: '#000000', backgroundColor: '#FFFFFF', category: '白天' },
  { id: '11', name: '彩虹渐变', textColor: '#RAINBOW', backgroundColor: '#000000', category: '特效' },
  { id: '12', name: '自定义', textColor: '#FFFFFF', backgroundColor: '#000000', category: '自定义' }
]
```

### 5.3 Template.ets

```typescript
import { DisplayMode, ScrollDirection, SpeedLevel } from './BannerConfig'

export interface Template {
  id: string
  name: string
  category: string
  text: string
  textColor: string
  backgroundColor: string
  displayMode: DisplayMode
  scrollDirection: ScrollDirection
  speedLevel: SpeedLevel
  fontSize: number
  icon: string
}

export enum TemplateCategory {
  CHEER = '应援',
  PICKUP = '接机',
  LOVE = '表白',
  PROMO = '促销',
  NOTICE = '通知',
  FUN = '互动'
}
```

### 5.4 HistoryRecord.ets

```typescript
import { BannerConfig } from './BannerConfig'

export interface HistoryRecord {
  id: string
  config: BannerConfig
  lastUsedAt: number
  useCount: number
}
```

---

## 六、核心服务设计

### 6.1 StorageService.ets

```typescript
import { preferences } from '@kit.ArkData'
import { BannerConfig } from '../models/BannerConfig'
import { HistoryRecord } from '../models/HistoryRecord'

const STORE_NAME = 'led_banner_store'
const KEY_HISTORY = 'history_records'
const KEY_LAST_CONFIG = 'last_config'
const KEY_CUSTOM_COLORS = 'custom_colors'
const MAX_HISTORY = 20
const MAX_CUSTOM_COLORS = 10

export class StorageService {
  private store: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    this.store = await preferences.getPreferences(context, STORE_NAME)
  }

  async saveLastConfig(config: BannerConfig): Promise<void> {
    if (!this.store) return
    await this.store.put(KEY_LAST_CONFIG, JSON.stringify(config))
    await this.store.flush()
  }

  async getLastConfig(): Promise<BannerConfig | null> {
    if (!this.store) return null
    const raw = await this.store.get(KEY_LAST_CONFIG, '') as string
    if (!raw) return null
    return JSON.parse(raw) as BannerConfig
  }

  async addHistory(config: BannerConfig): Promise<void> {
    if (!this.store) return
    const records = await this.getHistory()
    const existing = records.findIndex(r => r.config.text === config.text)
    if (existing >= 0) {
      records[existing].lastUsedAt = Date.now()
      records[existing].useCount++
      records[existing].config = config
    } else {
      const record: HistoryRecord = {
        id: Date.now().toString(),
        config: config,
        lastUsedAt: Date.now(),
        useCount: 1
      }
      records.unshift(record)
    }
    const trimmed = records.slice(0, MAX_HISTORY)
    await this.store.put(KEY_HISTORY, JSON.stringify(trimmed))
    await this.store.flush()
  }

  async getHistory(): Promise<HistoryRecord[]> {
    if (!this.store) return []
    const raw = await this.store.get(KEY_HISTORY, '[]') as string
    return JSON.parse(raw) as HistoryRecord[]
  }

  async deleteHistory(id: string): Promise<void> {
    if (!this.store) return
    const records = await this.getHistory()
    const filtered = records.filter(r => r.id !== id)
    await this.store.put(KEY_HISTORY, JSON.stringify(filtered))
    await this.store.flush()
  }

  async clearHistory(): Promise<void> {
    if (!this.store) return
    await this.store.put(KEY_HISTORY, '[]')
    await this.store.flush()
  }

  async saveCustomColor(color: string): Promise<void> {
    if (!this.store) return
    const colors = await this.getCustomColors()
    const idx = colors.indexOf(color)
    if (idx >= 0) colors.splice(idx, 1)
    colors.unshift(color)
    const trimmed = colors.slice(0, MAX_CUSTOM_COLORS)
    await this.store.put(KEY_CUSTOM_COLORS, JSON.stringify(trimmed))
    await this.store.flush()
  }

  async getCustomColors(): Promise<string[]> {
    if (!this.store) return []
    const raw = await this.store.get(KEY_CUSTOM_COLORS, '[]') as string
    return JSON.parse(raw) as string[]
  }
}
```

### 6.2 ScreenService.ets

```typescript
import { window } from '@kit.ArkUI'

export class ScreenService {
  private windowStage: window.Window | null = null

  async init(win: window.Window): Promise<void> {
    this.windowStage = win
  }

  async enterFullScreen(): Promise<void> {
    if (!this.windowStage) return
    await this.windowStage.setWindowLayoutFullScreen(true)
    await this.windowStage.setWindowSystemBarEnable([])
  }

  async exitFullScreen(): Promise<void> {
    if (!this.windowStage) return
    await this.windowStage.setWindowLayoutFullScreen(false)
    await this.windowStage.setWindowSystemBarEnable(['status', 'navigation'])
  }

  async setKeepScreenOn(keepOn: boolean): Promise<void> {
    if (!this.windowStage) return
    await this.windowStage.setWindowKeepScreenOn(keepOn)
  }

  async setMaxBrightness(): Promise<void> {
    if (!this.windowStage) return
    await this.windowStage.setWindowBrightness(1.0)
  }

  async restoreBrightness(): Promise<void> {
    if (!this.windowStage) return
    await this.windowStage.setWindowBrightness(-1)
  }

  async setLandscape(landscape: boolean): Promise<void> {
    if (!this.windowStage) return
    if (landscape) {
      await this.windowStage.setPreferredOrientation(window.Orientation.LANDSCAPE)
    } else {
      await this.windowStage.setPreferredOrientation(window.Orientation.PORTRAIT)
    }
  }
}
```

### 6.3 AnimationService.ets

```typescript
import { SpeedLevel } from '../models/BannerConfig'

export class AnimationService {
  getScrollDuration(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 12000, 2: 8000, 3: 5000, 4: 3000, 5: 1500 }
    return map[speedLevel] || 5000
  }

  getBlinkInterval(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 2000, 2: 1500, 3: 1000, 4: 600, 5: 300 }
    return map[speedLevel] || 1000
  }

  getBreathDuration(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 5000, 2: 4000, 3: 3000, 4: 2000, 5: 1200 }
    return map[speedLevel] || 3000
  }

  getBarrageSpeed(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 8000, 2: 6000, 3: 4000, 4: 2500, 5: 1500 }
    return map[speedLevel] || 4000
  }

  getFlipInterval(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 5000, 2: 4000, 3: 3000, 4: 2000, 5: 1000 }
    return map[speedLevel] || 3000
  }

  getNeonCycleDuration(speedLevel: SpeedLevel): number {
    const map: Record<number, number> = { 1: 6000, 2: 4500, 3: 3000, 4: 2000, 5: 1000 }
    return map[speedLevel] || 3000
  }
}
```

### 6.4 TemplateService.ets

```typescript
import { Template, TemplateCategory } from '../models/Template'
import { DisplayMode, ScrollDirection, SpeedLevel } from '../models/BannerConfig'

export class TemplateService {
  private templates: Template[] = [
    { id: 't1', name: '演唱会应援', category: TemplateCategory.CHEER,
      text: '我爱你', textColor: '#FF0000', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_cheer' },
    { id: 't2', name: '粉丝加油', category: TemplateCategory.CHEER,
      text: 'Fighting!', textColor: '#9B59B6', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 90, icon: 'placeholder_fight' },
    { id: 't3', name: '接人举牌', category: TemplateCategory.PICKUP,
      text: '接 XXX', textColor: '#FFFFFF', backgroundColor: '#000000',
      displayMode: DisplayMode.STATIC, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 120, icon: 'placeholder_pickup' },
    { id: 't4', name: '欢迎到来', category: TemplateCategory.PICKUP,
      text: '欢迎回家', textColor: '#FF8C00', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_welcome' },
    { id: 't5', name: '浪漫告白', category: TemplateCategory.LOVE,
      text: '我喜欢你', textColor: '#FF69B4', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_love' },
    { id: 't6', name: '求婚', category: TemplateCategory.LOVE,
      text: '嫁给我好吗？', textColor: '#FFD700', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 90, icon: 'placeholder_marry' },
    { id: 't7', name: '店铺促销', category: TemplateCategory.PROMO,
      text: '全场5折', textColor: '#FF8C00', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.FAST, fontSize: 110, icon: 'placeholder_sale' },
    { id: 't8', name: '开业大吉', category: TemplateCategory.PROMO,
      text: '盛大开业 欢迎光临', textColor: '#FF0000', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 90, icon: 'placeholder_open' },
    { id: 't9', name: '课堂通知', category: TemplateCategory.NOTICE,
      text: '请保持安静', textColor: '#00BFFF', backgroundColor: '#000000',
      displayMode: DisplayMode.STATIC, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_quiet' },
    { id: 't10', name: '排队叫号', category: TemplateCategory.NOTICE,
      text: '请1号到前台', textColor: '#00FF00', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_queue' },
    { id: 't11', name: '聚会游戏', category: TemplateCategory.FUN,
      text: '真心话大冒险', textColor: '#RAINBOW', backgroundColor: '#000000',
      displayMode: DisplayMode.NEON, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 80, icon: 'placeholder_game' },
    { id: 't12', name: '生日快乐', category: TemplateCategory.FUN,
      text: '生日快乐', textColor: '#FFD700', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_birthday' }
  ]

  getAllTemplates(): Template[] {
    return this.templates
  }

  getTemplatesByCategory(category: string): Template[] {
    return this.templates.filter(t => t.category === category)
  }

  getCategories(): string[] {
    const cats = new Set(this.templates.map(t => t.category))
    return Array.from(cats)
  }
}
```

---

## 七、核心页面设计

### 7.1 Index.ets（首页）

首页包含以下区域：
- 顶部标题栏
- 实时预览卡片（黑底+当前配色文字预览）
- 文字输入区（TextArea，200字限制）
- 显示模式选择（Flex wrap芯片按钮）
- 配色方案选择（Grid色块+名称）
- 速度滑块（Slider 1-5档）
- 字体大小滑块（Slider 30-200）
- 其他设置（Toggle开关：镜像/点阵/边框/横屏）
- 开始显示按钮（跳转DisplayPage）
- 底部导航栏（首页/模板/历史/计数器）

**关键交互逻辑：**
- aboutToAppear时初始化StorageService，恢复上次配置
- 点击"开始显示"时保存配置到历史记录，跳转DisplayPage并传参
- 底部导航通过router.pushUrl切换页面

### 7.2 DisplayPage.ets（全屏LED显示页）

全屏沉浸式LED显示，关键功能：
- aboutToAppear：解析路由参数获取BannerConfig
- initScreen：获取窗口实例，设置全屏+常亮+最大亮度+横屏（如配置）
- startAnimation：根据displayMode启动对应动画
- 双击暂停/继续
- 右上角退出按钮（半透明）
- aboutToDisappear：恢复窗口状态（退出全屏、恢复亮度、关闭常亮）

**动画实现方式：**
- 水平/垂直滚动：animateTo + translate + iterations:-1
- 闪烁：setInterval切换opacity
- 呼吸：animateTo + opacity渐变 + Curve.EaseInOut
- 弹幕：ForEach多实例 + 随机Y偏移 + animateTo
- 翻页：setInterval切换currentLineIndex
- 霓虹：animateTo + 颜色数组循环切换

### 7.3 TemplatePage.ets（模板选择页）

- 顶部分类Tab（应援/接机/表白/促销/通知/互动）
- Grid网格展示模板卡片
- 卡片包含：模板名称、预览文字、配色预览
- 点击卡片弹出编辑弹窗（可修改文字中的占位符）
- 确认后跳转DisplayPage

### 7.4 HistoryPage.ets（历史记录页）

- List列表展示历史记录
- 每项显示：文字内容、使用时间、使用次数、配色预览
- 左滑删除单条
- 右上角清空全部按钮
- 点击恢复配置并跳转DisplayPage

### 7.5 ColorPickerPage.ets（颜色选择页）

- HSV色轮选择器（Canvas绘制）
- 明度/饱和度滑块
- RGB数值输入（三个输入框）
- 颜色预览区
- 最近使用颜色列表（最多10个圆形色块）
- 确认按钮返回结果

### 7.6 CounterPage.ets（计数器页）

- 全屏黑底
- 大号数字居中显示
- 底部加减按钮（圆形，红绿配色）
- 顶部返回+重置按钮
- 全屏沉浸+常亮

---

## 八、多设备适配策略

### 8.1 断点系统

| 断点 | 范围 | 设备 | 布局策略 |
|------|------|------|--------|
| SM | < 600vp | 手机竖屏 | 单列布局 |
| MD | 600-840vp | 手机横屏/小平板 | 双列配置 |
| LG | > 840vp | 平板/2in1 | 左右分栏 |

### 8.2 适配要点

- **字体大小**：根据屏幕宽度动态计算最大字号
- **滚动速度**：根据屏幕宽度自动调整滚动时长
- **布局**：首页配置区在大屏上使用双列/分栏
- **全屏显示**：始终充满可用区域
- **安全区域**：所有交互按钮避开刘海/挖孔区域

---

## 九、AppGallery上架准备

### 9.1 应用信息

| 字段 | 内容 |
|------|------|
| 应用名称 | LED滚动字幕 |
| 包名 | com.ledscroll.banner |
| 分类 | 工具 > 实用工具 |
| 适用设备 | 手机、平板、2in1 |
| 最低API | 12 |
| 目标API | 16 |
| 语言 | 中文（简体） |
| 关键词 | LED、滚动字幕、应援牌、举牌、弹幕、电子横幅 |

### 9.2 应用描述

**一句话介绍：** 把手机变成LED滚动显示屏，演唱会应援、接机举牌、店铺广告必备工具

**详细描述：**
LED滚动字幕是一款免费、无广告、无需登录的LED显示工具。将您的手机屏幕变为醒目的LED滚动显示屏，支持8种显示模式、12种预设配色、5档速度调节，适用于演唱会应援、机场接人、店铺促销、课堂通知等多种场景。

主要功能：
- 8种显示模式：滚动、静态、闪烁、呼吸、弹幕、翻页、霓虹
- 12种预设配色+自定义颜色
- 丰富的场景模板，一键使用
- 全屏沉浸显示，最大亮度
- 支持镜像翻转、LED点阵风格
- 计数器模式
- 历史记录自动保存
- 支持横屏显示
- 完全离线，保护隐私

### 9.3 隐私合规

- **不收集任何用户数据**
- **不需要网络权限**
- **不需要存储权限**（使用应用沙箱Preferences）
- **不需要任何敏感权限**
- **无第三方SDK**
- **无广告SDK**

### 9.4 构建命令

```powershell
# Debug构建
hvigorw assembleHap --no-daemon --mode module -p product=default -p buildMode=debug

# Release构建
hvigorw assembleHap --no-daemon --mode module -p product=default -p buildMode=release
```

---

## 十、开发计划

### 10.1 阶段划分

| 阶段 | 时间 | 内容 | 交付物 |
|------|------|------|-------|
| P1-基础框架 | 第1-2天 | 项目搭建、路由、数据模型、存储服务 | 可运行框架 |
| P2-核心显示 | 第3-5天 | 首页UI、全屏显示页、滚动/静态/闪烁动画 | 核心功能可用 |
| P3-丰富模式 | 第6-8天 | 呼吸/弹幕/翻页/霓虹模式、LED点阵风格 | 全部显示模式 |
| P4-模板系统 | 第9-10天 | 模板页、颜色选择器、历史记录 | 功能完备 |
| P5-计数器+适配 | 第11-12天 | 计数器页、横屏适配、多设备适配 | 全设备可用 |
| P6-打磨+上架 | 第13-15天 | 性能优化、边界情况处理、上架材料准备 | 可提审版本 |

### 10.2 关键里程碑

1. **Day 2** - 框架搭建完成，首页可交互
2. **Day 5** - 全屏LED显示可用，3种核心模式
3. **Day 8** - 8种显示模式全部实现
4. **Day 10** - 模板+历史+颜色选择器完成
5. **Day 12** - 计数器+横屏+多设备适配完成
6. **Day 15** - 提交AppGallery审核

---

## 十一、测试清单

### 11.1 功能测试

| 测试项 | 验证内容 | 状态 |
|--------|---------|------|
| 文字输入 | 中英文、Emoji、200字符限制 | 待测 |
| 水平滚动 | 左到右、右到左、速度5档 | 待测 |
| 垂直滚动 | 上到下、下到上 | 待测 |
| 静态显示 | 居中、自适应字号 | 待测 |
| 闪烁模式 | 频率随速度变化 | 待测 |
| 呼吸模式 | 渐变平滑 | 待测 |
| 弹幕模式 | 多条滚动、不重叠 | 待测 |
| 翻页模式 | 多行轮播 | 待测 |
| 霓虹模式 | 颜色渐变流畅 | 待测 |
| 全屏显示 | 隐藏状态栏、沉浸式 | 待测 |
| 屏幕常亮 | 不息屏 | 待测 |
| 最大亮度 | 进入全屏后亮度最大 | 待测 |
| 镜像翻转 | 文字水平翻转 | 待测 |
| LED点阵 | 点阵风格渲染 | 待测 |
| 边框效果 | 闪烁边框 | 待测 |
| 颜色预设 | 12套配色切换 | 待测 |
| 自定义颜色 | 色轮+RGB输入 | 待测 |
| 模板选择 | 12个模板一键应用 | 待测 |
| 历史记录 | 保存/恢复/删除/清空 | 待测 |
| 计数器 | +1/-1/重置/全屏 | 待测 |
| 横屏 | 自动旋转 | 待测 |
| 双击暂停 | 暂停/恢复动画 | 待测 |

### 11.2 兼容性测试

| 设备 | 测试内容 |
|------|--------|
| 手机竖屏 | 全功能验证 |
| 手机横屏 | 横屏适配 |
| 平板 | 大屏布局 |
| 折叠屏 | 展开/折叠切换 |

### 11.3 性能测试

- 动画帧率 >= 60fps
- 页面切换 < 300ms
- 内存占用 < 100MB
- 长时间显示（30分钟+）无卡顿
- 快速切换模式无崩溃

### 11.4 异常测试

- 空文本提交
- 超长文本（200字符）显示
- 快速连续操作
- 后台切回
- 来电中断
- 低电量模式

---

## 十二、关键技术要点

### 12.1 动画实现

```typescript
// 使用animateTo实现流畅的滚动动画
animateTo({
  duration: scrollDuration,
  curve: Curve.Linear,
  iterations: -1,
  playMode: PlayMode.Normal
}, () => {
  this.offsetX = -textWidth
})
```

### 12.2 屏幕管理

```typescript
// 全屏+常亮+最大亮度 三合一
async enterDisplayMode(win: window.Window): Promise<void> {
  await win.setWindowLayoutFullScreen(true)
  await win.setWindowSystemBarEnable([])
  await win.setWindowKeepScreenOn(true)
  await win.setWindowBrightness(1.0)
}
```

### 12.3 数据持久化

```typescript
// 使用Preferences存储，无需权限
const store = await preferences.getPreferences(context, 'led_banner_store')
await store.put('key', JSON.stringify(data))
await store.flush()
```

### 12.4 状态管理规范

| 装饰器 | 用途 |
|--------|------|
| @State | 页面内部状态 |
| @Prop | 父到子单向传递 |
| @Link | 父子双向绑定 |
| @Provide/@Consume | 跨层级共享 |

---

## 十三、已知限制与风险

| 风险 | 说明 | 缓解措施 |
|------|------|--------|
| 动画性能 | 大量文字+高速滚动可能掉帧 | 限制最大字符数、优化渲染 |
| 屏幕烧屏 | OLED长时间静态显示 | 提示用户注意使用时长 |
| 电池消耗 | 最大亮度+常亮耗电快 | 提示用户注意电量 |
| 彩虹渐变 | ArkUI不直接支持文字渐变 | 使用多段Text拼接或Canvas |
| LED点阵 | 需要自定义渲染 | 使用Canvas或Grid模拟 |
