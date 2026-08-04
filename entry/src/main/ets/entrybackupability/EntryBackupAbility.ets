import { hilog } from '@kit.PerformanceAnalysisKit'
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit'

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup(): Promise<void> {
    hilog.info(0x0000, 'LEDBanner', 'onBackup')
  }

  async onRestore(bundleVersion: BundleVersion): Promise<void> {
    hilog.info(0x0000, 'LEDBanner', 'onRestore, version: %{public}s', bundleVersion.name)
  }
}
