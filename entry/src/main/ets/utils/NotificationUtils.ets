import { notificationManager } from "@kit.NotificationKit";
import { common } from "@kit.AbilityKit";
import { taskDB } from "../database/TaskDatabase";
import { TaskSignal } from "@kit.CoreFileKit";
import { taskStore, TaskStore } from "../model/TaskStore";


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
  const triggerTime:number=0
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

//检查今日有无要截至的任务,发送通知
export async function todayDueTimeNotify(){
  console.info('[DEBUG] todayDueTimeNotify() 被调用');
  await taskStore.loadTasks()
  const today=new Date()
  console.info('[DEBUG] 今天日期:', today.toLocaleDateString());
  console.info('[DEBUG] 今天时间戳:', today.getTime());

  // 先查询所有任务
  const allTasks=await taskDB.queryAllTask();
  console.info('[DEBUG] 数据库中所有任务数量:', allTasks.length);

  allTasks.forEach((t, index) => {
    const taskDate = new Date(t.dueTime);
    console.info(`[DEBUG] 任务${index}:`, {
      name: t.name,
      dueDate: taskDate.toLocaleDateString(),
      dueTimestamp: t.dueTime,
      isToday: taskDate.toDateString() === today.toDateString()
    });
  });

  //再查询今日任务
  const tasks=await taskStore.getToday()
  console.info('[DEBUG] 查询到今日任务数量:', tasks.length);

  if(tasks.length>0){
    const taskNames=tasks.map(t=>t.name).join('、')
    console.info('[DEBUG] 今日任务名称:', taskNames);
    await sendNotify("今日有任务到期",`你有 ${tasks.length} 任务需要完成: ${taskNames}`)
    console.info('[DEBUG] 通知已发送');
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


