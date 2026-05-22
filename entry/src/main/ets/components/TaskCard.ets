import {TaskItem} from "../model/TaskItem";
import { getPriorityText } from "../utils/PriorityUtils";
import {formatTime} from "../utils/TimeUtils";
import { Router } from "@ohos.arkui.UIContext";
import router from "@ohos.router";



//添加和修改任务对话框
@Component
export struct TaskCard {//TaskListPage的子组件

  @ObjectLink task:TaskItem
  //-------------------------------------------函数--------------------------------------------
  //回调详情
  detailClick:()=>void=()=>{}

  build() {
    Row(){
      //名称和截止时间放在一个Column中
      Column({space:10}){
        Text(this.task.name)
          .decoration({
            type:this.task.isFinished?TextDecorationType.LineThrough:TextDecorationType.None
          })
          .fontColor(this.task.isFinished?Color.Gray:Color.Black)
        Text(formatTime(this.task.dueTime))
      }
      .alignItems(HorizontalAlign.Start)
      .margin({left:10})
      .layoutWeight(1)
       Blank()
      //开始按钮
      Button("开始").onClick((event: ClickEvent) => {
        let router=this.getUIContext().getRouter()
        router.pushUrl({
          url:'pages/TimingPage',
          params:{
            taskId:this.task.id
          }
        })
      })
    }
    .padding(10)
    .borderRadius(25)
    .width("100%")
    .backgroundColor(Color.Yellow)
    .onClick(()=>{
      this.detailClick()
    })
  }
}