import { SpeedLevel } from '../models/BannerConfig'

export class AnimationService {
  private static instance: AnimationService | null = null

  static getInstance(): AnimationService {
    if (!AnimationService.instance) {
      AnimationService.instance = new AnimationService()
    }
    return AnimationService.instance
  }

  getScrollDuration(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 12000,
      '2': 8000,
      '3': 5000,
      '4': 3000,
      '5': 1500
    }
    return map[speedLevel.toString()] || 5000
  }

  getBlinkInterval(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 2000,
      '2': 1500,
      '3': 1000,
      '4': 600,
      '5': 300
    }
    return map[speedLevel.toString()] || 1000
  }

  getBreathDuration(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 5000,
      '2': 4000,
      '3': 3000,
      '4': 2000,
      '5': 1200
    }
    return map[speedLevel.toString()] || 3000
  }

  getBarrageSpeed(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 8000,
      '2': 6000,
      '3': 4000,
      '4': 2500,
      '5': 1500
    }
    return map[speedLevel.toString()] || 4000
  }

  getFlipInterval(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 5000,
      '2': 4000,
      '3': 3000,
      '4': 2000,
      '5': 1000
    }
    return map[speedLevel.toString()] || 3000
  }

  getNeonCycleDuration(speedLevel: SpeedLevel): number {
    const map: Record<string, number> = {
      '1': 6000,
      '2': 4500,
      '3': 3000,
      '4': 2000,
      '5': 1000
    }
    return map[speedLevel.toString()] || 3000
  }
}
