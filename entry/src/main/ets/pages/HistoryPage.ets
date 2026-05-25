import { common } from '@kit.AbilityKit'
import { AddTaskDialog } from '../components/AddTaskDialog'
import { TaskCard } from '../components/TaskCard'
import { TaskDetailDialog } from '../components/TaskDetailDialog'
import { TaskItem } from '../model/TaskItem'
import { taskStore, TaskStore } from '../model/TaskStore'
import { AppMotion, listItemTransition } from '../theme/AppMotion'
import { HeaderRowModifier, TitleTextModifier } from '../theme/AppStyles'
import { getPageSafeInsets } from '../utils/SafeAreaUtil'
import { SortTask } from '../utils/SortTask'

@Component
export struct HistoryPage {
  @State topInset: number = 0
  @State bottomInset: number = 0
  @State headerScale: number = 1
  // @State taskNum: number = 0
  @State isHistoryExpand: boolean = true//默认展开
  @State isDesc: boolean = false//默认升序排序
  @State store: TaskStore = taskStore//全局任务卡变量
  // @State editingTask: TaskItem | null = null
  @State filterDate: Date | null = null//筛选日期
  @State currentTask: TaskItem | null = null//当前任务
  detailDialogController: CustomDialogController | null = null
  // studyDialogController: CustomDialogController | null = null
  initDetailDialog() {
    this.detailDialogController = new CustomDialogController({
      builder: TaskDetailDialog({
        task: this.currentTask,
        // editClick: () => {
        //   this.detailDialogController?.close()
        //   this.openEditDialog(this.currentTask!)
        // },
        // finishClick: () => {
        //   this.currentTask!.isFinished = false
        //   this.store.updateTask(this.currentTask!)
        //   this.detailDialogController?.close()
        // },
        // deleteClick: () => {
        //   this.store.removeTask(this.currentTask!.id)
        //   this.currentTask = null
        //   this.detailDialogController?.close()
        // }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true,
      backgroundColor: $r('app.color.bg_secondary'),
      cornerRadius: 12,
      borderWidth: 0,
      width: '85%',
      maskColor: '#99000000',
      openAnimation: { duration: 180, curve: Curve.EaseOut },
      closeAnimation: { duration: 220, curve: Curve.EaseIn }
    })
  }

  // initTaskDialog() {
  //   this.studyDialogController = new CustomDialogController({
  //     builder: AddTaskDialog({
  //       editingTask: this.editingTask,
  //       confirm: async (taskName: string, dueTime: Date, priority: number) => {
  //         if (!taskName || taskName.trim().length == 0) {
  //           this.getUIContext().getPromptAction().showToast({ message: '任务名不能为空' })
  //           return
  //         }
  //         if (this.editingTask) {
  //           let updated = new TaskItem()
  //           updated.id = this.editingTask.id
  //           updated.name = taskName
  //           updated.dueTime = dueTime
  //           updated.priority = priority
  //           updated.isFinished = this.editingTask.isFinished
  //           updated.studyCount = this.editingTask.studyCount
  //           updated.studyMinute = this.editingTask.studyMinute
  //           await this.store.updateTask(updated)
  //         }
  //         this.editingTask = null
  //       }
  //     }),
  //     autoCancel: true,
  //     alignment: DialogAlignment.Center,
  //     customStyle: true,
  //     backgroundColor: $r('app.color.bg_secondary'),
  //     cornerRadius: 12,
  //     borderWidth: 0,
  //     width: 300,
  //     maskColor: '#99000000',
  //     openAnimation: { duration: 180, curve: Curve.EaseOut },
  //     closeAnimation: { duration: 220, curve: Curve.EaseIn }
  //   })
  // }

  // openEditDialog(task: TaskItem) {
  //   this.editingTask = task
  //   this.initTaskDialog()
  //   this.studyDialogController?.open()
  // }

  async aboutToAppear() {
    const insets = await getPageSafeInsets(this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.topInset = insets.top
    this.bottomInset = insets.bottom
    // this.initTaskDialog()
  }

  isSameDay(date1: Date, date2: Date): boolean {
    return date1.getFullYear() == date2.getFullYear()
      && date1.getMonth() == date2.getMonth()
      && date1.getDate() == date2.getDate()
  }

  // /** 已完成：今日 */
  // getTodayFinished(): TaskItem[] {
  //   let now = new Date()
  //   return this.store.tasks.filter(t =>
  //     t.isFinished &&
  //     t.dueTime.getFullYear() === now.getFullYear() &&
  //     t.dueTime.getMonth() === now.getMonth() &&
  //     t.dueTime.getDate() === now.getDate()
  //   )
  // }

  /** 已完成：全部或按日期筛选 */
  filterFinished(): TaskItem[] {
    let list = this.store.tasks.filter(t => t.isFinished)
    if (!this.filterDate) {
      return list
    }
    return list.filter(item => this.isSameDay(item.dueTime, this.filterDate!))
  }

  /** 先日期后优先级（SortTask） */
  getSortedList(): TaskItem[] {
    let raw = this.filterFinished()
    return SortTask([...raw], this.isDesc)
  }

  showTaskDetail(task: TaskItem) {
    this.currentTask = task
    this.initDetailDialog()
    this.detailDialogController?.open()
  }

  // @Builder
  // topButton(title: string, tar: number, click: () => void) {
  //   Button() {
  //     Text(title)
  //       .fontSize(15)
  //       .fontWeight(FontWeight.Medium)
  //       .fontColor(this.taskNum === tar ? $r('app.color.gold_primary') : $r('app.color.text_secondary'))
  //   }
  //   .width(88)
  //   .height(40)
  //   .backgroundColor(this.taskNum === tar ? $r('app.color.bg_secondary') : $r('app.color.bg_elevated'))
  //   .borderRadius(20)
  //   .border({
  //     width: this.taskNum === tar ? 1.5 : 1,
  //     color: this.taskNum === tar ? $r('app.color.gold_primary') : $r('app.color.border_subtle')
  //   })
  //   .scale({
  //     x: this.taskNum === tar ? 1.05 : 1,
  //     y: this.taskNum === tar ? 1.05 : 1
  //   })
  //   .animation({ duration: AppMotion.FAST, curve: Curve.Sharp })
  //   .onClick(() => {
  //     click()
  //   })
  // }

  build() {
    Column() {
      // Row({ space: 40 }) {
      //   this.topButton('今日', 0, () => { this.taskNum = 0 })
      //   this.topButton('所有', 1, () => { this.taskNum = 1 })
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.Center)
      // .margin({ top: 8, bottom: 16 })

      List() {
        ListItem() {
          Row() {
            Text('已完成任务').attributeModifier(new TitleTextModifier())
            Row({ space: 12 }) {
              Image(this.isHistoryExpand ? $r('app.media.down') : $r('app.media.right'))
                .width(22)
                .height(22)
                .rotate({ angle: this.isHistoryExpand ? 90 : 0 })
                .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseInOut })
                .onClick(() => {
                  this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {
                    this.headerScale = 0.97
                  })
                  this.isHistoryExpand = !this.isHistoryExpand
                  this.getUIContext().animateTo({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }, () => {
                    this.headerScale = 1
                  })
                })
              Image(this.isDesc ? $r('app.media.Desc') : $r('app.media.Asc'))
                .width(22)
                .height(22)
                .onClick(() => {
                  this.isDesc = !this.isDesc
                })
              Image($r('app.media.filter'))
                .width(22)
                .height(22)
                .onClick(() => {
                  this.getUIContext().getPromptAction().showDialog({
                    title: '截止日期选择',
                    message: '请选择筛选方式',
                    buttons: [
                      { text: '所有时间', color: '#C9A962' },
                      { text: '选择日期', color: '#C9A962' }
                    ]
                  }, (err, data) => {
                    if (data.index == 0) {
                      this.filterDate = null
                    } else if (data.index == 1) {
                      let endDate = new Date()
                      endDate.setFullYear(endDate.getFullYear() + 1)
                      this.getUIContext().showDatePickerDialog({
                        start: new Date(),
                        end: endDate,
                        selected: this.filterDate ?? new Date(),
                        onDateAccept: (value: Date) => { this.filterDate = value }
                      })
                    }
                  })
                })
            }
          }
          .onClick(() => {
            this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {
              this.headerScale = 0.97
            })
            this.isHistoryExpand = !this.isHistoryExpand
            this.getUIContext().animateTo({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }, () => {
              this.headerScale = 1
            })
          })
          .attributeModifier(new HeaderRowModifier())
          .justifyContent(FlexAlign.SpaceBetween)
          .scale({ x: this.headerScale, y: this.headerScale })
          .animation({ duration: AppMotion.FAST })
        }
        .margin({ bottom: 8 })
//=================================================================================================
        if (this.isHistoryExpand) {
          if (this.getSortedList().length === 0) {
            ListItem() {
              Text('暂无已完成任务')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 24, bottom: 24 })
            }
          } else {
            ForEach(this.getSortedList(), (item: TaskItem) => {
              ListItem() {
                TaskCard({
                  task: item,
                  detailClick: () => { this.showTaskDetail(item) }
                })
              }
              .margin({ bottom: 8 })
              .transition(listItemTransition())
            }, (item: TaskItem) => item.id)
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_primary'))
    .padding({
      left: 16,
      right: 16,
      top: 12 + this.topInset,
      bottom: this.bottomInset
    })
  }
}
