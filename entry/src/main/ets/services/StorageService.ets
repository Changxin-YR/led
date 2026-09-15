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
  private initPromise: Promise<void> | null = null
  private writeQueue: Promise<void> = Promise.resolve()

  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService()
    }
    return StorageService.instance
  }

  async init(context: Context): Promise<void> {
    if (this.store) return
    if (!this.initPromise) {
      this.initPromise = this.createStore(context)
    }

    const pending = this.initPromise
    try {
      await pending
    } finally {
      if (this.initPromise === pending) this.initPromise = null
    }
  }

  private async createStore(context: Context): Promise<void> {
    try {
      this.store = await preferences.getPreferences(context, STORE_NAME)
    } catch (error) {
      throw new Error(`Unable to open local preferences: ${JSON.stringify(error)}`)
    }
  }

  async saveLastConfig(config: BannerConfig): Promise<void> {
    if (!this.isValidBannerConfig(config as Object)) throw new Error('Invalid banner configuration')
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      await store.put(KEY_LAST_CONFIG, JSON.stringify(config))
      await store.flush()
    })
  }

  async saveDisplayConfig(config: BannerConfig): Promise<void> {
    if (!this.isValidBannerConfig(config as Object)) throw new Error('Invalid display configuration')
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      const records = await this.readHistory(store)
      await store.put(KEY_LAST_CONFIG, JSON.stringify(config))
      await store.put(KEY_HISTORY, JSON.stringify(this.mergeHistory(records, config)))
      await store.flush()
    })
  }

  async getLastConfig(): Promise<BannerConfig | null> {
    const store = this.requireStore()
    let raw: string
    try {
      raw = await store.get(KEY_LAST_CONFIG, '') as string
    } catch (error) {
      throw new Error(`Unable to read the last configuration: ${JSON.stringify(error)}`)
    }
    if (!raw) return null
    try {
      const parsed = JSON.parse(raw) as Object
      return this.isValidBannerConfig(parsed) ? parsed as BannerConfig : null
    } catch {
      return null
    }
  }

  async addHistory(config: BannerConfig): Promise<void> {
    if (!this.isValidBannerConfig(config as Object)) throw new Error('Invalid history configuration')
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      const records = await this.readHistory(store)
      await store.put(KEY_HISTORY, JSON.stringify(this.mergeHistory(records, config)))
      await store.flush()
    })
  }

  async getHistory(): Promise<HistoryRecord[]> {
    return this.readHistory(this.requireStore())
  }

  async deleteHistory(id: string): Promise<void> {
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      const records = await this.readHistory(store)
      const filtered = records.filter((r: HistoryRecord) => r.id !== id)
      await store.put(KEY_HISTORY, JSON.stringify(filtered))
      await store.flush()
    })
  }

  async clearHistory(): Promise<void> {
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      await store.put(KEY_HISTORY, '[]')
      await store.flush()
    })
  }

  async saveCustomColor(color: string): Promise<void> {
    if (!/^#[0-9A-Fa-f]{6}$/.test(color)) throw new Error('Invalid custom color')
    const store = this.requireStore()
    await this.enqueueWrite(async (): Promise<void> => {
      const colors = await this.readCustomColors(store)
      const idx = colors.indexOf(color)
      if (idx >= 0) colors.splice(idx, 1)
      colors.unshift(color)
      const trimmed = colors.slice(0, MAX_CUSTOM_COLORS)
      await store.put(KEY_CUSTOM_COLORS, JSON.stringify(trimmed))
      await store.flush()
    })
  }

  async getCustomColors(): Promise<string[]> {
    return this.readCustomColors(this.requireStore())
  }

  private requireStore(): preferences.Preferences {
    if (!this.store) throw new Error('StorageService is not initialized')
    return this.store
  }

  private enqueueWrite(operation: () => Promise<void>): Promise<void> {
    const next = this.writeQueue.then(operation)
    this.writeQueue = next.catch((): void => undefined)
    return next
  }

  private mergeHistory(records: HistoryRecord[], config: BannerConfig): HistoryRecord[] {
    const existing = records.findIndex((record: HistoryRecord) => record.config.text === config.text)
    if (existing >= 0) {
      records[existing].lastUsedAt = Date.now()
      records[existing].useCount++
      records[existing].config = config
    } else {
      records.unshift({
        id: config.id,
        config: config,
        lastUsedAt: Date.now(),
        useCount: 1
      })
    }
    return records.slice(0, MAX_HISTORY)
  }

  private async readHistory(store: preferences.Preferences): Promise<HistoryRecord[]> {
    let raw: string
    try {
      raw = await store.get(KEY_HISTORY, '[]') as string
    } catch (error) {
      throw new Error(`Unable to read history: ${JSON.stringify(error)}`)
    }
    try {
      const parsed = JSON.parse(raw) as Object
      if (!Array.isArray(parsed)) return []
      const records: HistoryRecord[] = []
      for (const item of parsed as Object[]) {
        if (this.isValidHistoryRecord(item)) records.push(item as HistoryRecord)
      }
      return records
    } catch {
      return []
    }
  }

  private async readCustomColors(store: preferences.Preferences): Promise<string[]> {
    let raw: string
    try {
      raw = await store.get(KEY_CUSTOM_COLORS, '[]') as string
    } catch (error) {
      throw new Error(`Unable to read custom colors: ${JSON.stringify(error)}`)
    }
    try {
      const parsed = JSON.parse(raw) as Object
      if (!Array.isArray(parsed)) return []
      const colors: string[] = []
      for (const item of parsed as Object[]) {
        if (typeof item === 'string' && /^#[0-9A-Fa-f]{6}$/.test(item as string)) {
          colors.push(item as string)
        }
      }
      return colors
    } catch {
      return []
    }
  }

  private isValidBannerConfig(value: Object): boolean {
    const candidate = value as Record<string, Object>
    return typeof candidate['id'] === 'string' &&
      (candidate['id'] as string).length > 0 &&
      typeof candidate['text'] === 'string' &&
      (candidate['text'] as string).trim().length > 0 &&
      (candidate['text'] as string).length <= 200 &&
      this.isValidColor(candidate['textColor'], true) &&
      this.isValidColor(candidate['backgroundColor']) &&
      typeof candidate['fontSize'] === 'number' &&
      (candidate['fontSize'] as number) >= 30 &&
      (candidate['fontSize'] as number) <= 200 &&
      typeof candidate['displayMode'] === 'string' &&
      typeof candidate['scrollDirection'] === 'string' &&
      typeof candidate['speedLevel'] === 'number' &&
      (candidate['speedLevel'] as number) >= 1 &&
      (candidate['speedLevel'] as number) <= 5 &&
      typeof candidate['ledStyle'] === 'string' &&
      typeof candidate['isMirrored'] === 'boolean' &&
      typeof candidate['showBorder'] === 'boolean' &&
      this.isValidColor(candidate['borderColor']) &&
      typeof candidate['isLandscape'] === 'boolean' &&
      typeof candidate['createdAt'] === 'number' &&
      (candidate['createdAt'] as number) >= 0
  }

  private isValidColor(value: Object, allowRainbow: boolean = false): boolean {
    return typeof value === 'string' &&
      ((allowRainbow && value === '#RAINBOW') || /^#[0-9A-Fa-f]{6}$/.test(value as string))
  }

  private isValidHistoryRecord(value: Object): boolean {
    const candidate = value as Record<string, Object>
    return typeof candidate['id'] === 'string' &&
      typeof candidate['lastUsedAt'] === 'number' &&
      typeof candidate['useCount'] === 'number' &&
      (candidate['lastUsedAt'] as number) >= 0 &&
      (candidate['useCount'] as number) >= 1 &&
      this.isValidBannerConfig(candidate['config'])
  }
}
