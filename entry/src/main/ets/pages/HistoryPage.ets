import { HistoryRecord } from '../models/HistoryRecord'
import { BannerConfig, DisplayRouteParams } from '../models/BannerConfig'
import { StorageService } from '../services/StorageService'
import { Utils } from '../common/Utils'
import { AppTheme } from '../common/Theme'
import { LedPanel } from '../components/LedPanel'
import { UiContextHelper } from '../common/UiContextHelper'

@Entry
@Component
struct HistoryPage {
  @State records: HistoryRecord[] = []
  private storageService: StorageService = StorageService.getInstance()

  aboutToAppear(): void {
    this.loadHistory()
  }

  onPageShow(): void {
    this.loadHistory()
  }

  private async loadHistory(): Promise<void> {
    try {
      await this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      this.records = await this.storageService.getHistory()
    } catch (error) {
      this.records = []
      console.error(`HistoryPage: failed to load history: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '历史记录加载失败')
    }
  }

  build() {
    Column() {
      this.buildHeader()
      if (this.records.length === 0) this.buildEmptyState()
      else this.buildHistoryList()
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
      Text('历史记录')
        .fontSize(AppTheme.uiFontSize(20))
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ left: 8 })
      Blank()
      if (this.records.length > 0) {
        Text('清空')
          .fontSize(AppTheme.uiFontSize(15))
          .fontColor(AppTheme.DANGER)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .onClick(() => this.clearAll())
      } else {
        Blank()
          .width(48)
          .height(48)
      }
    }
    .width('100%')
    .height(AppTheme.HEADER_HEIGHT)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      LedPanel({ text: '—', color: AppTheme.ACCENT, panelHeight: 120, fontSize: 42, radius: 12 })
      Text('暂无历史记录')
        .fontSize(AppTheme.uiFontSize(17))
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ top: 22 })
      Text('开始显示字幕后，记录会保存在这里')
        .fontSize(AppTheme.uiFontSize(13))
        .fontColor(AppTheme.TEXT_MUTED)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 36, right: 36 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHistoryList() {
    List({ space: AppTheme.CARD_GAP }) {
      ForEach(this.records, (item: HistoryRecord) => {
        ListItem() { this.buildHistoryCard(item) }
      }, (item: HistoryRecord) => `${item.id}-${item.useCount}-${item.lastUsedAt}`)
    }
    .width('100%')
    .constraintSize({ maxWidth: 720 })
    .alignSelf(ItemAlign.Center)
    .layoutWeight(1)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, top: 5, bottom: 16 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  buildHistoryCard(item: HistoryRecord) {
    Row() {
      Column() {
        LedPanel({
          text: item.config.text,
          color: item.config.textColor === '#RAINBOW' ? AppTheme.ACCENT : item.config.textColor,
          panelHeight: 58,
          fontSize: item.config.text.length > 10 ? 18 : 25,
          radius: 7
        })
        Row() {
          Text(Utils.formatTime(item.lastUsedAt))
            .fontSize(AppTheme.uiFontSize(12))
            .fontColor(AppTheme.TEXT_SECONDARY)
            .fontWeight(AppTheme.UI_FONT_WEIGHT)
          Text('  |  ')
            .fontSize(AppTheme.uiFontSize(12))
            .fontColor(AppTheme.TEXT_MUTED)
            .fontWeight(AppTheme.UI_FONT_WEIGHT)
          Text(`使用${item.useCount}次`)
            .fontSize(AppTheme.uiFontSize(12))
            .fontColor(AppTheme.TEXT_SECONDARY)
            .fontWeight(AppTheme.UI_FONT_WEIGHT)
        }
        .width('100%')
        .margin({ top: 7 })
      }
      .layoutWeight(1)
      Text('⌫')
        .width(42)
        .height(42)
        .fontSize(19)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
        .margin({ left: 13 })
        .borderRadius(22)
        .border({ width: 1, color: '#27496E' })
        .onClick(() => this.deleteRecord(item.id))
    }
    .width('100%')
    .padding(10)
    .backgroundColor(AppTheme.SURFACE_RAISED)
    .borderRadius(10)
    .border({ width: 1, color: '#163456' })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.useRecord(item))
  }

  private persistDisplayConfig(config: BannerConfig): void {
    this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      .then(() => this.storageService.saveDisplayConfig(config))
      .then(() => this.loadHistory())
      .catch((error: Error) => {
        console.error(`HistoryPage: failed to persist display config: ${JSON.stringify(error)}`)
      })
  }

  private persistHistoryChange(operation: () => Promise<void>, message: string): void {
    this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      .then(operation)
      .catch((error: Error) => {
        console.error(`HistoryPage: failed to persist history: ${JSON.stringify(error)}`)
        this.loadHistory()
        UiContextHelper.showToast(this.getUIContext(), message)
      })
  }

  private async useRecord(record: HistoryRecord): Promise<void> {
    const config: BannerConfig = {
      id: record.config.id,
      text: record.config.text,
      textColor: Utils.ensureTextContrast(record.config.textColor, record.config.backgroundColor),
      backgroundColor: record.config.backgroundColor,
      fontSize: record.config.fontSize,
      displayMode: record.config.displayMode,
      scrollDirection: record.config.scrollDirection,
      speedLevel: record.config.speedLevel,
      ledStyle: record.config.ledStyle,
      isMirrored: record.config.isMirrored,
      showBorder: record.config.showBorder,
      borderColor: record.config.borderColor,
      isLandscape: record.config.isLandscape,
      createdAt: record.config.createdAt
    }
    try {
      await UiContextHelper.pushUrl(this.getUIContext(), 'pages/DisplayPage',
        new DisplayRouteParams(JSON.stringify(config)))
      this.persistDisplayConfig(config)
    } catch (error) {
      console.error(`HistoryPage: failed to use history record: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '历史记录打开失败，请重试')
    }
  }

  private async deleteRecord(id: string): Promise<void> {
    try {
      const result = await this.getUIContext().getPromptAction().showDialog({
        title: '确认删除',
        message: '确定要删除这条历史记录吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '删除', color: AppTheme.DANGER }
        ]
      })
      if (result.index === 1) {
        this.records = this.records.filter((record: HistoryRecord) => record.id !== id)
        this.persistHistoryChange(() => this.storageService.deleteHistory(id), '历史记录删除失败，请重试')
      }
    } catch (error) {
      console.error(`HistoryPage: failed to confirm delete: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '删除失败，请重试')
    }
  }

  private async clearAll(): Promise<void> {
    try {
      const result = await this.getUIContext().getPromptAction().showDialog({
        title: '确认清空',
        message: '确定要清空所有历史记录吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '清空', color: AppTheme.DANGER }
        ]
      })
      if (result.index === 1) {
        this.records = []
        this.persistHistoryChange(() => this.storageService.clearHistory(), '历史记录清空失败，请重试')
      }
    } catch (error) {
      console.error(`HistoryPage: failed to clear history: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '历史记录清空失败，请重试')
    }
  }
}
