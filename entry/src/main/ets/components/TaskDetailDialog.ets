import { TaskItem } from "../model/TaskItem"

@CustomDialog
//详情对话框
export struct TaskDetailDialog{
  controller:CustomDialogController
  @State taskName:string=''
  @State count:number=0
  @State minute:number=0
  task:TaskItem|null=null
  aboutToAppear(): void {
    if(this.task){
      this.taskName=this.task.name
      this.count=this.task.studyCount
      this.minute=this.task.studyMinute
    }
  }
  //编辑
  editClick:()=>void=()=>{}
  //完成
  finishClick:()=>void=()=>{}
  //删除
  deleteClick:()=>void=()=>{}

  build(){
    Column({space:20}){
      Text(this.task!.name)//任务名
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text(`专注次数：${this.task!.studyCount}`)
      Text(`累计学习：${this.task!.studyMinute}分钟`)
      Row({space:20}){
        Button("编辑")
          .onClick(()=>{
            this.editClick()
          })
        Button("完成")
          .onClick(()=>{
            this.finishClick()
          })
        Button("删除")
          .onClick(()=>{
            this.deleteClick()

          })
      }
    }
    .padding(20)
    .width("80%")
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}