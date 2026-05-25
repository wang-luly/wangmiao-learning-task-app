import { Priority, TaskItem } from "../model/TaskItem"
import {
  AuxiliaryModifier,
  GHostButtonModifier,
  GoldenFillButtonModifier,
  TitleTextModifier
} from "../theme/AppStyles"

/** 添加/编辑弹窗水平翻转入场时长（毫秒） */
const FLIP_IN_DURATION: number = 620

@CustomDialog
export struct AddTaskDialog {
  controller: CustomDialogController
  @State taskName: string = ''
  @State dueTime: Date = new Date()
  @State startTime: Date = new Date()
  @State endTime: Date = new Date()
  @State priority: number = Priority.LOW
  editingTask: TaskItem | null = null
  priorityList: SelectOption[] = [{ value: "低" }, { value: "中" }, { value: "高" }]

  @State animScale: number = 0.12
  @State flipScaleX: number = 0.02
  /** 绕 Y 轴水平翻转：180° → 0° */
  @State flipAngleY: number = 180
  @State animOpacity: number = 0

  confirm: (taskName: string, dueTime: Date, priority: number) => void = () => {}

  aboutToAppear(): void {
    let now = new Date()
    this.startTime = new Date(now)
    this.endTime = new Date(now)
    this.endTime.setFullYear(this.endTime.getFullYear() + 1)
    if (this.editingTask) {
      this.taskName = this.editingTask.name
      this.dueTime = this.editingTask.dueTime
      this.priority = this.editingTask.priority
    }
    setTimeout(() => {
      this.playHorizontalFlipIn()
    }, 50)
  }

  /** 水平绕 Y 轴 180°→0°，由小变大淡入 */
  playHorizontalFlipIn(): void {
    this.animScale = 0.12
    this.flipScaleX = 0.02
    this.flipAngleY = 180
    this.animOpacity = 0
    this.getUIContext().animateTo({
      duration: FLIP_IN_DURATION,
      curve: Curve.EaseInOut
    }, () => {
      this.animScale = 1
      this.flipScaleX = 1
      this.flipAngleY = 0
      this.animOpacity = 1
    })
  }

  build() {
    Column({ space: 20 }) {
      Text(this.editingTask ? "编辑任务" : "创建任务")
        .attributeModifier(new TitleTextModifier())
        .fontSize(20)
      TextInput({
        placeholder: "请输入任务名称",
        text: this.taskName
      })
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_muted'))
        .backgroundColor($r('app.color.bg_elevated'))
        .borderRadius(8)
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .onChange((value) => {
          this.taskName = value
        })
      Column({ space: 6 }) {
        Text("截止时间")
          .attributeModifier(new AuxiliaryModifier())
        Column() {
          DatePicker({
            start: this.startTime,
            end: this.endTime,
            selected: this.dueTime
          })
            .selectedTextStyle({
              color: '#C9A962',
              font: { size: 18, weight: FontWeight.Medium }
            })
            .disappearTextStyle({
              color: '#9A9A9A',
              font: { size: 14, weight: FontWeight.Regular }
            })
            .textStyle({
              color: '#5C5C5C',
              font: { size: 15, weight: FontWeight.Regular }
            })
            .onDateChange((value: Date) => {
              this.dueTime = value
            })
        }
        .padding(10)
        .height(70)
        .backgroundColor($r('app.color.bg_elevated'))
        .borderRadius(8)
        .border({ width: 1, color: $r('app.color.border_subtle') })
      }
      Row() {
        Text("优先级")
          .width("30%")
          .attributeModifier(new AuxiliaryModifier())
        Select(this.priorityList)
          .selected(this.priority)
          .value(this.priorityList[this.priority].value)
          .font({ size: 15 })
          .fontColor($r('app.color.text_primary'))
          .selectedOptionFont({ size: 15 })
          .optionFont({ size: 15 })
          .backgroundColor($r('app.color.bg_elevated'))
          .onSelect((index: number) => {
            this.priority = index
          })
      }
      .width('100%')

      Row({ space: 20 }) {
        Button("取消")
          .attributeModifier(new GHostButtonModifier())
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })
        Button("确定")
          .attributeModifier(new GoldenFillButtonModifier())
          .layoutWeight(1)
          .onClick(() => {
            if (!this.taskName || this.taskName.trim().length == 0) {
              this.getUIContext().getPromptAction().showToast({
                message: '无法创建，你还没有输入任务名哦'
              })
              return
            }
            this.confirm(this.taskName, this.dueTime, this.priority)
            this.controller.close()
          })
      }
    }
    .width(300)
    .padding(20)
    .backgroundColor($r('app.color.bg_secondary'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_subtle') })
    .rotate({
      x: 0,
      y: 1,
      z: 0,
      angle: this.flipAngleY,
      centerX: '50%',
      centerY: '50%'
    })
    .scale({ x: this.animScale * this.flipScaleX, y: this.animScale })
    .opacity(this.animOpacity)
  }
}
