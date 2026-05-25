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
  /** 优先级竖条：低=深灰，中=亮银，高=金（低/中对比拉大） */
  static readonly PRIORITY_LOW: string = '#424242'
  static readonly PRIORITY_MID: string = '#C8C8C8'
  static readonly PRIORITY_HIGH: string = '#C9A962'
}

/** 任务卡片左侧竖条：高=金，中=亮银灰，低=深灰 */
export function getPriorityColor(priority: number): string {
  switch (priority) {
    case 2:
      return AppColors.PRIORITY_HIGH
    case 1:
      return AppColors.PRIORITY_MID
    default:
      return AppColors.PRIORITY_LOW
  }
}