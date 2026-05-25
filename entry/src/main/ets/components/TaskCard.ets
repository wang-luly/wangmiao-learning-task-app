import {TaskItem} from "../model/TaskItem";
import { getPriorityText } from "../utils/PriorityUtils";
import {formatTime} from "../utils/TimeUtils";
import { Router } from "@ohos.arkui.UIContext";
import router from "@ohos.router";
import { getPriorityColor } from "../theme/AppColors";
import { GoldenOutlineButtonModifier, TaskCardMarginModifier } from "../theme/AppStyles";
import { AppMotion, listItemTransition } from "../theme/AppMotion";


//添加和修改任务对话框
@Component
export struct TaskCard {//TaskListPage的子组件

  @ObjectLink task:TaskItem
  //-------------------------------------------函数--------------------------------------------
  //回调详情
  detailClick:()=>void=()=>{}

  build() {
    Row(){
      //左侧优先竖线条
      Column()
        .width(3)
        .height(36)
        .backgroundColor(
          this.task.isFinished ? $r('app.color.text_muted') : getPriorityColor(this.task.priority)
        )
        .borderRadius(2)
        .margin({ right: 12 })
      //名称和截止时间放在一个Column中
      Column({space:6}){
        Text(this.task.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.task.isFinished ? $r('app.color.text_muted') : $r('app.color.text_primary'))
          .decoration({
            type:this.task.isFinished?TextDecorationType.LineThrough:TextDecorationType.None,
            color:Color.White
          })
          .maxLines(1)//最大一行
          .textOverflow({ overflow: TextOverflow.Ellipsis })//超出以省略号显示
        Text(formatTime(this.task.dueTime))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      //开始按钮
      Button("开始")
        .attributeModifier(new GoldenOutlineButtonModifier())
        .onClick(() => {
          this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {})
          let router = this.getUIContext().getRouter()
          router.pushUrl({
            url: 'pages/TimingPage',
            params: {
              taskId: this.task.id
            }
          })
        })
    }
    .attributeModifier(new TaskCardMarginModifier())
    .transition(listItemTransition())
    .onClick(() => {
      this.detailClick()
    })
  }
}