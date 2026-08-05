import { Template, TemplateCategory } from '../models/Template'
import { DisplayMode, ScrollDirection, SpeedLevel } from '../models/BannerConfig'

export class TemplateService {
  private static instance: TemplateService | null = null
  private templates: Template[] = [
    {
      id: 't1', name: '演唱会应援', category: TemplateCategory.CHEER,
      text: '我爱你', textColor: '#FF0000', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_cheer'
    },
    {
      id: 't2', name: '粉丝加油', category: TemplateCategory.CHEER,
      text: 'Fighting!', textColor: '#9B59B6', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 90, icon: 'placeholder_fight'
    },
    {
      id: 't3', name: '加油打气', category: TemplateCategory.CHEER,
      text: '加油鸭', textColor: '#FF9800', backgroundColor: '#000000',
      displayMode: DisplayMode.STATIC, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 120, icon: 'placeholder_pickup'
    },
    {
      id: 't4', name: '生日祝福', category: TemplateCategory.FUN,
      text: '生日快乐', textColor: '#F04F98', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_welcome'
    },
    {
      id: 't5', name: '接机欢迎', category: TemplateCategory.PICKUP,
      text: '欢迎回家', textColor: '#00E5FF', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_love'
    },
    {
      id: 't6', name: '出行平安', category: TemplateCategory.PICKUP,
      text: '一路平安', textColor: '#73E63D', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 90, icon: 'placeholder_marry'
    },
    {
      id: 't7', name: '促销活动', category: TemplateCategory.PROMO,
      text: '新品上市', textColor: '#FFE000', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.FAST, fontSize: 110, icon: 'placeholder_sale'
    },
    {
      id: 't15', name: '限时优惠', category: TemplateCategory.PROMO,
      text: '限时特价', textColor: '#FF8C00', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_discount'
    },
    {
      id: 't8', name: '安全提示', category: TemplateCategory.NOTICE,
      text: '注意安全', textColor: '#168BFF', backgroundColor: '#000000',
      displayMode: DisplayMode.SCROLL_HORIZONTAL, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 90, icon: 'placeholder_open'
    },
    {
      id: 't9', name: '课堂通知', category: TemplateCategory.NOTICE,
      text: '请保持安静', textColor: '#00BFFF', backgroundColor: '#000000',
      displayMode: DisplayMode.STATIC, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_quiet'
    },
    {
      id: 't10', name: '排队叫号', category: TemplateCategory.NOTICE,
      text: '请1号到前台', textColor: '#00FF00', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 100, icon: 'placeholder_queue'
    },
    {
      id: 't11', name: '聚会游戏', category: TemplateCategory.FUN,
      text: '真心话大冒险', textColor: '#FF0000', backgroundColor: '#000000',
      displayMode: DisplayMode.NEON, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 80, icon: 'placeholder_game'
    },
    {
      id: 't12', name: '生日快乐', category: TemplateCategory.FUN,
      text: '生日快乐', textColor: '#FFD700', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_birthday'
    },
    {
      id: 't13', name: '浪漫表白', category: TemplateCategory.LOVE,
      text: 'I Love You', textColor: '#FF69B4', backgroundColor: '#000000',
      displayMode: DisplayMode.BREATH, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.SLOW, fontSize: 100, icon: 'placeholder_love'
    },
    {
      id: 't14', name: '心动告白', category: TemplateCategory.LOVE,
      text: '我喜欢你', textColor: '#FF1493', backgroundColor: '#000000',
      displayMode: DisplayMode.BLINK, scrollDirection: ScrollDirection.RIGHT_TO_LEFT,
      speedLevel: SpeedLevel.NORMAL, fontSize: 110, icon: 'placeholder_heart'
    }
  ]

  static getInstance(): TemplateService {
    if (!TemplateService.instance) {
      TemplateService.instance = new TemplateService()
    }
    return TemplateService.instance
  }

  getAllTemplates(): Template[] {
    return this.templates
  }

  getTemplatesByCategory(category: string): Template[] {
    return this.templates.filter((t: Template) => t.category === category)
  }

  getCategories(): string[] {
    return [
      TemplateCategory.CHEER,
      TemplateCategory.PICKUP,
      TemplateCategory.LOVE,
      TemplateCategory.PROMO,
      TemplateCategory.NOTICE,
      TemplateCategory.FUN
    ]
  }
}
