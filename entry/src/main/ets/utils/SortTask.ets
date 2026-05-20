import { TaskItem } from "../model/TaskItem";

export function SortTask(taskList:TaskItem[],isDesc:boolean):TaskItem[]{
  return [...taskList].sort((a,b)=>{
    //先按时间升序排序,忽略时分秒
    let yearA=a.dueTime.getFullYear()
    let monthA=a.dueTime.getMonth()
    let dayA=a.dueTime.getDate()

    let yearB=b.dueTime.getFullYear()
    let monthB=b.dueTime.getMonth()
    let dayB=b.dueTime.getDate()

    //转换成当天0点时间戳
    let dateA=new Date(yearA,monthA,dayA).getTime()
    let dateB=new Date(yearB,monthB,dayB).getTime()

    //先比较日期
    if(dateA!=dateB){
      return dateA-dateB
    }
    //再按优先级排序：分为升序和降序
    if(isDesc){
      return b.priority-a.priority
    }
    else{
      return a.priority-b.priority
    }
  })
}