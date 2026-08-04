import { BannerConfig } from './BannerConfig'

export interface HistoryRecord {
  id: string
  config: BannerConfig
  lastUsedAt: number
  useCount: number
}
