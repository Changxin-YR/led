export interface ColorScheme {
  id: string
  name: string
  textColor: string
  backgroundColor: string
  category: string
}

export const COLOR_PRESETS: ColorScheme[] = [
  { id: '1', name: '经典绿', textColor: '#00FF00', backgroundColor: '#000000', category: '经典' },
  { id: '2', name: '热情红', textColor: '#FF0000', backgroundColor: '#000000', category: '应援' },
  { id: '3', name: '纯净白', textColor: '#FFFFFF', backgroundColor: '#000000', category: '通用' },
  { id: '4', name: '浪漫粉', textColor: '#FF69B4', backgroundColor: '#000000', category: '表白' },
  { id: '5', name: '活力橙', textColor: '#FF8C00', backgroundColor: '#000000', category: '促销' },
  { id: '6', name: '科技蓝', textColor: '#00BFFF', backgroundColor: '#000000', category: '科技' },
  { id: '7', name: '土豪金', textColor: '#FFD700', backgroundColor: '#000000', category: '高端' },
  { id: '8', name: '荧光黄', textColor: '#FFFF00', backgroundColor: '#000000', category: '醒目' },
  { id: '9', name: '梦幻紫', textColor: '#9B59B6', backgroundColor: '#000000', category: '梦幻' },
  { id: '10', name: '反转白', textColor: '#000000', backgroundColor: '#FFFFFF', category: '白天' },
  { id: '11', name: '彩虹渐变', textColor: '#RAINBOW', backgroundColor: '#000000', category: '特效' },
  { id: '12', name: '自定义', textColor: '#FFFFFF', backgroundColor: '#000000', category: '自定义' }
]
