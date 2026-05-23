//任务页
import { TaskItem } from "../model/TaskItem";
import { util } from "@kit.ArkTS";
import {AddTaskDialog} from "../components/AddTaskDialog"
import { TaskCard } from "../components/TaskCard";
import { taskDB } from "../database/TaskDatabase";
import { SortTask } from "../utils/SortTask";
import { TaskDetailDialog } from "../components/TaskDetailDialog";
import { taskStore,TaskStore } from "../model/TaskStore";
import { todayDueTimeNotify } from "../utils/NotificationUtils";

@Component
export struct TaskListPage {
  //控制是今日还是所有任务
  @State taskNum:number=0
  //控制学习任务是否展示,实现下拉框
  @State isStudyExpand:boolean=false
  //控制升序排序还是降序排序
  @State isDesc:boolean=true
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
      })
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
      autoCancel:true,
      alignment:DialogAlignment.Center
    })
  }
  //打开新增弹窗
  openAddDialog(){
    this.editingTask=null
    this.studyDialogController?.open()
  }
  //打开编辑弹窗（与新增弹窗是同一个）
  openEditDialog(task:TaskItem){
    //这里让editingtask不为空
    this.editingTask=task
    this.studyDialogController?.open()
  }
  @Styles//顶部按钮style
  topButtonStyle(){
  .width(100)
  .height(40)
  .backgroundColor("rgba(255,255,255,0.7)")
  .borderRadius(25)
}
  //顶部按钮builder
  @Builder
  topButton(title:string,tar:number,click:()=>void){
    Button() {
      Row() {
        Image($r("app.media.fish"))
          .width(40)
          .height(40)
        Text(title)
          .fontColor(Color.White)
          .fontSize(16)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Medium)
      }
    }
    //按键切换特效
    .border({
      width:this.taskNum==tar?2:0,//一直都是红色，只不过控制宽度控制显示或者是不显示
      color:Color.Red
    })
    .topButtonStyle()
    .onClick(()=>{
      click()
    })
  }
//-------------------------------------------------------函数-----------------------------------------------
  //TaskListPage生命周期函数（只执行一次）
  async aboutToAppear() {
    //初始化数据库
    await taskDB.init(this.getUIContext().getHostContext() as Context)
    //利用store单例从数据库加载任务
    await this.store.loadTasks()
    //得到任务后排序
    this.applyPriority()
    //初始化，使得弹窗控制器不为空
    this.initTaskDialog()//添加编辑弹窗
    console.info('[DEBUG] TaskListPage: 任务数量', this.store.tasks.length);
    console.info('[DEBUG] TaskListPage: 任务列表', JSON.stringify(this.store.tasks));
    //检查今日到期任务
    await todayDueTimeNotify()
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
    //显示所有==null
    if(!this.filterDate){
      return this.store.tasks
    }
    //显示当前筛选日期任务
    return this.store.tasks.filter((item)=>{
      return this.isSameDay(item.dueTime,this.filterDate!)
    })
  }
  //排序函数：通过isDesc判断是升序还是降序
  applyPriority() {
    //所有任务排序
    this.store.tasks = SortTask([...this.store.tasks],this.isDesc)
  }
  //展示任务详情
  showTaskDetail(task:TaskItem){
    this.currentTask=task
    this.initDetailDialog()//详情弹窗
    this.detailDialogController?.open()
  }
//------------------------------------------UI----------------------------------------
  build() {
    Stack(){
      // 整个任务页的背景图
      Image(this.taskNum==0?$r("app.media.todayTaskBg"):$r("app.media.allTaskBg"))
        .width("100%")
        .height("100%")
      //整个屏幕Column
      Column() {
        Row({space:20}){
        //-------------------------顶部三个按钮------------------------------
          //今日任务按钮
          this.topButton("今日",0,()=>{
            this.taskNum=0
          })

          //所有任务按钮
          this.topButton("所有",1,()=>{
            this.taskNum=1
          })

          //添加任务按钮
          this.topButton("添加",-1,()=>{
            this.openAddDialog()
          })
        }
//-------------------------------------------------list展示------------------------------------------------------
          List(){
            //学习任务标题---------------------
            ListItem(){
              Row(){
                Text("学习任务")
                Row({space:10}){
                  //展开图片>
                  Image(this.isStudyExpand?$r("app.media.down"):$r("app.media.right"))
                    .width(30)
                    .onClick(()=>{
                      this.isStudyExpand=!this.isStudyExpand
                    })
                  //排序图片
                  Image(this.isDesc?$r('app.media.Desc'):$r('app.media.Asc'))
                    .width(30)
                    .onClick(()=>{
                      this.isDesc=!this.isDesc
                      this.applyPriority()
                    })
                  //如果是所有任务，显示按截止日期筛选的图片
                  if(this.taskNum==1){
                    Image($r('app.media.filter'))
                      .width(30)
                      .onClick(()=>{
                        //获取promptAction对象
                        let promptAction=this.getUIContext().getPromptAction()
                        //显示操作菜单
                        promptAction.showDialog({
                          //标题
                          title:'截止日期选择',
                          message:'请选择筛选方式',
                          //按钮
                          buttons:[{text:'所有时间',color:'#000'},{text:'选择日期',color:'#000'}]
                        },(err,data)=>{
                          if(data.index==0){
                            this.filterDate=null
                          }
                          else if(data.index==1){
                            //设置终止日期为一年后的今天
                            let endDate=new Date()
                            endDate.setFullYear(endDate.getFullYear()+1)
                            //弹出日期选择框
                            this.getUIContext().showDatePickerDialog({
                              start:new Date(),
                              end:endDate,
                              selected:this.filterDate??new Date(),
                              onDateAccept:(value:Date)=>{
                                this.filterDate=value
                              }
                            })
                          }
                        }
                        )
                      })
                  }
                }
                  .margin({right:10})
              }
                .justifyContent(FlexAlign.SpaceBetween)//分为两侧
                .backgroundColor(Color.Green)
                .width("100%")
                .height(50)
                .padding({left:10,right:10})
            }
            .margin({top:10})

            //学习任务列表-------------------------------
            if(this.isStudyExpand){
              ForEach(this.taskNum==0?this.store.getToday():this.filterDueTime(),(item:TaskItem)=>{
                ListItem(){
                  //TaskCard
                  TaskCard({//这是父组件传递给子组件TaskCard,task
                    task:item,
                  //详情点击
                    detailClick:async ()=>{
                      this.showTaskDetail(item)
                     }
                  })
                }
                .margin({left:10,right:10,top:5})
              })
            }
          }
          .width("100%")
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .height("100%")
    }

  }
}