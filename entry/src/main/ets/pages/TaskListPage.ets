//任务页
import { common } from '@kit.AbilityKit';
import { TaskItem } from "../model/TaskItem";
import { util } from "@kit.ArkTS";
import {AddTaskDialog} from "../components/AddTaskDialog"
import { TaskCard } from "../components/TaskCard";
import { taskDB } from "../database/TaskDatabase";
import { SortTask } from "../utils/SortTask";
import { TaskDetailDialog } from "../components/TaskDetailDialog";
import { taskStore,TaskStore } from "../model/TaskStore";
import { refreshTomorrowReminder, todayDueTimeNotify } from "../utils/NotificationUtils";
import { HeaderRowModifier, TitleTextModifier } from "../theme/AppStyles";
import { getPageSafeInsets } from "../utils/SafeAreaUtil";
import { AppMotion, listItemTransition } from "../theme/AppMotion";

@Component
export struct TaskListPage {
  @State topInset: number = 0
  @State bottomInset: number = 0
  @State headerScale: number = 1
  //控制是今日还是所有任务
  @State taskNum:number=0
  //控制学习任务是否展示,实现下拉框
  @State isStudyExpand:boolean=true

  //控制升序排序还是降序排序
  @State isDesc:boolean=false
  //全局单例任务列表展示
  @State store:TaskStore=taskStore
  //编辑任务
  @State editingTask:TaskItem|null=null
  //当前筛选日期，空表示所有
  @State filterDate:Date|null=null
  //当前任务对象
  @State currentTask:TaskItem|null=null
  //任务详情弹窗控制器
  detailDialogController:CustomDialogController|null=null
  //初始化详情弹窗控制器
  initDetailDialog(){
    this.detailDialogController=new CustomDialogController({
      builder:TaskDetailDialog({
        task:this.currentTask,
        //编辑回调函数
        editClick:()=>{
          this.detailDialogController?.close()
          this.openEditDialog(this.currentTask!)
        },
        //完成回调函数
        finishClick:()=>{
          this.currentTask!.isFinished=true
          this.store.updateTask(this.currentTask!)
          this.detailDialogController?.close()
        },
        //删除回调函数
        deleteClick:()=>{
          this.store.removeTask(this.currentTask!.id)
          this.currentTask=null
          this.detailDialogController?.close()
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true,
      backgroundColor: $r('app.color.bg_secondary'),
      cornerRadius: 12,
      borderWidth: 0,
      width: '85%',
      maskColor: '#99000000',
      // 蒙层快速淡入即可，翻转动画由 TaskDetailDialog 内部完成
      openAnimation: { duration: 180, curve: Curve.EaseOut },
      closeAnimation: { duration: 220, curve: Curve.EaseIn }
    })
  }
  //学习任务弹窗控制器
  studyDialogController:CustomDialogController|null=null
  //初始化对话框弹窗
  initTaskDialog(){
    this.studyDialogController=new CustomDialogController({
      builder:AddTaskDialog({
        editingTask:this.editingTask,
        confirm:async (taskName:string,dueTime:Date,priority:number)=>{
          //任务名不能为空
          if(!taskName||taskName.trim().length==0){
            //弹出toast
            this.getUIContext().getPromptAction().showToast({
              message:'任务名不能为空'
            })
            //阻止继续执行
            return
          }
          //通过editingTask是否为空来判断是编辑任务还是新增任务
          //编辑任务(taskItem对象)
          if(this.editingTask){
            let updated=new TaskItem()

            updated.id=this.editingTask.id
            updated.name=taskName
            updated.dueTime=dueTime
            updated.priority=priority
            updated.isFinished=this.editingTask.isFinished

            await this.store.updateTask(updated)
          }else{//否则的话就是新增任务，用之前写好的新增任务逻辑
            let newTask=new TaskItem()
            newTask.id=util.generateRandomUUID()
            newTask.dueTime=dueTime
            newTask.name=taskName
            newTask.priority=priority
            newTask.isFinished=false
            await this.store.addTask(newTask)
          }
          //最后对任务按优先级排序
          this.applyPriority()
          //将编辑任务置为null
          this.editingTask=null
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true,
      backgroundColor: $r('app.color.bg_secondary'),
      cornerRadius: 12,
      borderWidth: 0,
      width: 300,
      maskColor: '#99000000',
      openAnimation: { duration: 180, curve: Curve.EaseOut },
      closeAnimation: { duration: 220, curve: Curve.EaseIn }
    })
  }
  //打开新增弹窗：每次重建实例以触发 aboutToAppear 内翻转动画
  openAddDialog(){
    this.editingTask=null
    this.initTaskDialog()
    this.studyDialogController?.open()
  }
  //打开编辑弹窗（与新增弹窗是同一个）
  openEditDialog(task:TaskItem){
    this.editingTask=task
    this.initTaskDialog()
    this.studyDialogController?.open()
  }
  //顶部按钮builder
  @Builder
  topButton(title:string,tar:number,click:()=>void){
    Button() {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.taskNum === tar ? $r('app.color.gold_primary') : $r('app.color.text_secondary'))
    }
    .width(88)
    .height(40)
    .backgroundColor(this.taskNum === tar ? $r('app.color.bg_secondary') : $r('app.color.bg_elevated'))
    .borderRadius(20)
    .border({
      width: this.taskNum === tar ? 1.5 : 1,
      color: this.taskNum === tar ? $r('app.color.gold_primary') : $r('app.color.border_subtle')
    })
    .scale({
      x: this.taskNum === tar ? 1.05 : 1,
      y: this.taskNum === tar ? 1.05 : 1
    })
    .animation({ duration: AppMotion.FAST, curve: Curve.Sharp })
    .onClick(() => {
      click()
    })
  }
//-------------------------------------------------------函数-----------------------------------------------
  //TaskListPage生命周期函数（只执行一次）
  async aboutToAppear() {
    const insets = await getPageSafeInsets(this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.topInset = insets.top
    this.bottomInset = insets.bottom
    //初始化数据库
    await taskDB.init(this.getUIContext().getHostContext() as Context)
    //利用store单例从数据库加载任务
    await this.store.loadTasks()
    //得到任务后排序
    this.applyPriority()
    //初始化，使得弹窗控制器不为空
    this.initTaskDialog()//预创建添加/编辑弹窗（打开时仍会 initTaskDialog 重建以播动画）
    // //检查今日到期任务
    // await todayDueTimeNotify()
    //刷新明日通知
    await refreshTomorrowReminder()
  }
  //判断是否是今日的函数
  isToday(time:Date):boolean{
    let nowDate=new Date()
    return time.getFullYear()==nowDate.getFullYear()
    &&time.getMonth()==nowDate.getMonth()
    &&time.getDate()==nowDate.getDate()
  }
  //判断是否是同一天
  isSameDay(date1:Date,date2:Date):boolean{
    return date1.getFullYear()==date2.getFullYear()
      && date1.getMonth()==date2.getMonth()
      && date1.getDate()==date2.getDate()
  }
  //按截止日期筛选函数，仅针对allTaskList
  filterDueTime():TaskItem[]{
    let unfinished = this.store.tasks.filter(item => !item.isFinished)
    if(!this.filterDate){
      return unfinished
    }
    return unfinished.filter((item)=>{
      return this.isSameDay(item.dueTime,this.filterDate!)
    })
  }
  //排序函数：通过isDesc判断是升序还是降序
  applyPriority() {
    //所有任务排序
    this.store.tasks = SortTask([...this.store.tasks],this.isDesc)
  }
  //展示任务详情：每次新建弹窗实例，aboutToAppear 内播水平翻转动画
  showTaskDetail(task:TaskItem){
    this.currentTask=task
    this.initDetailDialog()
    this.detailDialogController?.open()
  }
  /** 未完成：全部或按日期筛选 */
  filterNotFinished(): TaskItem[] {
    let list = this.store.tasks.filter(t => t.isFinished===false)
    //筛选全部还是按日期
    if (!this.filterDate) {
      return list
    }
    return list.filter(item => this.isSameDay(item.dueTime, this.filterDate!))
  }
//------------------------------------------UI----------------------------------------
  build() {
    Column() {
      Row({ space: 40 }) {
        this.topButton("今日", 0, () => { this.taskNum = 0 })
        this.topButton("所有", 1, () => { this.taskNum = 1 })
        // this.topButton("添加", -1, () => { this.openAddDialog() })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8, bottom: 16 })
      List() {
        ListItem() {
          Row() {
            Text("学习任务").attributeModifier(new TitleTextModifier())
            Row({ space: 12 }) {
              Image(this.isStudyExpand ? $r("app.media.down") : $r("app.media.right"))
                .width(22)
                .height(22)
                .rotate({ angle: this.isStudyExpand ? 90 : 0 })
                .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseInOut })
                .onClick(() => {
                  this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {
                    this.headerScale = 0.97
                  })
                  this.isStudyExpand = !this.isStudyExpand
                  this.getUIContext().animateTo({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }, () => {
                    this.headerScale = 1
                  })
                })
              Image($r("app.media.plus"))
                .width(22)
                .height(22)
                .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseInOut })
                .onClick(() => {
                  this.openAddDialog()
                })
              Image(this.isDesc ? $r('app.media.Desc') : $r('app.media.Asc'))
                .width(22)
                .height(22)
                .onClick(() => {
                  this.isDesc = !this.isDesc
                  this.applyPriority()
                })
              if (this.taskNum == 1) {
                Image($r('app.media.filter'))//筛选图标
                  .width(22)
                  .height(22)
                  .onClick(() => {
                    let promptAction = this.getUIContext().getPromptAction()
                    promptAction.showDialog({
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
          }
          .onClick(() => {
            this.getUIContext().animateTo({ duration: AppMotion.FAST, curve: Curve.Sharp }, () => {
              this.headerScale = 0.97
            })
            this.isStudyExpand = !this.isStudyExpand
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
        //学习卡片区=======================================================================
        if (this.isStudyExpand) {
          if (this.taskNum==0&&this.store.getToday().length==0
          ||this.taskNum==1&&this.filterDueTime().length==0) {
            ListItem() {
              Text('暂无任务')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 24, bottom: 24 })
            }
          }else{
            ForEach(this.taskNum == 0 ? this.store.getToday() : this.filterDueTime(), (item: TaskItem, index: number) => {
              ListItem() {
                TaskCard({
                  task: item,
                  detailClick: async () => { this.showTaskDetail(item) }
                })
              }
              .margin({ bottom: 8 })
              .transition(listItemTransition())
            }, (item: TaskItem) => item.id)//
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