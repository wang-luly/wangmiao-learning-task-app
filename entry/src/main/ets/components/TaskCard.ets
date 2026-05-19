import {TaskItem} from "../model/TaskItem";
import {formatTime} from "../utils/TimeUtils";

@Component
export struct TaskCard {
  @Prop task:TaskItem
  //用回调函数实现删除数据
  @Prop deleteClick:()=>void=()=>{}

  build() {
    Row(){
      //名称和截止时间放在一个Column中
      Column({space:10}){
        Text(this.task.name)
        Text(formatTime(this.task.dueTime))
      }
      .alignItems(HorizontalAlign.Start)
      .margin({left:10})
      Blank()
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