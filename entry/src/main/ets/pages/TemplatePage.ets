import { router } from '@kit.ArkUI'
import { Template, TemplateCategory } from '../models/Template'
import { BannerConfig, DEFAULT_CONFIG, SpeedLevel, DisplayRouteParams } from '../models/BannerConfig'
import { TemplateService } from '../services/TemplateService'
import { Utils } from '../common/Utils'
import { Constants } from '../common/Constants'
import { AppTheme } from '../common/Theme'
import { LedPanel } from '../components/LedPanel'

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
  private templateService: TemplateService = TemplateService.getInstance()

  aboutToAppear(): void {
    this.categories = this.templateService.getCategories()
    this.selectedCategory = TemplateCategory.CHEER
    this.loadTemplates()
  }

  private loadTemplates(): void {
    this.templates = this.selectedCategory === TemplateCategory.CHEER ?
      this.templateService.getAllTemplates().slice(0, 8) :
      this.templateService.getTemplatesByCategory(this.selectedCategory)
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
        .width(36)
        .height(48)
        .textAlign(TextAlign.Center)
        .onClick(() => router.back())
      Text('场景模板')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ left: 6 })
      Blank()
    }
    .width('100%')
    .height(62)
    .padding({ left: 12, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildCategoryTabs() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .height(34)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : AppTheme.TEXT_SECONDARY)
            .padding({ left: 17, right: 17 })
            .margin({ right: 9 })
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
        Text('•••')
          .width(42)
          .height(34)
          .fontSize(14)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .backgroundColor(AppTheme.SURFACE_SOFT)
          .borderRadius(18)
          .textAlign(TextAlign.Center)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(48)
  }

  @Builder
  buildTemplateGrid() {
    Grid() {
      ForEach(this.templates, (item: Template, index: number) => {
        GridItem() { this.buildTemplateCard(item, index) }
      }, (item: Template) => item.id)
    }
    .columnsTemplate(this.columnTemplate)
    .columnsGap(12)
    .rowsGap(14)
    .padding({ left: 16, right: 16, top: 10, bottom: 16 })
    .layoutWeight(1)
    .scrollBar(BarState.Off)
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
        .fontSize(14)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ top: 9 })
        .maxLines(1)
      Text(`${this.getUseCount(index)} 万次使用`)
        .width('100%')
        .fontSize(12)
        .fontColor(AppTheme.TEXT_SECONDARY)
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

  private getUseCount(index: number): string {
    const values: string[] = ['12.3', '18.7', '15.6', '21.4', '9.8', '11.2', '7.5', '13.9']
    return values[index % values.length]
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
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .margin({ bottom: 14 })
        TextArea({ text: this.editText, placeholder: '请输入文字...' })
          .width('100%')
          .height(76)
          .fontSize(16)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .backgroundColor(AppTheme.SURFACE_SOFT)
          .borderRadius(9)
          .maxLength(Constants.MAX_TEXT_LENGTH)
          .onChange((value: string) => this.editText = value)
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .backgroundColor(AppTheme.SURFACE_SOFT)
            .borderRadius(10)
            .margin({ right: 6 })
            .onClick(() => this.showEditDialog = false)
          Button('开始显示')
            .layoutWeight(1)
            .height(44)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor(AppTheme.ACCENT_BLUE)
            .borderRadius(10)
            .margin({ left: 6 })
            .onClick(() => {
              this.showEditDialog = false
              this.confirmTemplate()
            })
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

  private confirmTemplate(): void {
    if (!this.editTemplate || !this.editText.trim()) return
    const config: BannerConfig = {
      id: Utils.generateId(), text: this.editText, textColor: this.editTemplate.textColor,
      backgroundColor: this.editTemplate.backgroundColor, fontSize: this.editFontSize,
      displayMode: this.editTemplate.displayMode, scrollDirection: this.editTemplate.scrollDirection,
      speedLevel: this.editSpeedLevel as SpeedLevel, ledStyle: DEFAULT_CONFIG.ledStyle,
      isMirrored: DEFAULT_CONFIG.isMirrored, showBorder: DEFAULT_CONFIG.showBorder,
      borderColor: DEFAULT_CONFIG.borderColor, isLandscape: DEFAULT_CONFIG.isLandscape,
      createdAt: Date.now()
    }
    router.pushUrl({ url: 'pages/DisplayPage', params: new DisplayRouteParams(JSON.stringify(config)) })
  }
}
