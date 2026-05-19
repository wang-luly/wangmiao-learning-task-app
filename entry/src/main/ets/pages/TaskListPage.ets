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
  //学习任务弹窗控制器
  studyDialogController:CustomDialogController=
    new CustomDialogController({
      builder:AddTaskDialog({//将AddTaskDialog绑定给这个控制器
        confirm:async (taskName:string,dueTime:Date)=>{
          //创建任务对象
          let newTask:TaskItem={
            id:util.generateRandomUUID(),
            dueTime:dueTime,
            name:taskName,
            isFinished:false
          }
          //添加到数据库
          await taskDB.insertTask(newTask)
          //添加到所有任务
          this.allTaskList.push(newTask)
          //判断是否加入到今日任务
          if(this.isToday(newTask.dueTime)){
            this.todayTaskList.push(newTask)
          }
          //刷新
          this.allTaskList=[...this.allTaskList]
          this.todayTaskList=[...this.todayTaskList]
        }
      })
    })
  //顶部按钮
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
    .width(100)
    .height(40)
    .backgroundColor("rgba(255,255,255,0.7)")
    //按键切换特效
    .border({
      width:this.taskNum==tar?2:0,//一直都是红色，只不过控制宽度控制显示或者是不显示
      color:Color.Red
    })
    .borderRadius(25)
    .onClick(()=>{
      this.taskNum=tar
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
          Button() {
            Row() {
              Image($r("app.media.fish"))
                .width(40)
                .height(40)
              Text("添加")
                .fontColor(Color.White)
                .fontSize(16)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
            }
          }
          .width(100)
          .height(40)
          .backgroundColor("rgba(255,255,255,0.7)")
            .onClick((event: ClickEvent) => {
              this.studyDialogController.open()
          })

        }

//-------------------------------------------------list展示------------------------------------------------------
        //任务列表展示
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
                  //将学习任务卡片分离到components
                  TaskCard({
                    task:item,
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