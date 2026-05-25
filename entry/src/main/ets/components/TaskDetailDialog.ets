import { TaskItem } from "../model/TaskItem"
import {
  AuxiliaryModifier,
  GHostButtonModifier,
  GoldenFillButtonModifier,
  GoldenOutlineButtonModifier,
  TitleTextModifier
} from "../theme/AppStyles"

/** 详情弹窗双轴翻转入场时长（毫秒） */
const FLIP_IN_DURATION: number = 620

@CustomDialog
export struct TaskDetailDialog {
  controller: CustomDialogController
  task: TaskItem | null = null

  @State taskName: string = ''
  @State count: number = 0
  @State minute: number = 0
  @State priority:number=0
  @State isFinished:boolean=false
  /** 整体缩放：先小后大 */
  @State animScale: number = 0.12
  /** 水平展开辅助（绕 Y 轴翻转时增强立体感） */
  @State flipScaleX: number = 0.02
  /** 竖直展开辅助（绕 X 轴翻转时增强立体感） */
  @State flipScaleY: number = 0.02
  /** 绕 Y 轴：水平方向转 180° */
  @State flipAngleY: number = 180
  /** 绕 X 轴：竖直方向转 180° */
  @State flipAngleX: number = 0
  @State animOpacity: number = 0

  editClick: () => void = () => {}
  finishClick: () => void = () => {}
  deleteClick: () => void = () => {}

  aboutToAppear(): void {
    this.syncTaskContent()
    setTimeout(() => {
      this.playDualAxisFlipIn()
    }, 50)
  }

  syncTaskContent(): void {
    if (this.task) {
      this.taskName = this.task.name
      this.count = this.task.studyCount
      this.minute = this.task.studyMinute//这个任务学习总分钟
      this.priority =this.task.priority
      this.isFinished = this.task.isFinished
    }
  }

  /** 水平(Y) + 竖直(X) 同步各转 180°，并由小变大淡入 */
  playDualAxisFlipIn(): void {
    this.animScale = 0.12
    this.flipScaleX = 0.02
    this.flipScaleY = 0.02
    this.flipAngleY = 180
    //this.flipAngleX = 180
    this.animOpacity = 0
    this.getUIContext().animateTo({
      duration: FLIP_IN_DURATION,
      curve: Curve.EaseInOut
    }, () => {
      this.animScale = 1
      this.flipScaleX = 1
      this.flipScaleY = 1
      this.flipAngleY = 0
      //this.flipAngleX = 0
      this.animOpacity = 1
    })
  }
  /**
   * priority转优先级文字
   */
  priorityToNum(priority:number):string{
    switch(priority){
      case 0:
        return '低'
      case 1:
        return '中'
      case 2:
        return '高'
      default :
        return '无'
    }
  }

  @Builder
  DetailContent() {
    Column({ space: 20 }) {
      Text(this.taskName)
        .attributeModifier(new TitleTextModifier())
        .fontSize(22)
        .width('100%')
      Text(`优先级别：${this.priorityToNum(this.priority)}`)
        .attributeModifier(new AuxiliaryModifier())
        .width('100%')
      Text(`专注次数：${this.count}`)
        .attributeModifier(new AuxiliaryModifier())
        .width('100%')
      Text(`累计学习：${this.minute} 分钟`)
        .attributeModifier(new AuxiliaryModifier())
        .width('100%')
      if(this.isFinished===false){
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
    }
    .width('100%')
  }

  build() {
    // 外层：绕 Y 轴水平转 180°
    Column() {
      // 内层：绕 X 轴竖直转 180°（与 Y 轴动画同一 animateTo 同步）
      Column() {
        this.DetailContent()
      }
      .width('100%')
      .rotate({
        x: 1,
        y: 0,
        z: 0,
        angle: this.flipAngleX,
        centerX: '50%',
        centerY: '50%'
      })
    }
    .padding(20)
    .width('100%')
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
    .scale({
      x: this.animScale * this.flipScaleX,
      y: this.animScale * this.flipScaleY
    })
    .opacity(this.animOpacity)
  }
}
