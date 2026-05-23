import { taskDB } from "../database/TaskDatabase";
import { TaskItem } from "../model/TaskItem";
import { TaskStore,taskStore } from "../model/TaskStore";
import { data } from "@kit.TelephonyKit";
import { StudyRecord } from "../model/StudyRecord";
import { util } from "@kit.ArkTS";
import { todayTimeNotify } from "../utils/NotificationUtils";

@Entry
@Component
export struct TimingPage {
  @State store:TaskStore=taskStore//全区唯一任务卡
  @State taskId:string=''
  @State taskName:string='学习任务'
  @State second:number=0
  //用于setInterval返回值,-1没有开启计时器
  timer:number=-1
  task:TaskItem|null=null//记录此任务
  //==================================函数=============================================
  async aboutToAppear(){
    let router=this.getUIContext().getRouter()
    let params=router.getParams() as Record<string,string>
    this.taskId=params['taskId']
    //得到数据库此id对应任务的真实数据
    let currentTask=await taskDB.queryTaskById(this.taskId)
    //task用来记录此任务
    if(currentTask){
      this.taskName=currentTask.name
      this.task=currentTask
    }
  }
  //开始计时
  startTimer(){
    if(this.timer!=-1) return
    this.timer=setInterval(()=>{
      this.second++
    },1000)
  }
  //暂停计时
  pauseTimer(){
    if(this.timer==-1) return
    clearInterval(this.timer)
    this.timer=-1
  }
  //结束学习
  async finishTimer(){
    //如果计时器没有结束
    if(this.timer!=-1){
      clearInterval(this.timer)
      this.timer=-1
    }
    let minute=Math.floor(this.second/60)
    //点击结束按钮时，判断minute是否>0，如果为0，弹出窗口提示学习未满一分钟，不会计入学习时长，是否退出，下面有继续学习和退出两个按钮
    if(minute==0) {
      this.getUIContext().getPromptAction().showDialog({
        title:'温馨提示',
        message:'学习时长过短，不会计入学习时长',
        buttons:[
        {text:'继续学习',color:'#000'},
        {text:'坚持退出',color:'#f00'}
        ]
      },(err,data)=>{
        if(data.index==1){
          this.backPage()
        }else if(data.index==0){//继续学习
          this.startTimer()
        }
      })
      return
    }
    //累加学习时长，学习次数
    if(this.task){
      this.task.studyCount+=1
      this.task.studyMinute+=minute
      //更新任务卡
      await this.store.updateTask(this.task)
      //更新学习记录
      let record=new StudyRecord(
        util.generateRandomUUID(),
        this.task.id,
        minute,
        new Date()
      )
      //写进数据库里
      await taskDB.insertRecord(record)
      //点击结束后检查今日学习时长是否达标
      await todayTimeNotify()
    }
    //最后将second重置为0
    this.second=0
    this.backPage()
  }
  //显示时间格式化
  formatTime():string{
    let minute=Math.floor(this.second/60)
    let second=this.second%60
    //不足两位补两位
    return `${minute.toString().padStart(2,'0')}:${second.toString().padStart(2,'0')}`
  }
  //返回上一页
  backPage(){
    let router=this.getUIContext().getRouter()
    router.back()
  }
  //===================================UI===========================================
  build() {
    Column({ space: 40 }) {
      //任务名
      Text(this.taskName)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
      //中间时钟显示
      Text(this.formatTime())
        .fontSize(60)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
      //按钮
      Row({ space: 20 }) {
        Button("开始")
          .onClick(() => {
            this.startTimer()
          })
        Button("暂停")
          .onClick(() => {
            this.pauseTimer()
          })
        Button("结束")
          .onClick(() => {
            this.finishTimer()
          })
      }
    }
    // 页面宽度100%
    .width('100%')
    // 页面高度100%
    .height('100%')

    // 整体居中
    .justifyContent(FlexAlign.Center)
  }
}