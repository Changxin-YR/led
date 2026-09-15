export class AppTheme {
  static readonly PAGE_BG: string = '#030A16'
  static readonly PAGE_BG_DEEP: string = '#01050D'
  static readonly SYSTEM_STATUS_BAR: string = '#030A16'
  static readonly SYSTEM_NAVIGATION_BAR: string = '#030A16'
  static readonly SURFACE: string = '#091629'
  static readonly SURFACE_RAISED: string = '#0D1B30'
  static readonly SURFACE_SOFT: string = '#111B2D'
  static readonly SETTING_PANEL_BG: string = '#091426'
  static readonly BORDER: string = '#1A3454'
  static readonly BORDER_BRIGHT: string = '#087BB5'
  static readonly ACCENT: string = '#00E5FF'
  static readonly ACCENT_BLUE: string = '#168BFF'
  static readonly ON_ACCENT: string = '#00131A'
  static readonly TEXT_PRIMARY: string = '#F5F8FF'
  static readonly DISPLAY_OVERLAY_BG: string = '#07111F'
  static readonly DISPLAY_OVERLAY_FG: string = '#FFFFFF'
  static readonly TEXT_SECONDARY: string = '#A6B0C3'
  static readonly TEXT_MUTED: string = '#8793A8'
  // The dot-matrix guide is still a Text control; keep it readable in both system themes.
  static readonly LED_MATRIX_DOT_COLOR: string = '#8793A8'
  static readonly LED_MATRIX_DOT_OPACITY: number = 0.85
  static readonly TOGGLE_OFF_TRACK: string = '#8793A8'
  static readonly TOGGLE_THUMB: string = '#00131A'
  static readonly DANGER: string = '#FF4D5A'
  static readonly SUCCESS: string = '#20D972'
  static readonly WARNING: string = '#D8E535'
  static readonly PANEL_RADIUS: number = 14
  static readonly CONTROL_RADIUS: number = 9
  static readonly PAGE_PADDING: number = 16
  static readonly HEADER_HEIGHT: number = 60
  static readonly BOTTOM_NAV_HEIGHT: number = 72
  static readonly NAV_ICON_SLOT_HEIGHT: number = 30
  static readonly PAGE_SECTION_GAP: number = 14
  static readonly CARD_GAP: number = 14
  static readonly SETTING_ROW_HEIGHT: number = 38
  static readonly SETTING_PANEL_VERTICAL_PADDING: number = 6
  static readonly UI_FONT_SCALE: number = 1.08
  // Keep decorative dot-matrix glyphs above the HarmonyOS PC/2-in-1 10fp minimum.
  static readonly LED_MATRIX_DOT_FONT_SIZE: number = 10
  static readonly UI_FONT_WEIGHT: FontWeight = FontWeight.Medium
  static readonly SYSTEM_TOP_PADDING: number = 28
  static readonly SYSTEM_BOTTOM_PADDING: number = 28

  static uiFontSize(baseSize: number): number {
    return Math.round(baseSize * AppTheme.UI_FONT_SCALE)
  }
}
