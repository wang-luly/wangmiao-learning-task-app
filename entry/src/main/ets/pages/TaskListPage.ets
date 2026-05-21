//任务页
import { TaskItem } from "../model/TaskItem";
import { util } from "@kit.ArkTS";
import {AddTaskDialog} from "../components/AddTaskDialog"
import { TaskCard } from "../components/TaskCard";
import { taskDB } from "../database/TaskDatabase";
import { SortTask } from "../utils/SortTask";

@Component
export struct TaskListPage {
  //控制是今日还是所有任务
  @State taskNum:number=0
  //控制学习任务是否展示,实现下拉框
  @State isStudyExpand:boolean=false
  //控制升序排序还是降序排序
  @State isDesc:boolean=true
  //测试任务列表展示
  @State todayTaskList: TaskItem[] = []
  @State allTaskList: TaskItem[] =[]
  //编辑任务
  @State editingTask:TaskItem|null=null
  //当前筛选日期，空表示所有
  @State filterDate:Date|null=null
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

            await taskDB.updateTask(updated)
            this.allTaskList=this.allTaskList.map((t)=>{
              return t.id==updated.id?updated:t
            })
          }else{//否则的话就是新增任务，用之前写好的新增任务逻辑
            let newTask=new TaskItem()
            newTask.id=util.generateRandomUUID()
            newTask.dueTime=dueTime
            newTask.name=taskName
            newTask.priority=priority
            newTask.isFinished=false
            await taskDB.insertTask(newTask)
            this.allTaskList.push(newTask)
          }
          this.todayTaskList=this.allTaskList.filter((item)=>{
            return this.isToday(item.dueTime)
          })
          this.allTaskList=[...this.allTaskList]
          this.todayTaskList=[...this.todayTaskList]
          //点击确定按钮后对任务按优先级排序
          this.applyPriority()
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
    //查询全部任务(taskItem对象版,@Observed)
    let result=await taskDB.queryAllTask()
    this.allTaskList=result.map((item)=>{
      let task=new TaskItem()
      task.id=item.id
      task.name=item.name
      task.dueTime=item.dueTime
      task.priority=item.priority
      task.isFinished=item.isFinished
      return task
    })
    //筛选今日任务
    this.todayTaskList=this.allTaskList.filter(item=>{
      return this.isToday(item.dueTime)
    })
    //得到任务后排序
    this.applyPriority()
    //初始化，使得弹窗控制器不为空
    this.initTaskDialog()
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
      return this.allTaskList
    }
    //显示当前筛选日期任务
    return this.allTaskList.filter((item)=>{
      return this.isSameDay(item.dueTime,this.filterDate!)
    })
  }
  //排序函数：通过isDesc判断是升序还是降序
  applyPriority() {
    //所有任务排序
    this.allTaskList = SortTask(this.allTaskList,this.isDesc)
    //今日任务排序
    this.todayTaskList = SortTask(this.allTaskList.filter((item) => {
      return this.isToday(item.dueTime)
    }),this.isDesc)
  }
//-------------------------------------------------------build----------------------------------------
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
              ForEach(this.taskNum==0?this.todayTaskList:this.filterDueTime(),(item:TaskItem)=>{
                ListItem(){
                  //TaskCard
                  TaskCard({
                    task:item,
                    updateClick:async ()=>{
                      this.openEditDialog(item)//编辑时，传入历史参数
                    },
                    deleteClick:async ()=> {
                      //删除数据库
                      await taskDB.deleteTask(item.id)
                      //删除所有任务中的该任务（用过滤器）
                      this.allTaskList = this.allTaskList.filter((task) => {
                        return task.id != item.id
                      })
                      //删除今日任务中的该任务（filter）
                      this.todayTaskList = this.todayTaskList.filter((task) => {
                        return task.id != item.id
                      })
                      //删除完后对task按优先级排序
                      this.applyPriority()
                    },
                    finishTask:async ()=>{
                      item.isFinished=true
                      await taskDB.updateTask(item)
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