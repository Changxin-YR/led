import { AppTheme } from '../common/Theme'

@Component
export struct LedPanel {
  @Prop text: string = ''
  @Prop color: string = AppTheme.ACCENT
  @Prop panelHeight: number = 88
  @Prop fontSize: number = 30
  @Prop radius: number = AppTheme.PANEL_RADIUS
  @Prop showGlow: boolean = true

  private dotColor(): string {
    return this.color === '#000000' ? '#52647A' : this.color
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
        .fontSize(8)
        .lineHeight(10)
        .fontColor(this.dotColor())
        .opacity(0.25)
        .textAlign(TextAlign.Center)
        .maxLines(8)
        .padding({ left: 4, right: 4 })

      Text(this.text)
        .fontSize(this.fontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
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
