import { Template, TemplateCategory } from '../models/Template'
import { BannerConfig, DEFAULT_CONFIG, SpeedLevel, DisplayRouteParams } from '../models/BannerConfig'
import { TemplateService } from '../services/TemplateService'
import { StorageService } from '../services/StorageService'
import { Utils } from '../common/Utils'
import { Constants } from '../common/Constants'
import { AppTheme } from '../common/Theme'
import { LedPanel } from '../components/LedPanel'
import { UiContextHelper } from '../common/UiContextHelper'

@Entry
@Component
struct TemplatePage {
  @State categories: string[] = []
  @State selectedCategory: string = TemplateCategory.CHEER
  @State templates: Template[] = []
  @State showEditDialog: boolean = false
  @State editText: string = ''
  @State editFontSize: number = 80
  @State editSpeedLevel: number = 3
  @State editTemplate: Template | null = null
  @State columnTemplate: string = '1fr 1fr'
  @State isStarting: boolean = false
  private templateService: TemplateService = TemplateService.getInstance()
  private storageService: StorageService = StorageService.getInstance()

  aboutToAppear(): void {
    this.categories = this.templateService.getCategories()
    this.selectedCategory = TemplateCategory.CHEER
    this.loadTemplates()
  }

  private loadTemplates(): void {
    this.templates = this.templateService.getTemplatesByCategory(this.selectedCategory)
  }

  build() {
    Stack() {
      Column() {
        this.buildHeader()
        this.buildCategoryTabs()
        this.buildTemplateGrid()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppTheme.PAGE_BG)

      if (this.showEditDialog) this.buildEditDialog()
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      const width = Number(newValue.width)
      if (width > 840) this.columnTemplate = '1fr 1fr 1fr 1fr'
      else if (width > 600) this.columnTemplate = '1fr 1fr 1fr'
      else this.columnTemplate = '1fr 1fr'
    })
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
      Text('场景模板')
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
  buildCategoryTabs() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .height(34)
            .fontSize(AppTheme.uiFontSize(14))
            .fontColor(this.selectedCategory === category ? AppTheme.ON_ACCENT : AppTheme.TEXT_SECONDARY)
            .fontWeight(AppTheme.UI_FONT_WEIGHT)
            .padding({ left: 17, right: 17 })
            .margin({ right: AppTheme.CARD_GAP })
            .backgroundColor(this.selectedCategory === category ? '#05BDEB' : AppTheme.SURFACE_SOFT)
            .borderRadius(18)
            .border({ width: 1, color: this.selectedCategory === category ? AppTheme.ACCENT : '#1B2D46' })
            .shadow({ radius: this.selectedCategory === category ? 10 : 0, color: '#006F99' })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.selectedCategory = category
              this.loadTemplates()
            })
        })
      }
      .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height(54)
  }

  @Builder
  buildTemplateGrid() {
    Grid() {
      ForEach(this.templates, (item: Template, index: number) => {
        GridItem() { this.buildTemplateCard(item, index) }
      }, (item: Template) => item.id)
    }
    .columnsTemplate(this.columnTemplate)
    .columnsGap(AppTheme.CARD_GAP)
    .rowsGap(AppTheme.CARD_GAP)
    .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, top: AppTheme.CARD_GAP, bottom: 16 })
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  buildTemplateCard(item: Template, index: number) {
    Column() {
      LedPanel({
        text: item.text,
        color: item.textColor === '#RAINBOW' ? AppTheme.ACCENT : item.textColor,
        panelHeight: 82,
        fontSize: item.text.length > 8 ? 19 : 25,
        radius: 8
      })
      Text(item.name)
        .width('100%')
        .fontSize(AppTheme.uiFontSize(14))
        .fontColor(AppTheme.TEXT_PRIMARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .margin({ top: 9 })
        .maxLines(1)
      Text('点击编辑并开始展示')
        .width('100%')
        .fontSize(AppTheme.uiFontSize(12))
        .fontColor(AppTheme.TEXT_SECONDARY)
        .fontWeight(AppTheme.UI_FONT_WEIGHT)
        .margin({ top: 5 })
    }
    .width('100%')
    .padding(7)
    .backgroundColor(AppTheme.SURFACE_RAISED)
    .borderRadius(10)
    .border({ width: 1, color: '#0878B5' })
    .shadow({ radius: 8, color: '#002F4D' })
    .onClick(() => this.openEditDialog(item))
  }

  @Builder
  buildEditDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000814CC')
        .onClick(() => this.showEditDialog = false)
      Column() {
        Text('使用模板')
          .fontSize(AppTheme.uiFontSize(19))
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .margin({ bottom: 14 })
        TextArea({ text: this.editText, placeholder: '请输入文字...' })
          .width('100%')
          .height(76)
          .fontSize(AppTheme.uiFontSize(16))
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
          .backgroundColor(AppTheme.SURFACE_SOFT)
          .borderRadius(9)
          .maxLength(Constants.MAX_TEXT_LENGTH)
          .onChange((value: string) => this.editText = value)
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .fontWeight(AppTheme.UI_FONT_WEIGHT)
            .backgroundColor(AppTheme.SURFACE_SOFT)
            .borderRadius(10)
            .margin({ right: 6 })
            .onClick(() => this.showEditDialog = false)
          Button('开始显示')
            .layoutWeight(1)
            .height(44)
            .fontColor(AppTheme.ON_ACCENT)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(AppTheme.ACCENT_BLUE)
            .borderRadius(10)
            .margin({ left: 6 })
            .enabled(!this.isStarting)
            .opacity(this.isStarting ? 0.6 : 1)
            .onClick(() => this.confirmTemplate())
        }
        .width('100%')
        .margin({ top: 18 })
      }
      .width('84%')
      .padding(20)
      .backgroundColor(AppTheme.SURFACE_RAISED)
      .borderRadius(14)
      .border({ width: 1, color: AppTheme.BORDER_BRIGHT })
    }
    .width('100%')
    .height('100%')
  }

  private openEditDialog(template: Template): void {
    this.editTemplate = template
    this.editText = template.text
    this.editFontSize = template.fontSize
    this.editSpeedLevel = template.speedLevel
    this.showEditDialog = true
  }

  private persistDisplayConfig(config: BannerConfig): void {
    this.storageService.init(UiContextHelper.requireHostContext(this.getUIContext()))
      .then(() => this.storageService.saveDisplayConfig(config))
      .catch((error: Error) => {
        console.error(`TemplatePage: failed to persist display config: ${JSON.stringify(error)}`)
      })
  }

  private async confirmTemplate(): Promise<void> {
    if (!this.editTemplate) return
    if (!this.editText.trim()) {
      UiContextHelper.showToast(this.getUIContext(), '请输入要显示的文字')
      return
    }
    if (this.isStarting) return
    this.isStarting = true
    const config: BannerConfig = {
      id: Utils.generateId(), text: this.editText,
      textColor: Utils.ensureTextContrast(this.editTemplate.textColor, this.editTemplate.backgroundColor),
      backgroundColor: this.editTemplate.backgroundColor, fontSize: this.editFontSize,
      displayMode: this.editTemplate.displayMode, scrollDirection: this.editTemplate.scrollDirection,
      speedLevel: this.editSpeedLevel as SpeedLevel, ledStyle: DEFAULT_CONFIG.ledStyle,
      isMirrored: DEFAULT_CONFIG.isMirrored, showBorder: DEFAULT_CONFIG.showBorder,
      borderColor: DEFAULT_CONFIG.borderColor, isLandscape: DEFAULT_CONFIG.isLandscape,
      createdAt: Date.now()
    }
    try {
      this.showEditDialog = false
      await UiContextHelper.pushUrl(this.getUIContext(), 'pages/DisplayPage',
        new DisplayRouteParams(JSON.stringify(config)))
      this.persistDisplayConfig(config)
    } catch (error) {
      console.error(`TemplatePage: failed to start template: ${JSON.stringify(error)}`)
      UiContextHelper.showToast(this.getUIContext(), '模板启动失败，请重试')
    } finally {
      this.isStarting = false
    }
  }
}
