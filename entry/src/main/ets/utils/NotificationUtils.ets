import { notificationManager } from "@kit.NotificationKit";
import { common } from "@kit.AbilityKit";
import { taskDB } from "../database/TaskDatabase";
import { reminderAgentManager } from "@kit.BackgroundTasksKit";


//保存app全局上下文，用于后台通知
let appContext:common.UIAbilityContext|null=null

//初始化上下文，告诉系统是哪个app在运行
export function initNotificationContext(context:common.UIAbilityContext){
  appContext=context
}

//发送通知函数
export async function sendNotify(title:string,content:string){
  //如果没有app上下文，拒绝发送通知
  if(!appContext) return
  const request:notificationManager.NotificationRequest={
    id:200496,  //唯一id，相同id会覆盖原通知
    notificationSlotType:notificationManager.SlotType.SOCIAL_COMMUNICATION,//通知类型
    content:{
      notificationContentType:notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal:{
        title:title,
        text:content
      }
    }
  }
  //调用系统api发送通知
  await notificationManager.publish(request)
}

//今日时长达标通知
export async function todayTimeNotify(){
  //测试今日时长已达标
  const testTime=250
  //从数据库查询今日学习时长
  const  todayTime=await taskDB.queryTodayStudyMinute()
  if(testTime>=240){
    await sendNotify(
      "今日学习任务已达标",
      `今日已学习 ${testTime} 分钟，恭喜完成目标`
    )
  }
}
//检查今日有无要截至的任务,发送通知
export async function todayDueTime(){
  const today=new Date()
  //从数据库中找到截至日期为今天的任务列表
  const tasks=await taskDB.queryTaskByDate(today.getTime())
  if(tasks.length>0){
    const taskNames=tasks.map(t=>t.name).join('、')
    //发送今日到期任务提醒
    await sendNotify("今日有任务到期",`你有任务需要完成${taskNames}`)
  }
}
