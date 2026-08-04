import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onCreate')
  }

  onDestroy(): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'LEDBanner', 'Ability onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'LEDBanner', 'Failed to load content: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(0x0000, 'LEDBanner', 'Content loaded successfully')
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
