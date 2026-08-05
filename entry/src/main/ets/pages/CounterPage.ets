import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { AppTheme } from '../common/Theme'

@Entry
@Component
struct CounterPage {
  @State count: number = 0
  private store: preferences.Preferences | null = null

  aboutToAppear(): void {
    this.loadCount()
  }

  private async loadCount(): Promise<void> {
    try {
      this.store = await preferences.getPreferences(getContext(this), 'led_banner_store')
      const saved = await this.store.get('counter_value', 0) as number
      this.count = saved
    } catch (e) {
      this.count = 0
    }
  }

  private async updateCount(value: number): Promise<void> {
    this.count = value
    if (this.store) {
      try {
        await this.store.put('counter_value', value)
        await this.store.flush()
      } catch (e) {
        // persistence failed, counter still updates in memory
      }
    }
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildCounterPanel()
      Row() {
        this.buildCounterButton('−', AppTheme.DANGER, () => this.updateCount(this.count - 1))
        this.buildCounterButton('+', AppTheme.SUCCESS, () => this.updateCount(this.count + 1))
      }
      .width('100%')
      .constraintSize({ maxWidth: 720 })
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1)
      .padding({ left: 36, right: 36, bottom: 44 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
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
        .onClick(() => router.back())
      Blank()
      Text('重置')
        .fontSize(15)
        .fontColor(AppTheme.WARNING)
        .padding({ left: 12, right: 2, top: 10, bottom: 10 })
        .onClick(() => this.updateCount(0))
    }
    .width('100%')
    .height(62)
    .padding({ left: 12, right: 18 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildCounterPanel() {
    Stack({ alignContent: Alignment.Center }) {
      Text('· · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · ·')
        .width('100%')
        .height('100%')
        .fontSize(10)
        .lineHeight(18)
        .fontColor('#0089D2')
        .opacity(0.48)
        .textAlign(TextAlign.Center)
        .padding({ top: 16 })
      Text(this.count.toString())
        .fontSize(this.count.toString().length > 3 ? 92 : 130)
        .fontWeight(FontWeight.Bold)
        .fontFamily('monospace')
        .fontColor(AppTheme.ACCENT)
        .textShadow({ radius: 24, color: AppTheme.ACCENT, offsetX: 0, offsetY: 0 })
    }
    .width('88%')
    .height('47%')
    .constraintSize({ maxWidth: 720, maxHeight: 560 })
    .margin({ top: 42 })
    .backgroundColor('#010811')
    .borderRadius(34)
    .border({ width: 2, color: AppTheme.ACCENT })
    .shadow({ radius: 22, color: '#006B9C', offsetX: 0, offsetY: 0 })
    .clip(true)
  }

  @Builder
  buildCounterButton(label: string, color: string, action: () => void) {
    Button(label)
      .type(ButtonType.Circle)
      .width(104)
      .height(104)
      .fontSize(48)
      .fontWeight(FontWeight.Lighter)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(52)
      .border({ width: 1, color: '#FFFFFF' })
      .shadow({ radius: 24, color: color, offsetX: 0, offsetY: 2 })
      .onClick(action)
  }
}
