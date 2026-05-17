//首页大框架
import { DetailsPage } from './DetailsPage'
import { TaskListPage } from './TaskListPage'

@Entry
@Component
struct Index {
  @State currentTab:number=0

  build() {
    Column(){
      //底部首页，详情页tab
      Tabs({index:this.currentTab,barPosition:BarPosition.End}){
        //首页
        TabContent(){
          TaskListPage()//任务页
        }
        .tabBar("任务")
        TabContent(){
          DetailsPage()//详情页
        }
        .tabBar("详情")
      }
      .scrollable(false)
      .onChange((index:number)=>{
        this.currentTab=index
      })
    }
  }
}