import { preferences } from '@kit.ArkData'
import { BannerConfig } from '../models/BannerConfig'
import { HistoryRecord } from '../models/HistoryRecord'

const STORE_NAME = 'led_banner_store'
const KEY_HISTORY = 'history_records'
const KEY_LAST_CONFIG = 'last_config'
const KEY_CUSTOM_COLORS = 'custom_colors'
const MAX_HISTORY = 20
const MAX_CUSTOM_COLORS = 10

export class StorageService {
  private store: preferences.Preferences | null = null
  private static instance: StorageService | null = null

  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService()
    }
    return StorageService.instance
  }

  async init(context: Context): Promise<void> {
    if (this.store) return
    this.store = await preferences.getPreferences(context, STORE_NAME)
  }

  async saveLastConfig(config: BannerConfig): Promise<void> {
    if (!this.store) return
    await this.store.put(KEY_LAST_CONFIG, JSON.stringify(config))
    await this.store.flush()
  }

  async getLastConfig(): Promise<BannerConfig | null> {
    if (!this.store) return null
    const raw = await this.store.get(KEY_LAST_CONFIG, '') as string
    if (!raw) return null
    try {
      return JSON.parse(raw) as BannerConfig
    } catch {
      return null
    }
  }

  async addHistory(config: BannerConfig): Promise<void> {
    if (!this.store) return
    const records = await this.getHistory()
    const existing = records.findIndex((r: HistoryRecord) => r.config.text === config.text)
    if (existing >= 0) {
      records[existing].lastUsedAt = Date.now()
      records[existing].useCount++
      records[existing].config = config
    } else {
      const record: HistoryRecord = {
        id: Date.now().toString(),
        config: config,
        lastUsedAt: Date.now(),
        useCount: 1
      }
      records.unshift(record)
    }
    const trimmed = records.slice(0, MAX_HISTORY)
    await this.store.put(KEY_HISTORY, JSON.stringify(trimmed))
    await this.store.flush()
  }

  async getHistory(): Promise<HistoryRecord[]> {
    if (!this.store) return []
    const raw = await this.store.get(KEY_HISTORY, '[]') as string
    try {
      return JSON.parse(raw) as HistoryRecord[]
    } catch {
      return []
    }
  }

  async deleteHistory(id: string): Promise<void> {
    if (!this.store) return
    const records = await this.getHistory()
    const filtered = records.filter((r: HistoryRecord) => r.id !== id)
    await this.store.put(KEY_HISTORY, JSON.stringify(filtered))
    await this.store.flush()
  }

  async clearHistory(): Promise<void> {
    if (!this.store) return
    await this.store.put(KEY_HISTORY, '[]')
    await this.store.flush()
  }

  async saveCustomColor(color: string): Promise<void> {
    if (!this.store) return
    const colors = await this.getCustomColors()
    const idx = colors.indexOf(color)
    if (idx >= 0) colors.splice(idx, 1)
    colors.unshift(color)
    const trimmed = colors.slice(0, MAX_CUSTOM_COLORS)
    await this.store.put(KEY_CUSTOM_COLORS, JSON.stringify(trimmed))
    await this.store.flush()
  }

  async getCustomColors(): Promise<string[]> {
    if (!this.store) return []
    const raw = await this.store.get(KEY_CUSTOM_COLORS, '[]') as string
    try {
      return JSON.parse(raw) as string[]
    } catch {
      return []
    }
  }
}
