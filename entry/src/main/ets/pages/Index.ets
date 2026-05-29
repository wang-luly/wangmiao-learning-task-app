//首页大框架
import { TaskListPage } from './TaskListPage'
import { CountPage } from "./CountPage";
import { HistoryPage } from './HistoryPage';
@Entry
@Component
struct Index {
  @State currentTab: number = 0
  //解决CountPage无法实时获取最新学习数据的问题
  @State countRefreshTick:number=0
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
          CountPage({refreshTick:this.countRefreshTick})//给countPage传参
        }
        .tabBar(this.tabBarItem("统计", 2))
        .onWillShow(()=>{
          this.countRefreshTick++
        })
      }
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barBackgroundColor($r('app.color.bg_primary'))
      .barOverlap(true)//tab浮在内容之上
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],//允许延伸到状态栏/导航栏，允许延伸到刘海/挖孔
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
      if (this.currentTab === index) {
        Row()
          .width(20)
          .height(3)
          .borderRadius(2)
          .backgroundColor($r('app.color.gold_primary'))
      }
    }
    .padding({ top: 8, bottom: 8 })
  }
}
