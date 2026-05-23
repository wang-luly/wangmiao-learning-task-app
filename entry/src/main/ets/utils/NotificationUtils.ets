import { notificationManager } from "@kit.NotificationKit";
import { common } from "@kit.AbilityKit";
import { taskDB } from "../database/TaskDatabase";
import { TaskSignal } from "@kit.CoreFileKit";
import { taskStore, TaskStore } from "../model/TaskStore";
import { reminderAgentManager } from "@kit.BackgroundTasksKit";

//提醒ID
let tomorrowReminderId:number|null=null

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
  //目标时间
  const triggerTime:number=240
  //测试今日时长已达标
  const testTime=250
  //从数据库查询今日学习时长
  let todayTime:number=await taskDB.queryTodayStudyMinute()//这里必须用数据库，因为store没写
  //真实完成指定今日时长
  if(todayTime>=triggerTime){
    await sendNotify(
      "今日学习任务已达标",
      `今日已学习 ${todayTime} 分钟，恭喜完成目标${triggerTime} 分钟`
    )
  }
  // //测试完成指定今日时长
  // if(testTime>=triggerTime){
  //   await sendNotify(
  //     "今日学习任务已达标",
  //     `今日已学习 ${testTime} 分钟，恭喜完成目标${triggerTime} 分钟`
  //   )
  // }
}

//检查今日有无要截至的任务,发送通知=====================
export async function todayDueTimeNotify(){
  console.info('[DEBUG] todayDueTimeNotify() 被调用');
  //先加载数据库内容到单例tasks中
  await taskStore.loadTasks()
  const today=new Date()
  console.info('[DEBUG] 今天日期:', today.toLocaleDateString());
  console.info('[DEBUG] 今天时间戳:', today.getTime());


  //查询今日任务
  let tasks=await taskStore.getToday()
  console.info('[DEBUG] 查询到今日任务数量:', tasks.length);
  tasks=tasks.filter((item)=>{
    return item.isFinished==false
  })
  console.info('[DEBUG] 查询到未完成的任务数量:',tasks.length)
  if(tasks.length>0){
    const taskNames=tasks.map(t=>t.name).join('、')
    await sendNotify("今日有任务到期",`你有 ${tasks.length} 任务需要完成: ${taskNames}`)
  } else {
    console.info('[DEBUG] 今日没有到期任务');
  }
}

//请求通知权限
export async function requestNotificationPermission(): Promise<void> {
    try {
      await notificationManager.requestEnableNotification();
      console.info('通知权限请求已发送');
    } catch (err) {
      let error = err as BusinessError;
      console.error(`请求通知权限失败: ${error.code}, ${error.message}`);
    }
}

//刷新明天提醒通知
export async function refreshTomorrowReminder() {
  console.log('[debug] 1. 开始')

  try {
    const before = await reminderAgentManager.getValidReminders()
    console.log('[debug] 取消前数量 =', before.length)

    await reminderAgentManager.cancelAllReminders()
    tomorrowReminderId=null
    console.log('[debug] 删除所有id')

    // 等 2 秒让系统释放配额
    await new Promise<void>((resolve) => {
      setTimeout(() => resolve(), 2000)
    })

    const after = await reminderAgentManager.getValidReminders()
    console.log('[debug] 取消后数量 =', after.length)  // 应该是 0
    // if (tomorrowReminderId) {
    //   console.log('[debug] 2. 取消旧提醒', tomorrowReminderId)
    //   await reminderAgentManager.cancelReminder(tomorrowReminderId)
    //   tomorrowReminderId = null
    // }

    console.log('[debug] 3. 开始 loadTasks')
    await taskStore.loadTasks()

    const tasks = taskStore.getTomorrow()
    console.log('[debug] 4. 明天任务数 =', tasks.length)

    if (tasks.length === 0) {
      console.log('[debug] 5. 明天没有任务，结束')
      return
    }

    const trigger = new Date()
    trigger.setMinutes(trigger.getMinutes() + 2)

    const reminderReq: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: {
        year: trigger.getFullYear(),
        month: trigger.getMonth() + 1,
        day: trigger.getDate(),
        hour: trigger.getHours(),
        minute: trigger.getMinutes(),
        second: 0
      },
      title: '待办任务提醒',
      content: `你还有${tasks.length}个任务未完成`,
      notificationId: 200495,
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      ringDuration: 0
    }

    console.log('[debug] 6. 准备注册提醒', JSON.stringify(reminderReq.dateTime))
    tomorrowReminderId = await reminderAgentManager.publishReminder(reminderReq)
    console.log('[debug] 7. 注册成功 id =', tomorrowReminderId)

  } catch (err) {
    const error = err as BusinessError
    console.error(`[debug] 出错: code=${error.code}, msg=${error.message}`)
  }
}