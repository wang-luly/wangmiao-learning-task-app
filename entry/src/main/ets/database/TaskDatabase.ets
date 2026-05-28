import relationalStore from '@ohos.data.relationalStore';
import { StudyRecord } from '../model/StudyRecord';
import { TaskItem } from '../model/TaskItem';

export class TaskDatabase{
  //类似于弹窗控制器controller
  private store:relationalStore.RdbStore|null=null
  //初始化数据库函数-------------------------------------
  async init(context:Context){
    //名字and安全系数
    const config:relationalStore.StoreConfig={
      name:'taskDB',
      securityLevel:relationalStore.SecurityLevel.S1
    }
    this.store=await relationalStore.getRdbStore(context,config)
    //创建任务表:注意isFinished是数字类型
    await this.store.executeSql(
      `
       CREATE TABLE IF NOT EXISTS task(
         id TEXT PRIMARY KEY,
         name TEXT,
         dueTime INTEGER,
         priority INTEGER,
         isFinished INTEGER,
         studyCount INTEGER,
         studyMinute INTEGER
       )
      `
    )
    await this.store.executeSql(
      `
         CREATE TABLE IF NOT EXISTS study_record(
          id TEXT PRIMARY KEY,
          taskId TEXT,
          studyMinute INTEGER,
          studyDate INTEGER
         )
      `
    )
  }
  //插入任务函数-----------------------------------------
  async insertTask(task:TaskItem){
    //先判断store是否存在
    if(!this.store) return
    //用store.insert(表名，对象)
    await this.store.insert(
      'task',
      {
        id:task.id,
        name:task.name,
        dueTime:task.dueTime.getTime(),
        priority:task.priority,
        isFinished:task.isFinished?1:0,
        studyCount:task.studyCount,
        studyMinute:task.studyMinute
      }
    )
  }
  //根据id查询任务
  async queryTaskById(id:string):Promise<TaskItem|null>{
    //判断store是否为空
    if(!this.store) return null
    //根据id得到数据库读取指针
    let result=await this.store.querySql(`SELECT * FROM task WHERE id=?`,[id])
    if(result.rowCount==0){
      return null
    }
    result.goToFirstRow()
    let task=this.resultToTask(result)
    result.close()
    return task
  }

  //查询所有任务函数---------------------------------------------
  async queryAllTask():Promise<TaskItem[]>{
    let taskList:TaskItem[]=[]
    //依然先判断store是否为空
    if(!this.store) return taskList
    //数据库游标，数据库读取指针
    let result=await this.store.querySql(
      `SELECT * FROM task`
    )
    while(result.goToNextRow()){
      let task=this.resultToTask(result)
      taskList.push(task)
    }
    result.close()
    return taskList
  }

  //删除数据库函数（根据id）----------------------------------------
  async deleteTask(id:string){
    if(!this.store) return
    //创建删除条件
    let predicates=new relationalStore.RdbPredicates('task')
    //设置删除条件
    predicates.equalTo('id',id)
    await this.store.delete(predicates)
  }
  //修改数据函数------------------------------------------------------
  async updateTask(task:TaskItem){
    if(!this.store) return
    let predicate=new relationalStore.RdbPredicates('task')
    predicate.equalTo('id',task.id)
    await this.store.update(
      {
        name:task.name,
        dueTime:task.dueTime.getTime(),
        priority:task.priority,
        isFinished:task.isFinished?1:0,
        studyCount:task.studyCount,
        studyMinute:task.studyMinute
      },
      predicate
    )
  }
  //查询结果转task对象
  private resultToTask(result: relationalStore.ResultSet): TaskItem {
    let task = new TaskItem()
    task.id = result.getString(
      result.getColumnIndex('id')
    )
    task.name = result.getString(
      result.getColumnIndex('name')
    )
    task.dueTime = new Date(result.getLong(
      result.getColumnIndex('dueTime')
    ))
    task.priority = result.getLong(
      result.getColumnIndex('priority')
    )
    task.isFinished = result.getLong(result.getColumnIndex('isFinished'))==1
    task.studyMinute = result.getLong(
      result.getColumnIndex('studyMinute')
    )
    task.studyCount = result.getLong(
      result.getColumnIndex('studyCount')
    )
    return task
  }
  //插入学习记录进学习记录表
  async insertRecord(record:StudyRecord){
    if(!this.store) return
    await this.store.insert(
      'study_record',
      {
        id:record.id,
        taskId:record.taskId,
        studyMinute:record.studyMinute,
        studyDate:record.studyDate.getTime()
      }
    )
  }

  //在学习记录表中查询今日学习总分钟
  async queryTodayStudyMinute():Promise<number>{
    if(!this.store) return 0
    let start=new Date()
    start.setHours(0)
    start.setMinutes(0)
    start.setSeconds(0)
    start.setMilliseconds(0)
    let end=new Date(start)
    end.setDate(end.getDate()+1)
    //将今天所有任务的studyMinute相加，只有一行
    let result=await this.store.querySql(
      `SELECT SUM(studyMinute) AS total FROM study_record WHERE studyDate>=? AND studyDate<=?`,
      [start.getTime(),end.getTime()]
    )

    if(result.rowCount==0){
      return 0
    }
    result.goToFirstRow()//来到学习记录表的第一行，也只有一行
    let total=result.getLong(
      result.getColumnIndex('total')
    )
    result.close()//别忘记关result
    return total
  }

  /** 近 7 天每日学习分钟，无记录的天为 0，与统计页日期标签顺序一致 */
  async queryLast7Days(): Promise<number[]> {
    //没有数据时，默认为0
    const empty7 = [0, 0, 0, 0, 0, 0, 0]
    //store为数据库句柄，打开失败
    if (!this.store) {
      return empty7
    }
    const startTime = new Date()
    startTime.setDate(startTime.getDate() - 6)//将开始时间设为六天前进行学习记录表数据库查找
    startTime.setHours(0, 0, 0, 0)
    const result = await this.store.querySql(
      `
        SELECT studyDate, SUM(studyMinute) as total
        FROM study_record
        WHERE studyDate>=?
        GROUP BY studyDate
        ORDER BY studyDate ASC
      `,
      [startTime.getTime()]
    )
    //存储日期->总分钟
    const dayMap = new Map<number, number>()
    while (result.goToNextRow()) {
      const studyDateMs = result.getLong(result.getColumnIndex('studyDate'))//学习日期
      const total = result.getLong(result.getColumnIndex('total'))//sum(StudyMinute) as total
      const day = new Date(studyDateMs)
      day.setHours(0, 0, 0, 0)
      const key = day.getTime()
      dayMap.set(key, (dayMap.get(key) ?? 0) + total)
    }
    result.close()

    const sevenDays: number[] = []//近七日学习时间数组
    for (let i = 6; i >= 0; i--) {//从后往前写日期
      const d = new Date()
      d.setDate(d.getDate() - i)//日期--
      d.setHours(0, 0, 0, 0)
      sevenDays.push(dayMap.get(d.getTime()) ?? 0)//map用key查找value
    }
    return sevenDays
  }

  //根据截止日期查询任务
  async queryTaskByDate(date:number):Promise<TaskItem[]>{
    const start=new Date(date)
    start.setHours(0,0,0,0)//date参数的00：00为开始区间
    const end=new Date(start)
    end.setDate(end.getDate()+1)//date参数的明日00：00为结束
    if(!this.store) return[]
    const result=await this.store.querySql(
      `
        SELECT * FROM task WHERE dueTime >= ? AND dueTime < ?
      `,[start.getTime(),end.getTime()]
    )
    let res:TaskItem[]=[]
    if(result.rowCount==0) return[]
    while (result.goToNextRow()) {
      let task=await this.resultToTask(result)
      res.push(task)
    }
    return res
  }

}
//导出数据库单例(软件设计模式中的单例模式)
export const taskDB=new TaskDatabase()