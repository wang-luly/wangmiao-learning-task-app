import {TaskItem} from "../model/TaskItem";
import { getPriorityText } from "../utils/PriorityUtils";
import {formatTime} from "../utils/TimeUtils";

@Component
export struct TaskCard {//TaskListPage的子组件
  @Prop task:TaskItem
  //-------------------------------------------函数--------------------------------------------
  //用回调函数实现删除数据
  deleteClick:()=>void=()=>{}
  //用回调函数实现修改数据，因为涉及到taskList的修改，因此依然用父子回调
  updateClick:()=>void=()=>{}

  build() {
    Row(){
      //名称和截止时间放在一个Column中
      Column({space:10}){
        Row({space:20}){
          Text(this.task.name)
          Text(getPriorityText(this.task.priority))
        }
        Text(formatTime(this.task.dueTime))
      }
      .alignItems(HorizontalAlign.Start)
      .margin({left:10})
      Blank()
      //编辑按钮
      Button("编辑")
        .backgroundColor(Color.Green)
        .margin({right:10})
        .onClick(()=>{
          this.updateClick()
        })
      //删除按钮
      Button("删除")
        .backgroundColor(Color.Red)

        .onClick((event: ClickEvent) => {
          this.deleteClick()
      })
    }
    .borderRadius(25)
    .width("100%")
    .height(80)
    .backgroundColor(Color.Yellow)
  }
}