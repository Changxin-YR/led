import { router, promptAction } from '@kit.ArkUI'
import { BannerConfig, DisplayMode, SpeedLevel, LEDStyle, ScrollDirection, DisplayRouteParams } from '../models/BannerConfig'
import { ColorScheme, COLOR_PRESETS } from '../models/ColorScheme'
import { StorageService } from '../services/StorageService'
import { Constants } from '../common/Constants'
import { AppTheme } from '../common/Theme'
import { Utils } from '../common/Utils'
import { LedPanel } from '../components/LedPanel'

interface ModeOption {
  label: string
  mode: DisplayMode
}

interface NavOption {
  icon: string
  label: string
}

@Entry
@Component
struct Index {
  @State text: string = 'Hello World'
  @State textColor: string = AppTheme.ACCENT
  @State bannerBackgroundColor: string = '#000000'
  @State fontSize: number = 80
  @State displayMode: DisplayMode = DisplayMode.STATIC
  @State scrollDirection: ScrollDirection = ScrollDirection.RIGHT_TO_LEFT
  @State speedLevel: number = 4
  @State speedPercent: number = 80
  @State ledStyle: LEDStyle = LEDStyle.DOT_MATRIX
  @State isMirrored: boolean = true
  @State showBorder: boolean = true
  @State bannerBorderColor: string = AppTheme.ACCENT
  @State isLandscape: boolean = true
  @State selectedColorIndex: number = 5
  @State selectedModeIndex: number = 2
  private storageService: StorageService = StorageService.getInstance()

  private modeOptions: ModeOption[] = [
    { label: '水平滚动', mode: DisplayMode.SCROLL_HORIZONTAL },
    { label: '垂直滚动', mode: DisplayMode.SCROLL_VERTICAL },
    { label: '静态显示', mode: DisplayMode.STATIC },
    { label: '闪烁', mode: DisplayMode.BLINK },
    { label: '呼吸', mode: DisplayMode.BREATH },
    { label: '弹幕', mode: DisplayMode.BARRAGE },
    { label: '翻页', mode: DisplayMode.FLIP },
    { label: '霓虹', mode: DisplayMode.NEON }
  ]

  private navOptions: NavOption[] = [
    { icon: '⌂', label: '首页' },
    { icon: '▦', label: '模板' },
    { icon: '◷', label: '历史' },
    { icon: '▣', label: '计数器' }
  ]

  aboutToAppear(): void {
    this.initData()
  }

  onPageShow(): void {
    this.loadCustomColorResult()
  }

  private async initData(): Promise<void> {
    await this.storageService.init(getContext(this))
    const lastConfig = await this.storageService.getLastConfig()
    if (lastConfig) {
      this.applyConfig(lastConfig)
    }
  }

  private applyConfig(config: BannerConfig): void {
    this.text = config.text
    this.textColor = config.textColor
    this.bannerBackgroundColor = config.backgroundColor
    this.fontSize = config.fontSize
    this.displayMode = config.displayMode
    this.scrollDirection = config.scrollDirection
    this.speedLevel = config.speedLevel
    this.speedPercent = config.speedLevel * 20
    this.ledStyle = config.ledStyle
    this.isMirrored = config.isMirrored
    this.showBorder = config.showBorder
    this.bannerBorderColor = config.borderColor
    this.isLandscape = config.isLandscape
    const colorIndex = COLOR_PRESETS.findIndex((item: ColorScheme) => item.textColor === config.textColor)
    this.selectedColorIndex = colorIndex
    const modeIndex = this.modeOptions.findIndex((item: ModeOption) => item.mode === config.displayMode)
    if (modeIndex >= 0) this.selectedModeIndex = modeIndex
  }

  private loadCustomColorResult(): void {
    const customColor = AppStorage.get<string>('customColorResult')
    if (customColor) {
      this.textColor = customColor
      this.bannerBackgroundColor = '#000000'
      this.selectedColorIndex = -1
      AppStorage.delete('customColorResult')
    }
  }

  private buildConfig(): BannerConfig {
    return {
      id: Utils.generateId(), text: this.text, textColor: this.textColor,
      backgroundColor: this.bannerBackgroundColor, fontSize: this.fontSize,
      displayMode: this.displayMode, scrollDirection: this.scrollDirection,
      speedLevel: this.speedLevel as SpeedLevel, ledStyle: this.ledStyle,
      isMirrored: this.isMirrored, showBorder: this.showBorder,
      borderColor: this.bannerBorderColor, isLandscape: this.isLandscape,
      createdAt: Date.now()
    }
  }

  build() {
    Column() {
      this.buildTitleBar()
      Scroll() {
        Column() {
          this.buildPreview()
          this.buildTextInput()
          this.buildModeSelector()
          this.buildColorSelector()
          this.buildSliders()
          this.buildOtherSettings()
        }
        .width('100%')
        .constraintSize({ maxWidth: 620 })
        .alignSelf(ItemAlign.Center)
        .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 12 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      this.buildStartArea()
      this.buildBottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.PAGE_BG)
  }

  @Builder
  buildTitleBar() {
    Row() {
      Text('LED')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.ACCENT)
      Text(' 滚动字幕')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.TEXT_PRIMARY)
      Blank()
      Text('◷')
        .fontSize(25)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .width(42)
        .height(42)
        .textAlign(TextAlign.Center)
        .onClick(() => router.pushUrl({ url: 'pages/HistoryPage' }))
    }
    .width('100%')
    .height(52)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildPreview() {
    Column() {
      Text('预览效果')
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)
      LedPanel({
        text: this.text || 'Hello World',
        color: this.textColor === '#RAINBOW' ? AppTheme.ACCENT : this.textColor,
        panelHeight: 74,
        fontSize: Math.min(this.fontSize * 0.42, 38),
        radius: 13
      })
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  buildTextInput() {
    Column() {
      Text('输入文字')
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .margin({ bottom: 7 })
        .alignSelf(ItemAlign.Start)
      Stack({ alignContent: Alignment.BottomEnd }) {
        TextArea({ text: this.text, placeholder: '请输入要显示的文字...' })
          .width('100%')
          .height(60)
          .fontSize(16)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .placeholderColor(AppTheme.TEXT_MUTED)
          .backgroundColor(AppTheme.SURFACE_SOFT)
          .borderRadius(AppTheme.CONTROL_RADIUS)
          .border({ width: 1, color: '#27344A' })
          .padding({ left: 13, right: 13, top: 10, bottom: 22 })
          .maxLength(Constants.MAX_TEXT_LENGTH)
          .onChange((value: string) => this.text = value)
        Text(`${this.text.length}/${Constants.MAX_TEXT_LENGTH}`)
          .fontSize(11)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .margin({ right: 10, bottom: 7 })
      }
      .width('100%')
      .height(60)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  buildModeSelector() {
    Column() {
      Text('显示模式')
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .margin({ bottom: 7 })
        .alignSelf(ItemAlign.Start)
      Grid() {
        ForEach(this.modeOptions, (item: ModeOption, index: number) => {
          GridItem() {
            Text(item.label)
              .width('100%')
              .height(28)
              .fontSize(13)
              .fontColor(this.selectedModeIndex === index ? '#FFFFFF' : AppTheme.TEXT_PRIMARY)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.selectedModeIndex === index ? '#04BCEB' : AppTheme.SURFACE_SOFT)
              .borderRadius(16)
              .border({ width: 1, color: this.selectedModeIndex === index ? AppTheme.ACCENT : '#26354B' })
              .shadow({ radius: this.selectedModeIndex === index ? 9 : 0, color: '#006F9E' })
              .onClick(() => {
                this.selectedModeIndex = index
                this.displayMode = item.mode
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(9)
      .rowsGap(8)
      .height(60)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  buildColorSelector() {
    Column() {
      Row() {
        Text('颜色方案')
          .fontSize(13)
          .fontColor(AppTheme.TEXT_SECONDARY)
        Blank()
        Text('自定义 >')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.ACCENT)
          .onClick(() => router.pushUrl({ url: 'pages/ColorPickerPage' }))
      }
      .width('100%')
      .margin({ bottom: 7 })
      Grid() {
        ForEach(COLOR_PRESETS.slice(0, 11), (item: ColorScheme, index: number) => {
          GridItem() {
            Column() {
              Stack() {
                Circle({ width: 30, height: 30 })
                  .fill(item.textColor === '#RAINBOW' ? '#F40071' : item.textColor)
                  .stroke(this.selectedColorIndex === index ? '#FFFFFF' : '#B8EAFF')
                  .strokeWidth(this.selectedColorIndex === index ? 2 : 1)
                  .shadow({ radius: this.selectedColorIndex === index ? 8 : 0, color: item.textColor === '#RAINBOW' ? '#F40071' : item.textColor })
              }
              Text(item.name)
                .fontSize(10)
                .fontColor(AppTheme.TEXT_SECONDARY)
                .margin({ top: 4 })
                .maxLines(1)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.selectedColorIndex = index
              this.textColor = item.textColor
              this.bannerBackgroundColor = item.backgroundColor
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .height(100)
    }
    .width('100%')
    .margin({ bottom: 5 })
  }

  @Builder
  buildSliders() {
    Column() {
      this.buildSliderRow('滚动速度', this.speedPercent, 0, 100, (value: number) => {
        this.speedPercent = value
        this.speedLevel = Math.max(1, Math.min(5, Math.round(value / 20)))
      })
      this.buildSliderRow('字体大小', this.fontSize, Constants.MIN_FONT_SIZE, Constants.MAX_FONT_SIZE, (value: number) => {
        this.fontSize = value
      })
    }
    .width('100%')
  }

  @Builder
  buildSliderRow(label: string, value: number, min: number, max: number, change: (value: number) => void) {
    Row() {
      Text(label)
        .width(76)
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
      Slider({ value: value, min: min, max: max, step: 1, style: SliderStyle.InSet })
        .layoutWeight(1)
        .selectedColor(AppTheme.ACCENT)
        .trackColor(AppTheme.SURFACE_SOFT)
        .blockColor('#1C9DE8')
        .onChange((next: number) => change(Math.round(next)))
      Text(`${Math.round(value)}`)
        .width(30)
        .fontSize(14)
        .fontColor(AppTheme.ACCENT)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(30)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildOtherSettings() {
    Column() {
      Text('其他设置')
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .alignSelf(ItemAlign.Start)
      Column() {
        this.buildSettingRow('◫', '镜像翻转', this.isMirrored, (value: boolean) => this.isMirrored = value)
        this.buildSettingRow('⊙', '边框装饰', this.showBorder, (value: boolean) => this.showBorder = value)
        this.buildSettingRow('▣', '横屏显示', this.isLandscape, (value: boolean) => this.isLandscape = value)
      }
      .width('100%')
      .padding({ left: 8, right: 4 })
      .backgroundColor('#091426')
      .borderRadius(8)
    }
    .width('100%')
    .margin({ top: 2, bottom: 10 })
  }

  @Builder
  buildSettingRow(icon: string, label: string, enabled: boolean, change: (value: boolean) => void) {
    Row() {
      Text(icon)
        .width(28)
        .fontSize(15)
        .fontColor(AppTheme.TEXT_SECONDARY)
      Text(label)
        .fontSize(13)
        .fontColor(AppTheme.TEXT_SECONDARY)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: enabled })
        .width(42)
        .height(26)
        .selectedColor('#149CF2')
        .onChange((value: boolean) => change(value))
    }
    .width('100%')
    .height(27)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildStartArea() {
    Row() {
      this.buildStartButton()
    }
    .width('100%')
    .constraintSize({ maxWidth: 620 })
    .alignSelf(ItemAlign.Center)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, top: 7, bottom: 9 })
    .backgroundColor(AppTheme.PAGE_BG)
  }

  @Builder
  buildStartButton() {
    Button('▶  开始显示')
      .width('100%')
      .height(48)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor('#05BFE7')
      .linearGradient({ angle: 90, colors: [[AppTheme.ACCENT, 0.0], [AppTheme.ACCENT_BLUE, 1.0]] })
      .borderRadius(12)
      .border({ width: 1, color: '#64F6FF' })
      .shadow({ radius: 14, color: '#007FA8', offsetX: 0, offsetY: 2 })
      .onClick(() => this.startDisplay())
  }

  @Builder
  buildBottomNav() {
    Row() {
      ForEach(this.navOptions, (item: NavOption, index: number) => {
        Column() {
          Text(item.icon)
            .fontSize(index === 0 ? 25 : 23)
            .fontWeight(index === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(index === 0 ? AppTheme.ACCENT : AppTheme.TEXT_SECONDARY)
          Text(item.label)
            .fontSize(10)
            .fontColor(index === 0 ? AppTheme.ACCENT : AppTheme.TEXT_SECONDARY)
            .margin({ top: 2 })
        }
        .width('25%')
        .height(62)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.openTab(index))
      })
    }
    .width('100%')
    .height(66)
    .backgroundColor('#020A14')
    .border({ width: { top: 1 }, color: '#10233B' })
  }

  private openTab(index: number): void {
    if (index === 1) router.pushUrl({ url: 'pages/TemplatePage' })
    if (index === 2) router.pushUrl({ url: 'pages/HistoryPage' })
    if (index === 3) router.pushUrl({ url: 'pages/CounterPage' })
  }

  private async startDisplay(): Promise<void> {
    if (!this.text.trim()) {
      promptAction.showToast({ message: '请输入要显示的文字' })
      return
    }
    const config = this.buildConfig()
    await this.storageService.saveLastConfig(config)
    await this.storageService.addHistory(config)
    router.pushUrl({ url: 'pages/DisplayPage', params: new DisplayRouteParams(JSON.stringify(config)) })
  }
}
