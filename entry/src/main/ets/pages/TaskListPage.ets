//任务页
import { TaskItem } from "../model/TaskItem";
import { StartOptions } from "@kit.AbilityKit";
import { util } from "@kit.ArkTS";
import {AddTaskDialog} from "../components/AddTaskDialog"
import { TaskCard } from "../components/TaskCard";
import { taskDB } from "../database/TaskDatabase";



@Component
export struct TaskListPage {
  //控制是今日还是所有任务
  @State taskNum:number=0
  //控制学习任务是否展示,实现下拉框
  @State isStudyExpand:boolean=false
  //测试任务列表展示
  @State todayTaskList: TaskItem[] = []
  @State allTaskList: TaskItem[] =[]
  //编辑任务
  @State editingTask:TaskItem|null=null
  //学习任务弹窗控制器
  studyDialogController:CustomDialogController|null=null
  //初始化弹窗
  initTaskDialog(){
    this.studyDialogController=new CustomDialogController({
      builder:AddTaskDialog({
        editingTask:this.editingTask,
        confirm:async (taskName:string,dueTime:Date,priority:number)=>{
          //编辑任务
          if(this.editingTask){
            let updated:TaskItem={
              id:this.editingTask.id,
              name:taskName,
              dueTime:dueTime,
              priority:priority,
              isFinished:this.editingTask.isFinished
            }
            await taskDB.updateTask(updated)
            this.allTaskList=this.allTaskList.map((t)=>{
              return t.id==updated.id?updated:t
            })
          }else{//否则的话就是新增任务，用之前写好的新增任务逻辑
            let newTask:TaskItem={
              id:util.generateRandomUUID(),
              dueTime:dueTime,
              name:taskName,
              priority:priority,
              isFinished:false
            }
            await taskDB.insertTask(newTask)
            this.allTaskList.push(newTask)
          }
          this.todayTaskList=this.allTaskList.filter((item)=>{
            return this.isToday(item.dueTime)
          })
          this.allTaskList=[...this.allTaskList]
          this.todayTaskList=[...this.todayTaskList]
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
  //生命周期函数（只执行一次）
  async aboutToAppear() {
    //初始化数据库
    await taskDB.init(this.getUIContext().getHostContext() as Context)
    //查询全部任务
    this.allTaskList=await taskDB.queryAllTask()
    //筛选今日任务
    this.todayTaskList=this.allTaskList.filter(item=>{
      return this.isToday(item.dueTime)
    })
    //初始化，使得弹窗控制器为空
    this.initTaskDialog()
  }
  //判断是否是今日的函数
  isToday(time:Date):boolean{
    let nowDate=new Date()
    return time.getFullYear()==nowDate.getFullYear()
    &&time.getMonth()==nowDate.getMonth()
    &&time.getDate()==nowDate.getDate()
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
        //任务列表展示todo:按优先级排序和截止日期筛选
          List(){
            //学习任务标题
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
                }
                  .margin({right:10})
              }
                .justifyContent(FlexAlign.SpaceBetween)
                .backgroundColor(Color.Green)
                .width("100%")
                .height(50)
            }
            .margin({top:10})

            //学习任务列表
            if(this.isStudyExpand){
              ForEach(this.taskNum==0?this.todayTaskList:this.allTaskList,(item:TaskItem)=>{
                ListItem(){
                  //将学习任务卡片分离到子组件TaskCard
                  TaskCard({
                    task:item,
                    updateClick:async ()=>{
                      this.openEditDialog(item)
                    },
                    deleteClick:async ()=>{
                      //删除数据库
                      await taskDB.deleteTask(item.id)
                      //删除所有任务中的该任务（用过滤器）
                      this.allTaskList=this.allTaskList.filter((task)=>{
                        return task.id!=item.id
                      })
                      //删除今日任务中的该任务（filter）
                      this.todayTaskList=this.todayTaskList.filter((task)=>{
                        return task.id != item.id
                      })
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