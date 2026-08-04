import { DisplayMode, ScrollDirection, SpeedLevel } from './BannerConfig'

export interface Template {
  id: string
  name: string
  category: string
  text: string
  textColor: string
  backgroundColor: string
  displayMode: DisplayMode
  scrollDirection: ScrollDirection
  speedLevel: SpeedLevel
  fontSize: number
  icon: string
}

export enum TemplateCategory {
  CHEER = '应援',
  PICKUP = '接机',
  LOVE = '表白',
  PROMO = '促销',
  NOTICE = '通知',
  FUN = '互动'
}
