import {Priority, TaskItem} from "../model/TaskItem";
import { AuxiliaryModifier, GHostButtonModifier, GoldenFillButtonModifier, TitleTextModifier } from "../theme/AppStyles";


@CustomDialog
export struct AddTaskDialog{
  //弹窗控制器用来控制弹窗是否关闭
  controller:CustomDialogController
  @State taskName:string=''//任务名
  @State dueTime:Date=new Date()//选择的时间
  @State startTime:Date=new Date()//可供选择的起始时间
  @State endTime:Date=new Date()//可供选择的结束时间
  @State priority:number=Priority.LOW//默认低优先级
  editingTask:TaskItem|null=null
  priorityList:SelectOption[]=[{value:"低"},{value:"中"},{value:"高"}]//优先级选择列表

  //生命周期(钩子)函数---------------------------
  aboutToAppear(): void {
    let now=new Date()
    this.startTime=new Date(now)
    this.endTime=new Date(now)
    this.endTime.setFullYear(this.endTime.getFullYear()+1)
    //如果是编辑模式，则显示原任务参数
    if(this.editingTask){
      this.taskName=this.editingTask.name
      this.dueTime=this.editingTask.dueTime
      this.priority=this.editingTask.priority
    }
  }
  //点击确定后的回调函数，不能加prop
  confirm:(taskName:string,dueTime:Date,priority:number)=>void = ()=>{}
  //--------------------------------build---------------------------------------

  build() {
    Column({space:20}){
      //标题
      Text(this.editingTask ? "编辑任务" : "创建任务")
        .attributeModifier(new TitleTextModifier())
        .fontSize(20)
      //输入框
      TextInput({
        placeholder:"请输入任务名称",
        text:this.taskName
      })
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_muted'))
        .backgroundColor($r('app.color.bg_elevated'))
        .borderRadius(8)
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .onChange((value)=>{
          this.taskName=value
        })
      //日期选择器
      Column({ space: 6 }) {

        Text("截止时间")
          .attributeModifier(new AuxiliaryModifier())
        Column() {
          DatePicker({
            start: this.startTime,
            end: this.endTime,
            selected: this.dueTime
          })
            .selectedTextStyle({
              color: '#C9A962',
              font: { size: 18, weight: FontWeight.Medium }
            })
            .disappearTextStyle({
              color: '#9A9A9A',
              font: { size: 14, weight: FontWeight.Regular }
            })
            .textStyle({
              color: '#5C5C5C',
              font: { size: 15, weight: FontWeight.Regular }
            })
            .onDateChange((value: Date) => {
              this.dueTime = value
            })
        }
        .padding(10)
        .height(70)
        .backgroundColor($r('app.color.bg_elevated'))
        .borderRadius(8)
        .border({ width: 1, color: $r('app.color.border_subtle') })
      }
      //优先级选择
      Row(){
        Text("优先级")
          .width("30%")
          .attributeModifier(new AuxiliaryModifier())
        Select(this.priorityList)
          .selected(this.priority)
          .value(this.priorityList[this.priority].value)
          .font({ size: 15 })
          .fontColor($r('app.color.text_primary'))
          .selectedOptionFont({ size: 15 })
          .optionFont({ size: 15 })
          .backgroundColor($r('app.color.bg_elevated'))
          .onSelect((index:number)=>{
            this.priority=index
          })
      }
      .width('100%')

      //按钮区域
      Row({space:20}){
        Button("取消")
          .attributeModifier(new GHostButtonModifier())
          .layoutWeight(1)
          .onClick((event: ClickEvent) => {
          this.controller.close()
        })
        Button("确定")
          .attributeModifier(new GoldenFillButtonModifier())
          .layoutWeight(1)
          .onClick((event: ClickEvent) => {
          if(!this.taskName||this.taskName.trim().length==0){
            this.getUIContext().getPromptAction().showToast({
              message:'无法创建，你还没有输入任务名哦'
            })
            return
          }
          //调用外部函数,因为避免让dialog需要依赖taskList
          this.confirm(this.taskName,this.dueTime,this.priority)
          //关闭弹窗
          this.controller.close()
        })
      }
    }
    .width(300)
    .padding(20)
    .backgroundColor($r('app.color.bg_secondary'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_subtle') })
  }
}