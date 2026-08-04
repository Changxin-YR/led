export class Constants {
  static readonly MAX_TEXT_LENGTH: number = 200
  static readonly MAX_LINES: number = 5
  static readonly MAX_HISTORY: number = 20
  static readonly MAX_CUSTOM_COLORS: number = 10
  static readonly MIN_FONT_SIZE: number = 30
  static readonly MAX_FONT_SIZE: number = 200
  static readonly DEFAULT_FONT_SIZE: number = 80
  static readonly ANIMATION_FRAME_RATE: number = 60

  static readonly SPEED_LABELS: Record<string, string> = {
    '1': '很慢',
    '2': '慢',
    '3': '正常',
    '4': '快',
    '5': '很快'
  }

  static readonly NEON_COLORS: string[] = [
    '#FF0000', '#FF7F00', '#FFFF00', '#00FF00',
    '#0000FF', '#4B0082', '#9B59B6', '#FF0000'
  ]

  static readonly BARRAGE_ROWS: number = 5
  static readonly BARRAGE_MAX_INSTANCES: number = 8
}
