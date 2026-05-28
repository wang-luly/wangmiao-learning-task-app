import { notificationManager } from "@kit.NotificationKit";
import { abilityAccessCtrl, common, Permissions } from "@kit.AbilityKit";
import { taskDB } from "../database/TaskDatabase";
import { TaskSignal } from "@kit.CoreFileKit";
import { taskStore, TaskStore } from "../model/TaskStore";
import { reminderAgentManager } from "@kit.BackgroundTasksKit";
import { TaskItem } from "../model/TaskItem";
import { preferences } from "@kit.ArkData";
import { calendarManager } from "@kit.CalendarKit";
import { isSimulationMode } from "../config/AppConfig";

//提醒ID
let tomorrowReminderId:number|null=null

//Preference用来持久化日程id
const CALENDAR_PREF_NAME='calendar_reminder_store'//Preferences文件名
const CALENDAR_EVENT_ID_KEY='morningEventId'//存上次创建的日程id
//写入系统日历的日程标题
const MORNING_EVENT_TITLE='待办任务提醒'
//提醒时间
const REMINDER_HOUR=8 //设置为8：00
const REMINDER_MINUTE=0
//为了方便调试
const USE_TEST_REMINDER_TIME=true
//内存中的日程id
let morningEventid:number|null=null
//避免并发，防止refresh重入
let isRefreshingReminder=false

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
    //通知渠道类型
    notificationSlotType:notificationManager.SlotType.SOCIAL_COMMUNICATION,//通知类型
    content:{
      //普通文本：标题+正文
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
  if(isSimulationMode()){
    await sendNotify("今日学习任务已达标","今日已学习 240 分钟，恭喜完成目标 240 分钟")
  }
  else{
    //真实完成指定今日时长
    if(todayTime>=triggerTime){
      await sendNotify(
        "今日学习任务已达标",
        `今日已学习 ${todayTime} 分钟，恭喜完成目标${triggerTime} 分钟`
      )
    }
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

//申请普通通知权限
export async function requestNotificationPermission(): Promise<void> {
    try {
      //弹出系统是否允许通知
      await notificationManager.requestEnableNotification();
      console.info('[notification] 通知权限请求已发送');
    } catch (err) {
      let error = err as BusinessError;
      console.error(`[notification] 请求通知权限失败: ${error.code}, ${error.message}`);
    }
}

//申请日历权限
export  async function requestCalendarPermission():Promise<boolean>{
  if(!appContext){
    console.log('[calendar] appContext未初始化无法申请权限')
    return false
  }
  const permissions:Permissions[]=['ohos.permission.READ_CALENDAR','ohos.permission.WRITE_CALENDAR']
  try {
    //创建权限管理器实例
    const atManager = abilityAccessCtrl.createAtManager()
    //弹出系统权限对话框，让用户选择允许或拒绝
    const result = await atManager.requestPermissionsFromUser(appContext,permissions)
    //检查每一项是否都是PERMISSION_GRANTED
    const granted=result.authResults.every((status)=> status===abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)//每一项用户都点了允许
    if(!granted){
      console.log('[calendar] 日历权限未全部授予，请到系统设置手动打开')
    }
    return granted
  }catch (err) {
    //类型断言
    const error=err as BusinessError
    console.error(`[calendar] 申请权限异常： ${error.code},${error.message}`)
    return false
  }
}

//刷新明天提醒通知 Calendar Kit
export async function refreshTomorrowReminder() {
  //防止重复进入
  if(isRefreshingReminder){
    console.info('[calendar] 正在刷新，跳过重复调用')
    return
  }
  if(!appContext){
    console.error('[calendar] appContext未初始化')
    return
  }
  isRefreshingReminder=true

  try{
    //确认日程权限，这里已经授权过了不会再次弹窗
    const hasPermission = await requestCalendarPermission()
    if(!hasPermission){
      return
    }
    //获取系统日历对象，拿到系统日历管理器
    const calendarMgr=calendarManager.getCalendarManager(appContext)
    //拿到默认日历
    const calendar=await calendarMgr.getCalendar()
    //删除旧日程
    await deleteMorningCalendarEvent(calendar)
    //从数据库加载最新任务
    await taskStore.loadTasks()
    //计算提醒时间
    const remindTime=getNextReminderTime()
    //计算提醒日当天的任务
    const tasks=getTaskNotFinished(remindTime)
    const dbTasks=await taskDB.queryAllTask()
    console.info(`[calendar] 直接查数据库任务数为${dbTasks.length}`)
    console.info(`[calendar] 提醒时间=${remindTime.toLocaleString()},任务数=${tasks.length}`)
    //没有任务就只删除旧日程，不创建新的
    if(tasks.length===0){
      console.info('[calendar] 无待提醒任务，结束')
      return
    }

    //拼接通知内容
    const taskNames=tasks.map(t=>t.name).join('、')
    //将开始时间设置为下一次提醒时间
    const startTime=remindTime.getTime()

    //构造日历事件
    const event:calendarManager.Event={
      type:calendarManager.EventType.NORMAL,  //普通日程
      title:MORNING_EVENT_TITLE,              //日历里显示的标题，变量
      description:`你有${tasks.length}个任务需要完成：${taskNames}`,//通知正文
      startTime:startTime,
      endTime:startTime+30*60*1000,             //占位
      isAllDay:false,                          //非全天事件
      reminderTime:[0]                        //提前0分钟开始提醒
    }

    //写入系统日历
    //调用日历自带函数
    const eventId = await calendar.addEvent(event)
    await saveStoredEventId(eventId)
    console.info(`[calendar] 日程创建成功 id=${eventId}`)

  }catch (err) {
    const error =err as BusinessError
    console.error(`[calendar] 刷新失败 ${error.code},${error.message}`)
  } finally {
    isRefreshingReminder=false
  }
}

/**
 * 计算下一次提醒的时间，测试模式：当前时间加2min，正式模式每天8：00
 */
function getNextReminderTime():Date {
  //测试模式:将下次提醒时间定到创建app的后两分钟
  if(isSimulationMode()){
    const testTime=new Date()
    testTime.setMinutes(testTime.getMinutes()+2)
    testTime.setSeconds(0,0)
    return testTime
  }
  //正式模式
  const now=new Date()
  const target=new Date()
  target.setHours(REMINDER_HOUR,REMINDER_MINUTE,0,0)
  //如果今日定时已过，则提醒时间订到明天
  if(now.getTime()>=target.getTime()){
    target.setDate(target.getDate()+1)
  }
  return target
}

/**
 * 获取某一天到期且未完成的任务
 */
function getTaskNotFinished(date: Date) :TaskItem[]{
  return taskStore.tasks.filter((item)=>
    item.isFinished===false &&
    item.dueTime.getFullYear()===date.getFullYear()&&
    item.dueTime.getMonth()===date.getMonth()&&
    item.dueTime.getDate()===date.getDate()
  )
}

/**
 * 从Preference读取上次创建的日程id
 */
async function loadStoredEventId():Promise<number|null> {
  //不为空，有上次创建的id，直接返回
  if(morningEventid!==null)
    return morningEventid
  if(!appContext)
    return null
  //得到对象
  const pref=await preferences.getPreferences(appContext,CALENDAR_PREF_NAME)
  const storedId=await pref.get(CALENDAR_EVENT_ID_KEY,-1) as number
  //-1代表从未创建过
  if(storedId>=0){
    morningEventid=storedId
  }
  return morningEventid
}

/**
 * 把日程id保存到内存+Preferences
 * @param id:number|null
 */
async function saveStoredEventId(id:number|null ) {
  //内存变量方便快速读
  morningEventid=id
  if(!appContext){
    return
  }
  //得到名为  的对象
  const pref =await preferences.getPreferences(appContext,CALENDAR_PREF_NAME)
  //把参数id存进pref，空或者未定义都存-1
  await pref.put(CALENDAR_EVENT_ID_KEY,id??-1)//空值合并
  //put之后数据还在缓冲区，要等flush之后才真正落盘
  await pref.flush()
}

/**
 * 删除旧的日历日程
 */
async function deleteMorningCalendarEvent(calendar:calendarManager.Calendar) {
  //从Preference读id
  const storedId = await loadStoredEventId()
  if(storedId===null){//没有日程id就不执行删除函数
    return
  }

  try{
    await calendar.deleteEvent(storedId)
    console.info(`[calendar] 已经删除旧日程id ${storedId}`)
  }catch (err) {
    const error=err as BusinessError
    console.warn(`[calendar] 删除旧日程失败： ${error.code},${error.message}`)
  }
  await saveStoredEventId(null)//
}












