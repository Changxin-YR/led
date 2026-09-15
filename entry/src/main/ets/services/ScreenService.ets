import { window } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppTheme } from '../common/Theme'

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

  async applyAppChrome(): Promise<void> {
    const currentWindow = this.win
    if (!currentWindow) return

    await this.runWindowOperation('restore automatic orientation', () =>
      currentWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED))
    await this.runWindowOperation('apply window background color', async () => {
      currentWindow.setWindowBackgroundColor(AppTheme.PAGE_BG)
    })
    await this.runWindowOperation('restore standard window layout', () =>
      currentWindow.setWindowLayoutFullScreen(false))
    await this.runWindowOperation('show system bars', () => currentWindow.setWindowSystemBarEnable(['status', 'navigation']))
    await this.runWindowOperation('apply system bar colors', () => currentWindow.setWindowSystemBarProperties({
      statusBarColor: AppTheme.PAGE_BG,
      navigationBarColor: AppTheme.SYSTEM_NAVIGATION_BAR,
      statusBarContentColor: AppTheme.TEXT_PRIMARY,
      navigationBarContentColor: AppTheme.TEXT_PRIMARY,
      isStatusBarLightIcon: true,
      isNavigationBarLightIcon: true
    }))
  }

  async enterDisplayMode(landscape: boolean): Promise<void> {
    const currentWindow = this.win
    if (!currentWindow) return

    const orientation = landscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT
    await this.runWindowOperation('set display orientation', () => currentWindow.setPreferredOrientation(orientation))
    await this.runWindowOperation('enable display fullscreen', () => currentWindow.setWindowLayoutFullScreen(true))
    await this.runWindowOperation('hide system bars', () => currentWindow.setWindowSystemBarEnable([]))
    await this.runWindowOperation('keep screen on', () => currentWindow.setWindowKeepScreenOn(true))
    await this.runWindowOperation('set display brightness', () => currentWindow.setWindowBrightness(1.0))
  }

  async exitDisplayMode(): Promise<void> {
    const currentWindow = this.win
    if (!currentWindow) return

    await this.runWindowOperation('restore automatic orientation', () =>
      currentWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED))
    await this.applyAppChrome()
    await this.runWindowOperation('restore screen timeout', () => currentWindow.setWindowKeepScreenOn(false))
    await this.runWindowOperation('restore automatic brightness', () => currentWindow.setWindowBrightness(-1))
  }

  private async runWindowOperation(name: string, operation: () => Promise<void>): Promise<void> {
    try {
      await operation()
    } catch (error) {
      hilog.warn(0x0000, 'LEDBanner', 'Window operation %{public}s failed: %{public}s', name, JSON.stringify(error))
    }
  }
}
