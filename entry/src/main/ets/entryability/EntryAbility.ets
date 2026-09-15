import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { ScreenService } from '../services/ScreenService'

export default class EntryAbility extends UIAbility {
  private screenService: ScreenService = ScreenService.getInstance()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onCreate')
  }

  onDestroy(): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onWindowStageCreate')
    const appChromeReady: Promise<void> = this.configureAppChrome(windowStage)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'LEDBanner', 'Failed to load content: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(0x0000, 'LEDBanner', 'Content loaded successfully')
      appChromeReady.then(() => this.screenService.applyAppChrome()).catch((error: Error) => {
        hilog.warn(0x0000, 'LEDBanner', 'Failed to reapply app chrome after content load: %{public}s',
          JSON.stringify(error))
      })
    })
  }

  private configureAppChrome(windowStage: window.WindowStage): Promise<void> {
    return windowStage.getMainWindow().then(async (windowInstance: window.Window) => {
      await this.screenService.init(windowInstance)
      await this.screenService.applyAppChrome()
    }).catch((error: Error) => {
      hilog.warn(0x0000, 'LEDBanner', 'Failed to configure app chrome: %{public}s', JSON.stringify(error))
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onBackground')
  }
}
