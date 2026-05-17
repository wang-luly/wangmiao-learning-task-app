export type taskCategory = '学习'|'生活'
export interface TaskItem{
  id:string
  dueTime:Date//截止时间，时间戳
  name:string//任务名
  category:taskCategory //任务分类：学习，生活...
}