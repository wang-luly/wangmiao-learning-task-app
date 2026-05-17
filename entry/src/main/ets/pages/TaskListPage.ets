//任务页
import { TaskItem } from "../model/TaskItem";
import { StartOptions } from "@kit.AbilityKit";
import { util } from "@kit.ArkTS";
import {AddTaskDialog} from "../components/AddTaskDialog"

@Component
export struct TaskListPage {
  //控制是今日还是所有任务
  @State taskNum:number=0
  //控制学习任务和生活任务是否展示,实现下拉框
  @State isStudyExpand:boolean=false
  @State isLifeExpand:boolean=false
  //测试任务列表展示
  @State todayTaskList: TaskItem[] = []
  @State allTaskList: TaskItem[] =[]
  //学习任务弹窗控制器
  studyDialogController:CustomDialogController=
    new CustomDialogController({
      builder:AddTaskDialog({//将AddTaskDialog绑定给这个控制器
        confirm:(taskName:string,dueTime:Date)=>{
          let newTask:TaskItem={
            id:util.generateRandomUUID(),
            dueTime:dueTime,
            name:taskName,
            category:"学习"
          }
          //添加所有任务
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
//-------------------------------------------------------函数-----------------------------------------------
  //判断是否是今日的函数
  isToday(time:Date):boolean{
    let nowDate=new Date()
    return time.getFullYear()==nowDate.getFullYear()
    &&time.getMonth()==nowDate.getMonth()
    &&time.getDate()==nowDate.getDate()
  }

  //得到学习分类的任务
  getStudyTask(taskList:TaskItem[]):TaskItem[]{
    return taskList.filter(item=>{
      return item.category=="学习"
    })
  }
  //得到生活分类的任务
  getLifeTask(taskList:TaskItem[]):TaskItem[]{
    return taskList.filter(item=>{
      return item.category=='生活'
    })
  }

  //标准时间格式函数
  formatTime(time:Date):string{
    let year=time.getFullYear()
    let month=time.getMonth()+1
    let day=time.getDate()
    return `${year}-${month.toString().padStart(2,'0')}-${day.toString().padStart(2,'0')}`
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

          //今日任务按钮
          Button() {
            Row() {
              Image($r("app.media.fish"))
                .width(40)
                .height(40)
              Text("今日")
                .fontColor(Color.White)
                .fontSize(16)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
            }
          }
          .width(100)
          .height(40)
          .borderRadius(25)
          .backgroundColor("rgba(255,255,255,0.7)")
          //按键切换特效
          .border({
            width:this.taskNum==0?2:0,//一直都是红色，只不过控制宽度控制显示或者是不显示
            color:Color.Red
          })
          .onClick((event: ClickEvent) => {
            this.taskNum=0
          })

          //所有任务按钮
          Button() {
            Row() {
              Image($r("app.media.fish"))
                .width(40)
                .height(40)
              Text("所有")
                .fontColor(Color.White)
                .fontSize(16)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
            }
          }
          .width(100)
          .height(40)
          .borderRadius(25)
          .backgroundColor("rgba(255,255,255,0.7)")
          //按键切换特效
          .border({
            width:this.taskNum==1?2:0,//一直都是红色，只不过控制宽度控制显示或者是不显示
            color:Color.Red
          })
          .onClick((event: ClickEvent) => {
            this.taskNum=1
          })

          // //添加任务按钮
          // Button() {
          //   Row() {
          //     Image($r("app.media.fish"))
          //       .width(40)
          //       .height(40)
          //     Text("添加")
          //       .fontColor(Color.White)
          //       .fontSize(16)
          //       .fontColor(Color.Black)
          //       .fontWeight(FontWeight.Medium)
          //   }
          // }
          // .width(100)
          // .height(40)
          // .borderRadius(25)
          // .backgroundColor("rgba(255,255,255,0.7)")
          // .onClick((event: ClickEvent) => {
          //
          // })
        }
//-------------------------------------------------list展示------------------------------------------------------
        //任务列表展示
          List(){
            //学习任务标题
            ListItem(){
              Row(){
                Text("学习任务")
                Row({space:10}){
                  Image(this.isStudyExpand?$r("app.media.down"):$r("app.media.right"))
                    .width(30)
                    .onClick(()=>{
                      this.isStudyExpand=!this.isStudyExpand
                    })
                  Image($r("app.media.plus"))
                    .width(30)
                    .onClick(()=>{
                      //创建学习任务函数
                      this.studyDialogController.open()
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

            //学习任务
            if(this.isStudyExpand){
              ForEach(this.taskNum==0?this.getStudyTask(this.todayTaskList):this.getStudyTask(this.allTaskList),(item:TaskItem)=>{
                ListItem(){
                  Row(){
                    Column({space:10}){
                      Text(item.name)
                      Text(this.formatTime(item.dueTime))
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({left:10})
                  }
                  .borderRadius(25)
                  .width("100%")
                  .height(80)
                  .backgroundColor(Color.Yellow)
                }
                .margin({left:10,right:10,top:5})
              })
            }

            //生活任务标题
            ListItem(){
              Row(){
                Text("生活任务")
                Row({space:10}){
                  Image(this.isLifeExpand?$r("app.media.down"):$r("app.media.right"))
                    .width(30)
                    .onClick(()=>{
                      this.isLifeExpand=!this.isLifeExpand
                    })
                  Image($r("app.media.plus"))
                    .width(30)
                    //创建生活任务函数
                    .onClick(()=>{
                      //todo:
                    })
                }
                .margin({right:10})
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .height(50)
              .width("100%")
              .backgroundColor(Color.Green)
            }
            .margin({top:10})

            //生活任务内容
            if(this.isLifeExpand){
              ForEach(this.taskNum==0?this.getLifeTask(this.todayTaskList):this.getLifeTask(this.allTaskList),(item:TaskItem)=>{
                ListItem(){
                  Row(){
                    Column({space:10}){
                      Text(item.name)
                      Text(this.formatTime(item.dueTime))
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({left:10})
                  }
                  .borderRadius(25)
                  .width("100%")
                  .height(80)
                  .backgroundColor(Color.Yellow)
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