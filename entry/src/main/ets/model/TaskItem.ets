export enum Priority{//优先级枚举
  HIGH=2,
  MEDIUM=1,
  LOW=0
}
@Observed
export class  TaskItem{
  id:string=''//用的string类型1
  name:string=''//任务名2
  dueTime:Date=new Date()//截止时间3
  priority:number=0//优先级，自定义Priority4
  isFinished:boolean=false//是否完成5
  studyCount:number=0//专注学习次数6
  studyMinute:number=0//记录这个任务总学习时长学习分钟7
  //一个task赋值给另一个task
  static copyTask(task:TaskItem):TaskItem{
    let newTask=new TaskItem()
    newTask.id=task.id
    newTask.name=task.name
    newTask.dueTime=new Date(task.dueTime)//Date是引用类型，必须new Date
    newTask.priority=task.priority
    newTask.isFinished=task.isFinished
    newTask.studyCount=task.studyCount
    newTask.studyMinute=task.studyMinute
    return newTask
  }
}