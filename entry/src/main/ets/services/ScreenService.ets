import { window } from '@kit.ArkUI'

export class ScreenService {
  private win: window.Window | null = null
  private static instance: ScreenService | null = null

  static getInstance(): ScreenService {
    if (!ScreenService.instance) {
      ScreenService.instance = new ScreenService()
    }
    return ScreenService.instance
  }

  async init(windowInstance: window.Window): Promise<void> {
    this.win = windowInstance
  }

  async enterFullScreen(): Promise<void> {
    if (!this.win) return
    await this.win.setWindowLayoutFullScreen(true)
    await this.win.setWindowSystemBarEnable([])
  }

  async exitFullScreen(): Promise<void> {
    if (!this.win) return
    await this.win.setWindowLayoutFullScreen(false)
    await this.win.setWindowSystemBarEnable(['status', 'navigation'])
  }

  async setKeepScreenOn(keepOn: boolean): Promise<void> {
    if (!this.win) return
    await this.win.setWindowKeepScreenOn(keepOn)
  }

  async setMaxBrightness(): Promise<void> {
    if (!this.win) return
    await this.win.setWindowBrightness(1.0)
  }

  async restoreBrightness(): Promise<void> {
    if (!this.win) return
    await this.win.setWindowBrightness(-1)
  }

  async setLandscape(landscape: boolean): Promise<void> {
    if (!this.win) return
    if (landscape) {
      await this.win.setPreferredOrientation(window.Orientation.LANDSCAPE)
    } else {
      await this.win.setPreferredOrientation(window.Orientation.PORTRAIT)
    }
  }
}
