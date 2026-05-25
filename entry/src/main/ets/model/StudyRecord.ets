
@Observed
export class StudyRecord{
  id:string=''  //学习记录表的id
  taskId:string=''  //对应的任务Id
  studyMinute:number=0//记录每一次学习分钟
  studyDate:Date=new Date()//学习日期

  constructor(id: string, taskId: string, studyMinute: number, studyDate: Date) {
    this.id = id
    this.taskId = taskId
    this.studyMinute = studyMinute
    this.studyDate = studyDate
  }


}