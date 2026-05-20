import { TaskItem } from "../model/TaskItem";
//降序排序
export function setPriorityDesc(taskList:TaskItem[]):TaskItem[]{
  return [...taskList].sort((a,b)=>
    b.priority-a.priority
  )
}
//升序排序
export function setPriorityAsc(taskList:TaskItem[]):TaskItem[]{
  return [...taskList].sort((a,b)=>
    a.priority-b.priority
  )
}
