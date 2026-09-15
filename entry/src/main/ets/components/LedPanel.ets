import { AppTheme } from '../common/Theme'
import { Utils } from '../common/Utils'

@Component
export struct LedPanel {
  @Prop text: string = ''
  @Prop color: string = AppTheme.ACCENT
  @Prop panelHeight: number = 88
  @Prop fontSize: number = 30
  @Prop radius: number = AppTheme.PANEL_RADIUS
  @Prop showGlow: boolean = true

  // Keep the helper as the component's visual token seam for existing UI contracts.
  private dotColor(): string {
    return AppTheme.LED_MATRIX_DOT_COLOR
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text('· · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·\n' +
        '· · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·\n' +
        ' · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·')
        .width('100%')
        .height('100%')
        .fontSize(AppTheme.LED_MATRIX_DOT_FONT_SIZE)
        .lineHeight(10)
        .fontColor(AppTheme.LED_MATRIX_DOT_COLOR)
        .opacity(AppTheme.LED_MATRIX_DOT_OPACITY)
        .textAlign(TextAlign.Center)
        .maxLines(8)
        .padding({ left: 4, right: 4 })

      Text(this.text)
        .fontSize(this.fontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(Utils.ensureTextContrast(this.color, '#01060C'))
        .fontFamily('monospace')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .textShadow({
          radius: this.showGlow ? 14 : 0,
          color: this.showGlow ? this.color : '#00000000',
          offsetX: 0,
          offsetY: 0
        })
        .padding({ left: 10, right: 10 })
    }
    .width('100%')
    .height(this.panelHeight)
    .backgroundColor('#01060C')
    .borderRadius(this.radius)
    .border({ width: 1, color: AppTheme.BORDER_BRIGHT })
    .shadow({ radius: this.showGlow ? 12 : 0, color: '#003E5E', offsetX: 0, offsetY: 0 })
    .clip(true)
  }
}
