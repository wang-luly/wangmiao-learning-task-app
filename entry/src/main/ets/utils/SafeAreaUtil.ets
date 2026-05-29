import { common } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export interface PageSafeInsets {
  top: number
  bottom: number
}

/** 读取状态栏、底部导航/手势条高度（vp），避免与系统栏重叠 */
export async function getPageSafeInsets(context: common.UIAbilityContext): Promise<PageSafeInsets> {
  try {
    const win = await window.getLastWindow(context)
    const system = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)//顶部
    const navigation = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)//底部
    return {
      top: px2vp(system.topRect.height),//px转换成vp，适应不同屏幕密度
      bottom: px2vp(navigation.bottomRect.height)
    }
  } catch {
    return { top: 0, bottom: 0 }
  }
}
