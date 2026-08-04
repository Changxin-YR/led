import { router } from '@kit.ArkUI'
import { window } from '@kit.ArkUI'
import { display } from '@kit.ArkUI'
import { BannerConfig, DisplayMode, ScrollDirection } from '../models/BannerConfig'
import { ScreenService } from '../services/ScreenService'
import { AnimationService } from '../services/AnimationService'
import { Constants } from '../common/Constants'

@Entry
@Component
struct DisplayPage {
  @State config: BannerConfig | null = null
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State textOpacity: number = 1.0
  @State currentLineIndex: number = 0
  @State neonColorIndex: number = 0
  @State screenWidth: number = 360
  @State screenHeight: number = 780
  @State isPaused: boolean = false
  @State showExitBtn: boolean = false
  @State showGuide: boolean = false
  @State barrageOffsets: number[] = [0, 0, 0, 0, 0]
  private screenService: ScreenService = ScreenService.getInstance()
  private animationService: AnimationService = AnimationService.getInstance()
  private scrollTimer: number = -1
  private blinkTimer: number = -1
  private flipTimer: number = -1
  private neonTimer: number = -1
  private barrageTimers: number[] = []
  private barrageDelayTimers: number[] = []
  private hideExitTimer: number = -1
  private breathTimer: number = -1
  private flipInnerTimer: number = -1
  private estimatedTextWidth: number = 0
  private tapCount: number = 0
  private tapTimer: number = -1

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params && params['config']) {
      this.config = JSON.parse(params['config']) as BannerConfig
    }
    this.initScreen()
  }

  async initScreen(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this))
      await this.screenService.init(win)
      await this.screenService.enterFullScreen()
      await this.screenService.setKeepScreenOn(true)
      await this.screenService.setMaxBrightness()

      if (this.config?.isLandscape) {
        await this.screenService.setLandscape(true)
      }

      const displayInfo = display.getDefaultDisplaySync()
      this.screenWidth = px2vp(displayInfo.width)
      this.screenHeight = px2vp(displayInfo.height)

      this.calculateTextWidth()
      this.startAnimation()
      this.showGuideOnFirstUse()
    } catch (e) {
      this.screenWidth = 360
      this.screenHeight = 780
      this.calculateTextWidth()
      this.startAnimation()
      this.showGuideOnFirstUse()
    }
  }

  aboutToDisappear(): void {
    this.cleanup()
  }

  private calculateTextWidth(): void {
    if (!this.config) return
    const charCount = this.config.text.length
    this.estimatedTextWidth = charCount * this.config.fontSize * 0.7
  }

  private showGuideOnFirstUse(): void {
    const hasSeenGuide = AppStorage.get<boolean>('hasSeenDisplayGuide')
    if (hasSeenGuide) return
    this.showGuide = true
    AppStorage.setOrCreate<boolean>('hasSeenDisplayGuide', true)
    setTimeout(() => {
      this.showGuide = false
    }, 3000)
  }

  private async cleanup(): Promise<void> {
    this.clearAllTimers()
    await this.screenService.exitFullScreen()
    await this.screenService.setKeepScreenOn(false)
    await this.screenService.restoreBrightness()
    if (this.config?.isLandscape) {
      await this.screenService.setLandscape(false)
    }
  }

  private clearAllTimers(): void {
    if (this.scrollTimer >= 0) { clearInterval(this.scrollTimer); this.scrollTimer = -1 }
    if (this.blinkTimer >= 0) { clearInterval(this.blinkTimer); this.blinkTimer = -1 }
    if (this.flipTimer >= 0) { clearInterval(this.flipTimer); this.flipTimer = -1 }
    if (this.neonTimer >= 0) { clearInterval(this.neonTimer); this.neonTimer = -1 }
    if (this.breathTimer >= 0) { clearInterval(this.breathTimer); this.breathTimer = -1 }
    if (this.flipInnerTimer >= 0) { clearTimeout(this.flipInnerTimer); this.flipInnerTimer = -1 }
    if (this.hideExitTimer >= 0) { clearTimeout(this.hideExitTimer); this.hideExitTimer = -1 }
    if (this.tapTimer >= 0) { clearTimeout(this.tapTimer); this.tapTimer = -1 }
    for (const t of this.barrageTimers) {
      if (t >= 0) clearInterval(t)
    }
    this.barrageTimers = []
    for (const t of this.barrageDelayTimers) {
      if (t >= 0) clearTimeout(t)
    }
    this.barrageDelayTimers = []
  }

  private handleTap(): void {
    this.tapCount++
    if (this.tapCount === 1) {
      this.tapTimer = setTimeout(() => {
        if (this.tapCount === 1) {
          this.onSingleTap()
        }
        this.tapCount = 0
      }, 300)
    } else if (this.tapCount === 2) {
      if (this.tapTimer >= 0) { clearTimeout(this.tapTimer); this.tapTimer = -1 }
      this.tapCount = 0
      this.onDoubleTap()
    }
  }

  private onSingleTap(): void {
    this.showExitBtn = true
    if (this.hideExitTimer >= 0) clearTimeout(this.hideExitTimer)
    this.hideExitTimer = setTimeout(() => {
      this.showExitBtn = false
    }, 3000)
  }

  private onDoubleTap(): void {
    this.isPaused = !this.isPaused
    if (this.isPaused) {
      this.pauseAnimation()
    } else {
      this.resumeAnimation()
    }
  }

  private pauseAnimation(): void {
    if (this.scrollTimer >= 0) { clearInterval(this.scrollTimer); this.scrollTimer = -1 }
    if (this.blinkTimer >= 0) { clearInterval(this.blinkTimer); this.blinkTimer = -1 }
    if (this.flipTimer >= 0) { clearInterval(this.flipTimer); this.flipTimer = -1 }
    if (this.neonTimer >= 0) { clearInterval(this.neonTimer); this.neonTimer = -1 }
    if (this.breathTimer >= 0) { clearInterval(this.breathTimer); this.breathTimer = -1 }
    if (this.flipInnerTimer >= 0) { clearTimeout(this.flipInnerTimer); this.flipInnerTimer = -1 }
    for (const t of this.barrageTimers) {
      if (t >= 0) clearInterval(t)
    }
    this.barrageTimers = []
    for (const t of this.barrageDelayTimers) {
      if (t >= 0) clearTimeout(t)
    }
    this.barrageDelayTimers = []
    this.textOpacity = 1.0
  }

  private resumeAnimation(): void {
    this.startAnimation()
  }

  private startAnimation(): void {
    if (!this.config) return
    switch (this.config.displayMode) {
      case DisplayMode.SCROLL_HORIZONTAL:
        this.startScrollH()
        break
      case DisplayMode.SCROLL_VERTICAL:
        this.startScrollV()
        break
      case DisplayMode.BLINK:
        this.startBlink()
        break
      case DisplayMode.BREATH:
        this.startBreath()
        break
      case DisplayMode.FLIP:
        this.startFlip()
        break
      case DisplayMode.NEON:
        this.startNeon()
        break
      case DisplayMode.BARRAGE:
        this.startBarrage()
        break
      default:
        break
    }
  }

  private startScrollH(): void {
    if (!this.config) return
    const duration = this.animationService.getScrollDuration(this.config.speedLevel)
    const isRtl = this.config.scrollDirection !== ScrollDirection.LEFT_TO_RIGHT
    const startPos = isRtl ? this.screenWidth : -this.estimatedTextWidth
    const endPos = isRtl ? -this.estimatedTextWidth : this.screenWidth
    const steps = Math.max(duration / 16, 1)
    const increment = (endPos - startPos) / steps

    this.offsetX = startPos
    this.scrollTimer = setInterval(() => {
      this.offsetX += increment
      if (isRtl && this.offsetX <= endPos) {
        this.offsetX = startPos
      } else if (!isRtl && this.offsetX >= endPos) {
        this.offsetX = startPos
      }
    }, 16)
  }

  private startScrollV(): void {
    if (!this.config) return
    const duration = this.animationService.getScrollDuration(this.config.speedLevel)
    const textHeight = this.config.fontSize * 1.2
    const startPos = this.screenHeight
    const endPos = -textHeight
    const steps = Math.max(duration / 16, 1)
    const increment = (endPos - startPos) / steps

    this.offsetY = startPos
    this.scrollTimer = setInterval(() => {
      this.offsetY += increment
      if (this.offsetY <= endPos) {
        this.offsetY = startPos
      }
    }, 16)
  }

  private startBlink(): void {
    if (!this.config) return
    const interval = this.animationService.getBlinkInterval(this.config.speedLevel)
    this.blinkTimer = setInterval(() => {
      this.textOpacity = this.textOpacity === 1.0 ? 0.0 : 1.0
    }, interval)
  }

  private startBreath(): void {
    if (!this.config) return
    const duration = this.animationService.getBreathDuration(this.config.speedLevel)
    const halfDuration = duration / 2
    const steps = halfDuration / 16
    let breathingIn = false
    let step = 0

    this.textOpacity = 1.0
    this.breathTimer = setInterval(() => {
      step++
      if (!breathingIn) {
        this.textOpacity = 1.0 - (step / steps) * 0.8
        if (step >= steps) {
          step = 0
          breathingIn = true
        }
      } else {
        this.textOpacity = 0.2 + (step / steps) * 0.8
        if (step >= steps) {
          step = 0
          breathingIn = false
        }
      }
    }, 16)
  }

  private startFlip(): void {
    if (!this.config) return
    const interval = this.animationService.getFlipInterval(this.config.speedLevel)
    const lines = this.config.text.split('\n')
    if (lines.length <= 1) return
    this.flipTimer = setInterval(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.textOpacity = 0
      })
      this.flipInnerTimer = setTimeout(() => {
        this.currentLineIndex = (this.currentLineIndex + 1) % lines.length
        animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
          this.textOpacity = 1
        })
      }, 300)
    }, interval)
  }

  private startNeon(): void {
    if (!this.config) return
    const duration = this.animationService.getNeonCycleDuration(this.config.speedLevel)
    const interval = duration / Constants.NEON_COLORS.length
    this.neonTimer = setInterval(() => {
      this.neonColorIndex = (this.neonColorIndex + 1) % Constants.NEON_COLORS.length
    }, interval)
  }

  private startBarrage(): void {
    if (!this.config) return
    const baseDuration = this.animationService.getBarrageSpeed(this.config.speedLevel)
    const rows = Constants.BARRAGE_ROWS

    for (let i = 0; i < rows; i++) {
      const speedFactor = 0.7 + (i % 3) * 0.3
      const duration = baseDuration * speedFactor
      const steps = Math.max(duration / 16, 1)
      const totalDistance = this.screenWidth + this.estimatedTextWidth
      const increment = totalDistance / steps
      const delay = i * (baseDuration / rows / 2)

      const delayTimer = setTimeout(() => {
        this.barrageOffsets[i] = this.screenWidth
        const timer = setInterval(() => {
          const newOffsets = [...this.barrageOffsets]
          newOffsets[i] -= increment
          if (newOffsets[i] < -this.estimatedTextWidth) {
            newOffsets[i] = this.screenWidth
          }
          this.barrageOffsets = newOffsets
        }, 16)
        this.barrageTimers.push(timer)
      }, delay)
      this.barrageDelayTimers.push(delayTimer)
    }
  }

  private getDisplayText(): string {
    if (!this.config) return ''
    if (this.config.displayMode === DisplayMode.FLIP) {
      const lines = this.config.text.split('\n')
      return lines[this.currentLineIndex] || this.config.text
    }
    return this.config.text
  }

  private getTextColor(): string {
    if (!this.config) return '#00FF00'
    if (this.config.displayMode === DisplayMode.NEON || this.config.textColor === '#RAINBOW') {
      return Constants.NEON_COLORS[this.neonColorIndex]
    }
    return this.config.textColor
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.config?.backgroundColor || '#000000')

      if (this.config) {
        if (this.config.displayMode === DisplayMode.BARRAGE) {
          this.buildBarrage()
        } else {
          this.buildMainText()
        }
      }

      if (this.config?.showBorder) {
        Column()
          .width('100%')
          .height('100%')
          .border({
            width: 4,
            color: this.config.borderColor || '#00FF00',
            style: BorderStyle.Solid
          })
          .hitTestBehavior(HitTestMode.Transparent)
      }

      if (this.isPaused) {
        Text('已暂停')
          .fontSize(14)
          .fontColor('#FFFFFF80')
          .position({ x: '42%', y: '5%' })
      }

      if (this.showGuide) {
        Column() {
          Text('单击：显示退出按钮')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .margin({ bottom: 8 })
          Text('双击：暂停/继续动画')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#00000090')
        .position({ x: 0, y: '80%' })
        .alignItems(HorizontalAlign.Center)
      }

      if (this.showExitBtn) {
        Column() {
          Text('×')
            .fontSize(36)
            .fontColor('#FFFFFF')
            .backgroundColor('#00000060')
            .borderRadius(20)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
        }
        .position({ x: '88%', y: '3%' })
        .onClick(() => {
          router.back()
        })
      }
    }
    .width('100%')
    .height('100%')
    .gesture(
      TapGesture({ count: 1 })
        .onAction(() => {
          this.handleTap()
        })
    )
  }

  @Builder
  buildMainText() {
    Column() {
      Text(this.getDisplayText())
        .fontSize(this.config!.fontSize)
        .fontColor(this.getTextColor())
        .fontWeight(FontWeight.Bold)
        .opacity(this.textOpacity)
        .translate({ x: this.offsetX, y: this.offsetY })
        .scale({
          x: this.config!.isMirrored ? -1 : 1,
          y: 1
        })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildBarrage() {
    Stack() {
      ForEach(this.getBarrageRows(), (item: BarrageRow) => {
        Text(this.config!.text)
          .fontSize(this.config!.fontSize * 0.55)
          .fontColor(this.getTextColor())
          .fontWeight(FontWeight.Bold)
          .opacity(0.9)
          .position({ x: this.barrageOffsets[item.index], y: item.yPosition })
      })
    }
    .width('100%')
    .height('100%')
  }

  private getBarrageRows(): BarrageRow[] {
    const items: BarrageRow[] = []
    const rowHeight = this.screenHeight / (Constants.BARRAGE_ROWS + 1)
    for (let i = 0; i < Constants.BARRAGE_ROWS; i++) {
      items.push({
        index: i,
        yPosition: rowHeight * (i + 0.5)
      })
    }
    return items
  }
}

interface BarrageRow {
  index: number
  yPosition: number
}
