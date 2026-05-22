import { taskDB } from "../database/TaskDatabase"
@Component
export struct CountPage {
  //今日学习总时长
  @State todayMinute:number=0
  //目标学习时长
  @State targetMinute:number=120
  //===============================函数======================================
  async aboutToAppear(){
    //从数据库中获取今日学习总时长
    this.todayMinute=
      await taskDB.queryTodayStudyMinute()
  }

  //=============================UI=============================================
  build() {
    Column({space:20}){
      Text("今日学习统计")
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
      Text(`今日已学习 ${this.todayMinute} 分钟`)
        .fontSize(20)
      Progress({
        value:this.todayMinute,
        total:this.targetMinute,
        type:ProgressType.Linear
      })
        .width("80%")
      Text(
        `${Math.floor(this.todayMinute/this.targetMinute*100)}%`
      )
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Center)
  }
}