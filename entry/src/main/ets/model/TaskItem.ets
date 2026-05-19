export enum Priority{//优先级枚举
  HIGH=2,
  MEDIUM=1,
  LOW=0
}

export interface TaskItem{
  id:string//用的string类型
  name:string//任务名
  dueTime:Date//截止时间，时间戳
  priority:number//优先级，自定义Priority
  isFinished:boolean//是否完成
}