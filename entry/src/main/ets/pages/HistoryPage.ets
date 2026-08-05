import { router, promptAction } from '@kit.ArkUI'
import { HistoryRecord } from '../models/HistoryRecord'
import { DisplayRouteParams } from '../models/BannerConfig'
import { StorageService } from '../services/StorageService'
import { Utils } from '../common/Utils'
import { AppTheme } from '../common/Theme'
import { LedPanel } from '../components/LedPanel'

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
    await this.storageService.init(getContext(this))
    this.records = await this.storageService.getHistory()
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
        .width(36)
        .height(48)
        .textAlign(TextAlign.Center)
        .onClick(() => router.back())
      Text('历史记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ left: 6 })
      Blank()
      Text('清空')
        .fontSize(15)
        .fontColor(AppTheme.DANGER)
        .padding({ left: 12, right: 2, top: 10, bottom: 10 })
        .opacity(this.records.length > 0 ? 1 : 0.45)
        .onClick(() => {
          if (this.records.length > 0) this.clearAll()
        })
    }
    .width('100%')
    .height(62)
    .padding({ left: 12, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      LedPanel({ text: '—', color: AppTheme.ACCENT, panelHeight: 120, fontSize: 42, radius: 12 })
      Text('暂无历史记录')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ top: 22 })
      Text('开始显示字幕后，记录会保存在这里')
        .fontSize(13)
        .fontColor(AppTheme.TEXT_MUTED)
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
    List({ space: 11 }) {
      ForEach(this.records, (item: HistoryRecord) => {
        ListItem() { this.buildHistoryCard(item) }
      }, (item: HistoryRecord) => item.id)
    }
    .width('100%')
    .constraintSize({ maxWidth: 720 })
    .alignSelf(ItemAlign.Center)
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 5, bottom: 16 })
    .scrollBar(BarState.Off)
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
            .fontSize(12)
            .fontColor(AppTheme.TEXT_SECONDARY)
          Text('  |  ')
            .fontSize(12)
            .fontColor(AppTheme.TEXT_MUTED)
          Text(`使用${item.useCount}次`)
            .fontSize(12)
            .fontColor(AppTheme.TEXT_SECONDARY)
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

  private async useRecord(record: HistoryRecord): Promise<void> {
    await this.storageService.saveLastConfig(record.config)
    router.pushUrl({ url: 'pages/DisplayPage', params: new DisplayRouteParams(JSON.stringify(record.config)) })
  }

  private async deleteRecord(id: string): Promise<void> {
    await this.storageService.deleteHistory(id)
    this.loadHistory()
  }

  private async clearAll(): Promise<void> {
    promptAction.showDialog({
      title: '确认清空',
      message: '确定要清空所有历史记录吗？',
      buttons: [
        { text: '取消', color: AppTheme.TEXT_SECONDARY },
        { text: '清空', color: AppTheme.DANGER }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        await this.storageService.clearHistory()
        this.loadHistory()
      }
    })
  }
}
