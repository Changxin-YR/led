export class RgbColor {
  r: number
  g: number
  b: number

  constructor(r: number, g: number, b: number) {
    this.r = r
    this.g = g
    this.b = b
  }
}

export class Utils {
  private static isHexColor(color: string): boolean {
    return /^#[0-9A-Fa-f]{6}$/.test(color)
  }

  private static getRelativeLuminance(color: string): number {
    const rgb = Utils.hexToRgb(color)
    const toLinear = (channel: number): number => {
      const value = channel / 255
      return value <= 0.04045 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * toLinear(rgb.r) + 0.7152 * toLinear(rgb.g) + 0.0722 * toLinear(rgb.b)
  }

  static getContrastRatio(foreground: string, background: string): number {
    if (!Utils.isHexColor(foreground) || !Utils.isHexColor(background)) return 0
    const foregroundLuminance = Utils.getRelativeLuminance(foreground)
    const backgroundLuminance = Utils.getRelativeLuminance(background)
    return (Math.max(foregroundLuminance, backgroundLuminance) + 0.05) /
      (Math.min(foregroundLuminance, backgroundLuminance) + 0.05)
  }

  static ensureTextContrast(requestedColor: string, backgroundColor: string): string {
    const safeBackground = Utils.isHexColor(backgroundColor) ? backgroundColor : '#000000'
    if (Utils.getContrastRatio(requestedColor, safeBackground) >= 4.5) return requestedColor
    const blackContrast = Utils.getContrastRatio('#000000', safeBackground)
    const whiteContrast = Utils.getContrastRatio('#FFFFFF', safeBackground)
    return blackContrast >= whiteContrast ? '#000000' : '#FFFFFF'
  }

  static generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8)
  }

  static formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hour = date.getHours().toString().padStart(2, '0')
    const minute = date.getMinutes().toString().padStart(2, '0')
    return `${month}-${day} ${hour}:${minute}`
  }

  static truncateText(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text
    return text.substring(0, maxLength) + '...'
  }

  static hexToRgb(hex: string): RgbColor {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if (result) {
      return new RgbColor(
        parseInt(result[1], 16),
        parseInt(result[2], 16),
        parseInt(result[3], 16)
      )
    }
    return new RgbColor(0, 255, 0)
  }

  static rgbToHex(r: number, g: number, b: number): string {
    const toHex = (c: number): string => {
      const hex = Math.max(0, Math.min(255, Math.round(c))).toString(16)
      return hex.length === 1 ? '0' + hex : hex
    }
    return '#' + toHex(r) + toHex(g) + toHex(b)
  }

  static hsvToRgb(h: number, s: number, v: number): RgbColor {
    const c = v * s
    const x = c * (1 - Math.abs((h / 60) % 2 - 1))
    const m = v - c
    let r = 0, g = 0, b = 0
    if (h < 60) { r = c; g = x; b = 0 }
    else if (h < 120) { r = x; g = c; b = 0 }
    else if (h < 180) { r = 0; g = c; b = x }
    else if (h < 240) { r = 0; g = x; b = c }
    else if (h < 300) { r = x; g = 0; b = c }
    else { r = c; g = 0; b = x }
    return new RgbColor(
      Math.round((r + m) * 255),
      Math.round((g + m) * 255),
      Math.round((b + m) * 255)
    )
  }
}
