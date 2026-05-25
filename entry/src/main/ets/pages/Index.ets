//首页大框架
import { TaskListPage } from './TaskListPage'
import { CountPage } from "./CountPage";
import { AppMotion } from '../theme/AppMotion';
import { HistoryPage } from './HistoryPage';
//todo:柱状图没时间也要画日期和0；筛选没用黑金主题
@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State tabAnim: number = 1

  build() {
    Column() {
      Tabs({ index: this.currentTab, barPosition: BarPosition.End }) {
        TabContent() {
          TaskListPage()
        }
        .tabBar(this.tabBarItem("任务", 0))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.tabBarItem("历史", 1))

        TabContent() {
          CountPage()
        }
        .tabBar(this.tabBarItem("统计", 2))
      }
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barBackgroundColor($r('app.color.bg_primary'))
      .animationDuration(AppMotion.NORMAL)
      .barOverlap(true)
      .onChange((index: number) => {
        this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {
          this.tabAnim = 0.92
        })
        this.currentTab = index
        this.getUIContext().animateTo({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }, () => {
          this.tabAnim = 1
        })
      })
      .opacity(this.tabAnim)
      .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseOut })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM, SafeAreaEdge.START, SafeAreaEdge.END])
  }

  @Builder
  tabBarItem(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(this.currentTab === index ? 15 : 14)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === index ? $r('app.color.gold_primary') : $r('app.color.text_secondary'))
        .scale({
          x: this.currentTab === index ? 1.08 : 1,
          y: this.currentTab === index ? 1.08 : 1
        })
        .animation({ duration: AppMotion.FAST, curve: Curve.Sharp })
      if (this.currentTab === index) {
        Row()
          .width(20)
          .height(3)
          .borderRadius(2)
          .backgroundColor($r('app.color.gold_primary'))
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.5, y: 1 })))
      }
    }
    .padding({ top: 8, bottom: 8 })
  }
}
