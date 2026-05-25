/** 全应用动效：时长与转场 */
export class AppMotion {
  static readonly FAST: number = 220
  static readonly NORMAL: number = 380
  static readonly SLOW: number = 720
  static readonly CHART: number = 900
}

export function listItemTransition(): TransitionEffect {
  return TransitionEffect.OPACITY
    .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseOut })
    .combine(TransitionEffect.translate({ y: 28 }).animation({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }))
}

export function cardPressTransition(): TransitionEffect {
  return TransitionEffect.scale({ x: 0.96, y: 0.96 })
    .animation({ duration: AppMotion.FAST, curve: Curve.Sharp })
}
