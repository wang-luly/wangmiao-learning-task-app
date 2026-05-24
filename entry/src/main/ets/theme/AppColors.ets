/**
 * 黑金主题色板
 */
export class AppColors {
  static readonly BG_PRIMARY: string = '#0A0A0A'
  static readonly BG_SECONDARY: string = '#141414'
  static readonly BG_ELEVATED: string = '#1E1E1E'
  static readonly GOLD_PRIMARY: string = '#C9A962'
  static readonly GOLD_LIGHT: string = '#E8D5A3'
  static readonly GOLD_DIM: string = '#8B7355'
  static readonly TEXT_PRIMARY: string = '#F5F5F5'
  static readonly TEXT_SECONDARY: string = '#9A9A9A'
  static readonly TEXT_MUTED: string = '#5C5C5C'
  static readonly BORDER_SUBTLE: string = '#2A2A2A'
}

/** 任务卡片按优先级 优先级左侧竖条颜色：高=金，中=银灰，低=暗灰  */
export function getPriorityColor(priority: number): string {
  switch (priority) {
    case 2:
      return AppColors.GOLD_PRIMARY
    case 1:
      return '#9A9A9A'
    default:
      return '#6B6B6B'
  }
}