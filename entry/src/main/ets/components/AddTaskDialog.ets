@CustomDialog
export struct AddTaskDialog{
  //弹窗控制器用来控制弹窗是否关闭
  controller:CustomDialogController
  @State taskName:string=''
  @State dueTime:Date=new Date()//选择的时间
  @State startTime:Date=new Date()//可供选择的起始时间
  @State endTime:Date=new Date()

  //生命周期(钩子)函数---------------------------
  aboutToAppear(): void {
    let now=new Date()
    this.startTime=new Date(now)
    this.endTime=new Date(now)
    this.endTime.setFullYear(this.endTime.getFullYear()+1)
  }
  //点击确定后的回调函数
  @Prop confirm:(taskName:string,dueTime:Date)=>void = ()=>{}
  //--------------------------------build---------------------------------------

  build() {
    Column({space:20}){
      //标题
      Text("创建任务")
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
      //输入框
      TextInput({
        placeholder:"请输入任务名称",
        text:this.taskName
      })
        .width('100%')
        .onChange((value)=>{
          this.taskName=value
        })
      //日期选择器
      Column({ space: 6 }) {

        Text("截止时间")
        Column() {
          DatePicker({
            start: this.startTime,
            end: this.endTime,
            selected: this.dueTime
          })
            .onDateChange((value: Date) => {
              this.dueTime = value
            })
        }
        .padding(10)
        .height(70)
        .backgroundColor("#F5F6F7")
        .borderRadius(12)
      }

      //按钮区域
      Row({space:20}){
        Button("取消").onClick((event: ClickEvent) => {
          this.controller.close()
        })
        Button("确定").onClick((event: ClickEvent) => {
          //调用外部函数,因为避免让dialog需要依赖taskList
          this.confirm(this.taskName,this.dueTime)
          //关闭弹窗
          this.controller.close()
        })
      }
    }
    .width(300)
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}