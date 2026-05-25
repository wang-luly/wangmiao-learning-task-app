//首页大框架
import { TaskListPage } from './TaskListPage'
import {TimingPage} from './TimingPage'
import {CountPage} from "./CountPage";

@Entry
@Component
struct Index {
  @State currentTab:number=0

  build() {
    Column(){
      //底部任务页，计时学习页，统计页tab
      Tabs({index:this.currentTab,barPosition:BarPosition.End}){
        //首页
        TabContent(){
          TaskListPage()//任务页
        }
        .tabBar(this.tabBarItem("任务",0))

        TabContent(){
          CountPage()//统计页
        }
        .tabBar(this.tabBarItem("统计",1))
      }
      .scrollable(false)//不显示进度条
      .barMode(BarMode.Fixed)//tab等宽平铺，不可左右滑动
      .barBackgroundColor($r('app.color.bg_primary'))
      .onChange((index:number)=>{
        this.currentTab=index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_primary'))
  }

  /**
   * 选定底部不同tab的状态
   * @param title
   * @param index
   */
  @Builder
  tabBarItem(title: string, index: number) {
    Text(title)
      .fontSize(14)
      .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.currentTab === index ? $r('app.color.gold_primary') : $r('app.color.text_secondary'))
      .padding({ top: 8, bottom: 8 })
  }
}