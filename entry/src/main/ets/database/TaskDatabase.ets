import relationalStore from '@ohos.data.relationalStore';
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
    //创建任务表
    await this.store.executeSql(
      `
       CREATE TABLE IF NOT EXISTS task(
         id TEXT PRIMARY KEY,
         name TEXT,
         dueTime INTEGER,
         isFinished INTEGER
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
        isFinished:task.isFinished?1:0
      }
    )
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
      taskList.push({
        id:result.getString(result.getColumnIndex('id')),
        name:result.getString(result.getColumnIndex('name')),
        dueTime:new Date(result.getLong(result.getColumnIndex('dueTime'))),
        isFinished:result.getLong(result.getColumnIndex('isFinished'))==1
      })
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

}
//导出数据库单例(软件设计模式中的单例模式)
export const taskDB=new TaskDatabase()