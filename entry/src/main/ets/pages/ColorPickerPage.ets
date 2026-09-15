import { StorageService } from '../services/StorageService'
import { Utils } from '../common/Utils'
import { AppTheme } from '../common/Theme'
import { LedPanel } from '../components/LedPanel'
import { UiContextHelper } from '../common/UiContextHelper'

@Entry
@Component
struct ColorPickerPage {
  @State hue: number = 183
  @State saturation: number = 1.0
  @State hsvBrightness: number = 1.0
  @State currentColor: string = '#00E5FF'
  @State redValue: number = 0
  @State greenValue: number = 229
  @State blueValue: number = 255
  @State customColors: string[] = []
  @State isSaving: boolean = false
  private storageService: StorageService = StorageService.getInstance()
  private defaultRecentColors: string[] = ['#00E5FF', '#9346D8', '#F04F98', '#FF9800', '#FFE000', '#00D735']

  aboutToAppear(): void {
    this.loadCustomColors()
    this.updateColorFromHsv()
  }

  private async loadCustomColors(): Promise<void> {
    try {
      await this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      this.customColors = await this.storageService.getCustomColors()
    } catch (error) {
      this.customColors = []
      console.error(`ColorPickerPage: failed to load custom colors: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '最近颜色加载失败')
    }
  }

  private updateColorFromHsv(): void {
    const rgb = Utils.hsvToRgb(this.hue, this.saturation, this.hsvBrightness)
    this.redValue = rgb.r
    this.greenValue = rgb.g
    this.blueValue = rgb.b
    this.currentColor = Utils.rgbToHex(rgb.r, rgb.g, rgb.b)
  }

  private updateColorFromRgb(): void {
    this.currentColor = Utils.rgbToHex(this.redValue, this.greenValue, this.blueValue)
    const r = this.redValue / 255
    const g = this.greenValue / 255
    const b = this.blueValue / 255
    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    const delta = max - min
    this.hsvBrightness = max
    this.saturation = max === 0 ? 0 : delta / max
    if (delta === 0) this.hue = 0
    else if (max === r) this.hue = 60 * (((g - b) / delta) % 6)
    else if (max === g) this.hue = 60 * ((b - r) / delta + 2)
    else this.hue = 60 * ((r - g) / delta + 4)
    if (this.hue < 0) this.hue += 360
  }

  private getRecentColors(): string[] {
    const colors: string[] = []
    this.customColors.forEach((color: string) => {
      if (colors.indexOf(color) < 0) colors.push(color)
    })
    this.defaultRecentColors.forEach((color: string) => {
      if (colors.indexOf(color) < 0) colors.push(color)
    })
    return colors.slice(0, 6)
  }

  private persistCustomColor(color: string): void {
    this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      .then(() => this.storageService.saveCustomColor(color))
      .catch((error: Error) => {
        console.error(`ColorPickerPage: failed to persist custom color: ${JSON.stringify(error)}`)
      })
  }

  private addRecentColor(color: string): void {
    this.customColors = [color, ...this.customColors.filter((item: string) => item !== color)].slice(0, 10)
  }

  build() {
    Column() {
      this.buildHeader()
      Scroll() {
        Column() {
          this.buildColorPreview()
          this.buildHueSlider()
          this.buildValueSlider('饱和度 (S)', Math.round(this.saturation * 100), (value: number) => {
            this.saturation = value / 100
            this.updateColorFromHsv()
          })
          this.buildValueSlider('明度 (V)', Math.round(this.hsvBrightness * 100), (value: number) => {
            this.hsvBrightness = value / 100
            this.updateColorFromHsv()
          })
          this.buildRgbInputs()
          this.buildRecentColors()
          this.buildConfirmButton()
        }
        .width('100%')
        .constraintSize({ maxWidth: 620 })
        .alignSelf(ItemAlign.Center)
        .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.PAGE_BG)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('‹')
        .fontSize(38)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .width(40)
        .height(48)
        .textAlign(TextAlign.Center)
        .onClick(() => UiContextHelper.back(this.getUIContext()))
      Text('自定义颜色')
        .fontSize(AppTheme.uiFontSize(20))
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ left: 8 })
      Blank()
    }
    .width('100%')
    .height(AppTheme.HEADER_HEIGHT)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildColorPreview() {
    Column() {
      LedPanel({ text: 'Aa 预览', color: this.currentColor, panelHeight: 152, fontSize: 43, radius: 14 })
      Row() {
        Text(this.currentColor.toUpperCase())
          .fontSize(AppTheme.uiFontSize(14))
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
        Text('▣')
          .fontSize(17)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .margin({ left: 17 })
      }
      .height(36)
      .padding({ left: 25, right: 14 })
      .margin({ top: 15 })
      .backgroundColor(AppTheme.SURFACE_SOFT)
      .borderRadius(9)
      .border({ width: 1, color: '#26354B' })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ top: AppTheme.PAGE_SECTION_GAP, bottom: AppTheme.PAGE_SECTION_GAP })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHueSlider() {
    Column() {
      Row() {
        Text('色相 (H)')
          .fontSize(AppTheme.uiFontSize(13))
          .fontColor(AppTheme.TEXT_SECONDARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
        Blank()
        Text(`${Math.round(this.hue)}°`)
          .fontSize(AppTheme.uiFontSize(13))
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
      }
      .width('100%')
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          ForEach(['#FF0000', '#FF9800', '#FFF500', '#31EF38', '#00E5FF', '#005BFF', '#7B00FF', '#E500A4', '#FF001E'], (color: string) => {
            Column()
              .layoutWeight(1)
              .height(12)
              .backgroundColor(color)
          })
        }
        .width('100%')
        .height(12)
        .borderRadius(7)
        .clip(true)
        Slider({ value: this.hue, min: 0, max: 360, step: 1, style: SliderStyle.InSet })
          .width('100%')
          .selectedColor('#00000000')
          .trackColor('#00000000')
          .blockColor('#1CA8E8')
          .onChange((value: number) => {
            this.hue = Math.round(value)
            this.updateColorFromHsv()
          })
      }
      .width('100%')
      .height(32)
    }
    .width('100%')
    .margin({ bottom: AppTheme.PAGE_SECTION_GAP })
  }

  @Builder
  buildValueSlider(label: string, value: number, change: (value: number) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(AppTheme.uiFontSize(13))
          .fontColor(AppTheme.TEXT_SECONDARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
        Blank()
        Text(`${value}%`)
          .fontSize(AppTheme.uiFontSize(13))
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
      }
      .width('100%')
      Slider({ value: value, min: 0, max: 100, step: 1, style: SliderStyle.InSet })
        .width('100%')
        .selectedColor(this.currentColor)
        .trackColor('#16334A')
        .blockColor('#169DE4')
        .onChange((next: number) => change(Math.round(next)))
    }
    .width('100%')
    .margin({ bottom: AppTheme.PAGE_SECTION_GAP })
  }

  @Builder
  buildRgbInputs() {
    Column() {
      Text('RGB 数值')
        .fontSize(AppTheme.uiFontSize(13))
        .fontColor(AppTheme.TEXT_SECONDARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 4 })
      Row() {
        this.buildRgbField('R', this.redValue, (value: number) => this.redValue = value)
        this.buildRgbField('G', this.greenValue, (value: number) => this.greenValue = value)
        this.buildRgbField('B', this.blueValue, (value: number) => this.blueValue = value)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .margin({ bottom: 18 })
  }

  @Builder
  buildRgbField(label: string, value: number, change: (value: number) => void) {
    Column() {
      Text(label)
        .fontSize(AppTheme.uiFontSize(12))
        .fontColor(AppTheme.TEXT_SECONDARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .margin({ bottom: 3 })
      TextInput({ text: value.toString() })
        .width('100%')
        .height(42)
        .fontSize(AppTheme.uiFontSize(16))
        .fontColor(AppTheme.TEXT_PRIMARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .textAlign(TextAlign.Center)
        .type(InputType.Number)
        .backgroundColor(AppTheme.SURFACE_SOFT)
        .borderRadius(8)
        .border({ width: 1, color: '#27374D' })
        .onChange((text: string) => {
          const isValidInput = /^\d+$/.test(text)
          const parsed = isValidInput ? parseInt(text, 10) : -1
          if (text.length === 0) return
          if (isValidInput && parsed >= 0 && parsed <= 255) {
            change(parsed)
            this.updateColorFromRgb()
          } else {
            UiContextHelper.showToast(this.getUIContext(), 'RGB请输入0-255的整数')
          }
        })
    }
    .width('29%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildRecentColors() {
    Column() {
      Text('最近使用')
        .fontSize(AppTheme.uiFontSize(13))
        .fontColor(AppTheme.TEXT_SECONDARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })
      Row() {
        ForEach(this.getRecentColors(), (color: string, index: number) => {
          Circle({ width: 36, height: 36 })
            .fill(color)
            .stroke(index === 0 ? AppTheme.ACCENT : '#C4DEEE')
            .strokeWidth(index === 0 ? 2 : 1)
            .margin({ right: 13 })
            .onClick(() => {
              this.currentColor = color
              const rgb = Utils.hexToRgb(color)
              this.redValue = rgb.r
              this.greenValue = rgb.g
              this.blueValue = rgb.b
              this.updateColorFromRgb()
            })
        })
        Text('+')
          .width(38)
          .height(38)
          .fontSize(23)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .borderRadius(12)
          .border({ width: 1, color: '#35455E' })
          .onClick(() => {
            this.addRecentColor(this.currentColor)
            this.persistCustomColor(this.currentColor)
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ bottom: 26 })
  }

  @Builder
  buildConfirmButton() {
    Button('✓  确认选择')
      .width('100%')
      .height(58)
      .fontSize(AppTheme.uiFontSize(18))
      .fontWeight(FontWeight.Bold)
      .fontColor(AppTheme.ON_ACCENT)
      .backgroundColor(AppTheme.ACCENT)
      .linearGradient({ angle: 90, colors: [[AppTheme.ACCENT, 0.0], [AppTheme.ACCENT_BLUE, 1.0]] })
      .borderRadius(20)
      .border({ width: 1, color: '#67F8FF' })
      .shadow({ radius: 16, color: '#007EA6', offsetX: 0, offsetY: 3 })
      .enabled(!this.isSaving)
      .onClick(() => {
        if (this.isSaving) return
        this.isSaving = true
        this.addRecentColor(this.currentColor)
        AppStorage.setOrCreate<string>('customColorResult', this.currentColor)
        this.persistCustomColor(this.currentColor)
        this.isSaving = false
        UiContextHelper.back(this.getUIContext())
      })
  }
}
