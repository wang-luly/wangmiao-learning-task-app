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
        .tabBar("任务")
        TabContent(){
          TimingPage()//计时页
        }
        .tabBar("计时")
        TabContent(){
          CountPage()//统计页
        }
        .tabBar("统计")
      }
      .scrollable(false)
      .onChange((index:number)=>{
        this.currentTab=index
      })
    }
  }
}