import { preferences } from '@kit.ArkData'
import { AppTheme } from '../common/Theme'
import { UiContextHelper } from '../common/UiContextHelper'

@Entry
@Component
struct CounterPage {
  @State count: number = 0
  @State isUpdating: boolean = false
  private store: preferences.Preferences | null = null
  private storageInitPromise: Promise<void> | null = null
  private writeQueue: Promise<void> = Promise.resolve()
  private hasLocalChange: boolean = false

  aboutToAppear(): void {
    this.storageInitPromise = this.loadCount()
    this.storageInitPromise.catch((error: Error) => {
      console.error(`CounterPage: counter initialization failed: ${JSON.stringify(error)}`)
    })
  }

  private async loadCount(): Promise<void> {
    try {
      this.store = await preferences.getPreferences(
        UiContextHelper.requireHostContext(this.getUIContext()), 'led_banner_store')
      const saved = await this.store.get('counter_value', 0) as Object
      if (!this.hasLocalChange) {
        this.count = typeof saved === 'number' && !isNaN(saved as number) ? saved as number : 0
      }
    } catch (error) {
      this.store = null
      if (!this.hasLocalChange) this.count = 0
      console.error(`CounterPage: failed to load counter: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '计数器数据加载失败，已使用默认值')
    }
  }

  private async ensureStorageReady(): Promise<void> {
    if (!this.storageInitPromise) this.storageInitPromise = this.loadCount()
    const pending = this.storageInitPromise
    try {
      await pending
      if (!this.store) throw new Error('Counter storage is unavailable')
    } catch (error) {
      if (this.storageInitPromise === pending) this.storageInitPromise = null
      throw new Error(`Counter storage initialization failed: ${JSON.stringify(error)}`)
    }
  }

  private async changeCount(delta: number): Promise<void> {
    this.hasLocalChange = true
    this.count += delta
    this.persistCount()
  }

  private async setCount(value: number): Promise<void> {
    this.hasLocalChange = true
    this.count = value
    this.persistCount()
  }

  private async confirmReset(): Promise<void> {
    if (this.count === 0) return
    try {
      const result = await this.getUIContext().getPromptAction().showDialog({
        title: '确认重置',
        message: '确定要将计数器重置为 0 吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '重置', color: AppTheme.DANGER }
        ]
      })
      if (result.index === 1) {
        await this.setCount(0)
      }
    } catch (error) {
      console.error(`CounterPage: failed to confirm reset: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '重置失败，请重试')
    }
  }

  private persistCount(): void {
    const value = this.count
    const pending = this.writeQueue.then(async (): Promise<void> => {
      await this.ensureStorageReady()
      if (!this.store) throw new Error('Counter storage is unavailable')
      await this.store.put('counter_value', value)
      await this.store.flush()
    })
    this.writeQueue = pending.catch((error: Error): void => {
      console.error(`CounterPage: failed to persist counter: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '计数器保存失败，请重试')
    })
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildCounterPanel()
      Row() {
        this.buildCounterButton('−', AppTheme.DANGER, () => this.changeCount(-1))
        this.buildCounterButton('+', AppTheme.SUCCESS, () => this.changeCount(1))
      }
      .width('100%')
      .constraintSize({ maxWidth: 720 })
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1)
      .padding({ left: 36, right: 36, bottom: 52 })
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
        .onClick(() => UiContextHelper.back(this.getUIContext()))
      Blank()
      Text('重置')
        .fontSize(AppTheme.uiFontSize(15))
        .fontColor(AppTheme.WARNING)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .opacity(this.isUpdating ? 0.5 : 1)
        .enabled(!this.isUpdating)
        .padding({ left: 12, right: 2, top: 10, bottom: 10 })
        .onClick(() => this.confirmReset())
    }
    .width('100%')
    .height(AppTheme.HEADER_HEIGHT)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
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
        .fontSize(AppTheme.uiFontSize(12))
        .lineHeight(18)
        .fontColor(AppTheme.LED_MATRIX_DOT_COLOR)
        .opacity(AppTheme.LED_MATRIX_DOT_OPACITY)
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
    .margin({ top: 48 })
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
      .fontSize(AppTheme.uiFontSize(48))
      .fontWeight(FontWeight.Lighter)
      .fontColor(AppTheme.ON_ACCENT)
      .backgroundColor(color)
      .borderRadius(52)
      .border({ width: 1, color: '#FFFFFF' })
      .shadow({ radius: 24, color: color, offsetX: 0, offsetY: 2 })
      .enabled(!this.isUpdating)
      .onClick(action)
  }
}
