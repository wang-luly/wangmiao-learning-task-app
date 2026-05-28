import {TaskItem} from "../model/TaskItem";
import {formatTime} from "../utils/TimeUtils";
import { getPriorityColor } from "../theme/AppColors";
import { GoldenOutlineButtonModifier } from "../theme/AppStyles";
import { taskStore, TaskStore } from "../model/TaskStore";


//添加和修改任务对话框
@Component
export struct TaskCard {//TaskListPage的子组件

  @ObjectLink task:TaskItem
  @State store:TaskStore=taskStore
  //-------------------------------------------函数--------------------------------------------
  //回调详情
  detailClick:()=>void=()=>{}
  @Styles
  taskCardContainerStyle() {
  .width('100%')
  .padding({ left: 12, right: 12, top: 14, bottom: 14 })
  .backgroundColor($r('app.color.bg_secondary'))
  .borderRadius(12)
  .border({ width: 1, color: $r('app.color.border_subtle') })
}

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
          .key(`${this.task.id}_${this.task.name}`)
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
      //计时学习or删除按钮
      Button(this.task.isFinished?"删除":"计时")
        .attributeModifier(new GoldenOutlineButtonModifier())
        .onClick(() => {
          if(this.task.isFinished==false){
            let router = this.getUIContext().getRouter()
            router.pushUrl({
              url: 'pages/TimingPage',
              params: {
                taskId: this.task.id
              }
            })
          }
          else{//删除
            this.store.removeTask(this.task.id)
          }
        })
    }
    .taskCardContainerStyle()
    .onClick(() => {
      this.detailClick()
    })
  }
}
