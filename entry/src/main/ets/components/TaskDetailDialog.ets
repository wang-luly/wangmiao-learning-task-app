import { TaskItem } from "../model/TaskItem"
import {
  AuxiliaryModifier,
  GHostButtonModifier,
  GoldenFillButtonModifier,
  GoldenOutlineButtonModifier,
  TitleTextModifier
} from "../theme/AppStyles"

@CustomDialog
//详情对话框
export struct TaskDetailDialog {
  controller: CustomDialogController
  @State taskName: string = ''
  @State count: number = 0
  @State minute: number = 0
  task: TaskItem | null = null

  aboutToAppear(): void {
    if (this.task) {
      this.taskName = this.task.name
      this.count = this.task.studyCount
      this.minute = this.task.studyMinute
    }
  }

  editClick: () => void = () => {}
  finishClick: () => void = () => {}
  deleteClick: () => void = () => {}

  build() {
    Column({ space: 20 }) {
      Text(this.taskName)
        .attributeModifier(new TitleTextModifier())
        .fontSize(22)
        .width('100%')
      Text(`专注次数：${this.count}`)
        .attributeModifier(new AuxiliaryModifier())
        .width('100%')
      Text(`累计学习：${this.minute} 分钟`)
        .attributeModifier(new AuxiliaryModifier())
        .width('100%')
      Row({ space: 12 }) {
        Button('编辑')
          .attributeModifier(new GoldenOutlineButtonModifier())
          .layoutWeight(1)
          .onClick(() => {
            this.editClick()
          })
        Button('完成')
          .attributeModifier(new GoldenFillButtonModifier())
          .layoutWeight(1)
          .onClick(() => {
            this.finishClick()
          })
        Button('删除')
          .attributeModifier(new GHostButtonModifier())
          .fontColor('#E57373')
          .layoutWeight(1)
          .onClick(() => {
            this.deleteClick()
          })
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
    .backgroundColor($r('app.color.bg_secondary'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_subtle') })
  }
}
