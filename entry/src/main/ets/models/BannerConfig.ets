export enum DisplayMode {
  SCROLL_HORIZONTAL = 'scroll_h',
  SCROLL_VERTICAL = 'scroll_v',
  STATIC = 'static',
  BLINK = 'blink',
  BREATH = 'breath',
  BARRAGE = 'barrage',
  FLIP = 'flip',
  NEON = 'neon'
}

export enum ScrollDirection {
  LEFT_TO_RIGHT = 'ltr',
  RIGHT_TO_LEFT = 'rtl',
  TOP_TO_BOTTOM = 'ttb',
  BOTTOM_TO_TOP = 'btt'
}

export enum SpeedLevel {
  VERY_SLOW = 1,
  SLOW = 2,
  NORMAL = 3,
  FAST = 4,
  VERY_FAST = 5
}

export enum LEDStyle {
  SOLID = 'solid',
  DOT_MATRIX = 'dot',
  OUTLINE = 'outline'
}

export interface BannerConfig {
  id: string
  text: string
  textColor: string
  backgroundColor: string
  fontSize: number
  displayMode: DisplayMode
  scrollDirection: ScrollDirection
  speedLevel: SpeedLevel
  ledStyle: LEDStyle
  isMirrored: boolean
  showBorder: boolean
  borderColor: string
  isLandscape: boolean
  createdAt: number
}

export const DEFAULT_CONFIG: BannerConfig = {
  id: '',
  text: 'Hello World',
  textColor: '#00FF00',
  backgroundColor: '#000000',
  fontSize: 80,
  displayMode: DisplayMode.SCROLL_HORIZONTAL,
  scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
  speedLevel: SpeedLevel.NORMAL,
  ledStyle: LEDStyle.SOLID,
  isMirrored: false,
  showBorder: false,
  borderColor: '#00FF00',
  isLandscape: false,
  createdAt: 0
}

export class DisplayRouteParams {
  config: string

  constructor(config: string) {
    this.config = config
  }
}
