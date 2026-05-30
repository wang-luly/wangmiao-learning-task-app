import { common } from '@kit.AbilityKit'
import { AddTaskDialog } from '../components/AddTaskDialog'
import { TaskCard } from '../components/TaskCard'
import { TaskDetailDialog } from '../components/TaskDetailDialog'
import { taskDB } from '../database/TaskDatabase'
import { TaskItem } from '../model/TaskItem'
import { taskStore, TaskStore } from '../model/TaskStore'
import { HeaderRowModifier, TitleTextModifier } from '../theme/AppStyles'
import { getPageSafeInsets } from '../utils/SafeAreaUtil'
import { SortTask } from '../utils/SortTask'

@Component
export struct HistoryPage {
  @State topInset: number = 0
  @State bottomInset: number = 0
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
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true,
      backgroundColor: $r('app.color.bg_secondary'),
      cornerRadius: 12,
      borderWidth: 0,
      width: '85%',
      maskColor: '#99000000'
    })
  }


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

  async showTaskDetail(task: TaskItem) {
    const latest = await taskDB.queryTaskById(task.id)
    const idx = this.store.tasks.findIndex(t => t.id === task.id)
    if (latest && idx !== -1) {
      TaskItem.applyFrom(this.store.tasks[idx], latest)
      this.store.tasks = [...this.store.tasks]
      this.currentTask = this.store.tasks[idx]
    } else {
      this.currentTask = latest ?? task
    }
    this.initDetailDialog()
    this.detailDialogController?.open()
  }


//===============================================UI=======================================
  build() {
    Column() {
      List() {
        ListItem() {
          Row() {
            Text('已完成任务').attributeModifier(new TitleTextModifier())
            Row({ space: 12 }) {
              Image(this.isHistoryExpand ? $r('app.media.down') : $r('app.media.right'))
                .width(22)
                .height(22)
                .rotate({ angle: this.isHistoryExpand ? 90 : 0 })
                .onClick(() => {
                  this.isHistoryExpand = !this.isHistoryExpand
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
            this.isHistoryExpand = !this.isHistoryExpand
          })
          .attributeModifier(new HeaderRowModifier())
          .justifyContent(FlexAlign.SpaceBetween)
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
            }, (item: TaskItem) => `${item.id}_${item.name}_${item.dueTime.getTime()}`)
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
