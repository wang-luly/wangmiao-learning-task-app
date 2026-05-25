import { taskDB } from "../database/TaskDatabase";
import { TaskItem } from "../model/TaskItem";
import { TaskStore, taskStore } from "../model/TaskStore";
import { StudyRecord } from "../model/StudyRecord";
import { util } from "@kit.ArkTS";
import { todayTimeNotify } from "../utils/NotificationUtils";
import { GoldenFillButtonModifier, GoldenOutlineButtonModifier } from "../theme/AppStyles";

@Entry
@Component
export struct TimingPage {
  @State store: TaskStore = taskStore
  @State taskId: string = ''
  @State taskName: string = '学习任务'
  @State second: number = 0
  private readonly pomodoroSeconds: number = 25 * 60
  @State timer: number = -1
  task: TaskItem | null = null

  async aboutToAppear() {
    let router = this.getUIContext().getRouter()
    let params = router.getParams() as Record<string, string>
    this.taskId = params['taskId']
    let currentTask = await taskDB.queryTaskById(this.taskId)
    if (currentTask) {
      this.taskName = currentTask.name
      this.task = currentTask
    }
  }

  startTimer() {
    if (this.timer != -1) {
      return
    }
    this.timer = setInterval(() => {
      this.second++
    }, 1000)
  }

  pauseTimer() {
    if (this.timer == -1) {
      return
    }
    clearInterval(this.timer)
    this.timer = -1
  }

  async finishTimer() {
    if (this.timer != -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
    let minute = Math.floor(this.second / 60)
    if (minute == 0) {
      this.getUIContext().getPromptAction().showDialog({
        title: '温馨提示',
        message: '学习时长过短，不会计入学习时长',
        buttons: [
          { text: '继续学习', color: '#C9A962' },
          { text: '坚持退出', color: '#9A9A9A' }
        ]
      }, (err, data) => {
        if (data.index == 1) {
          this.backPage()
        } else if (data.index == 0) {
          this.startTimer()
        }
      })
      return
    }
    if (this.task) {
      this.task.studyCount += 1
      this.task.studyMinute += minute
      await this.store.updateTask(this.task)
      let record = new StudyRecord(
        util.generateRandomUUID(),
        this.task.id,
        minute,
        new Date()
      )
      await taskDB.insertRecord(record)
      await todayTimeNotify()
    }
    this.second = 0
    this.backPage()
  }

  formatTime(): string {
    let minute = Math.floor(this.second / 60)
    let second = this.second % 60
    return `${minute.toString().padStart(2, '0')}:${second.toString().padStart(2, '0')}`
  }

  backPage() {
    this.getUIContext().getRouter().back()
  }

  ringProgress(): number {
    return Math.min(this.second, this.pomodoroSeconds)
  }

  build() {
    Column({ space: 40 }) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.ringProgress(),
          total: this.pomodoroSeconds,
          type: ProgressType.Ring
        })
          .width(280)
          .height(280)
          .color($r('app.color.gold_primary'))
          .backgroundColor($r('app.color.border_subtle'))
          .style({ strokeWidth: 12 })

        Column({ space: 12 }) {
          Text(this.taskName)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .width(200)
          Text(this.formatTime())
            .fontSize(56)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.gold_light'))
          Text('25 分钟')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width(280)
      .height(280)

      Row({ space: 16 }) {
        Button(this.timer==-1?"开始":"暂停")
          .attributeModifier(new GoldenOutlineButtonModifier())
          .onClick(() => {
            this.timer==-1?this.startTimer():this.pauseTimer()
          })
        Button('结束')
          .attributeModifier(new GoldenFillButtonModifier())
          .onClick(() => { this.finishTimer() })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.bg_primary'))
    .justifyContent(FlexAlign.Center)
  }
}
