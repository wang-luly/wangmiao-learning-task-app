import { TaskItem } from "../model/TaskItem";
import { taskDB } from "../database/TaskDatabase";
import { refreshTomorrowReminder } from "../utils/NotificationUtils";

@Observed
export class TaskStore {
  //tasks数组存所有任务
  tasks: TaskItem[] = []
  //查询数据库所有任务
  async loadTasks() {
    this.tasks = await taskDB.queryAllTask()
  }
  //添加任务
  async addTask(task: TaskItem) {
    await taskDB.insertTask(task)
    this.tasks.push(task)
    this.loadTasks()
    //刷新明日通知
    await refreshTomorrowReminder()
  }
  //更新任务
  async updateTask(task: TaskItem) {
    //函数内部id匹配，修改相应任务
    await taskDB.updateTask(task)//自动找数据库里id
    let index = this.tasks.findIndex(t => t.id === task.id)
    if (index !== -1) {
      TaskItem.applyFrom(this.tasks[index], task)
      this.tasks = [...this.tasks]
    }
    //刷新明日通知
    await refreshTomorrowReminder()
  }
  //删除任务
  async removeTask(id: string) {
    await taskDB.deleteTask(id)
    this.tasks = this.tasks.filter(t => t.id !== id)
    //刷新明日通知
    await refreshTomorrowReminder()
  }
  //得到今日任务
  getToday() {
    let now = new Date()
    return this.tasks.filter(t =>
      !t.isFinished &&
      t.dueTime.getFullYear() === now.getFullYear() &&
      t.dueTime.getMonth() === now.getMonth() &&
      t.dueTime.getDate() === now.getDate()
    )
  }

  //得到明日且未完成任务
  getTomorrow() {
    let tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate()+1)
    //过滤器选择年月日相同的写进数组
    return this.tasks.filter(t =>
    !t.isFinished&&
    t.dueTime.getFullYear() === tomorrow.getFullYear() &&
      t.dueTime.getMonth() === tomorrow.getMonth() &&
      t.dueTime.getDate() === tomorrow.getDate()
    )
  }
}
//单例模式taskStore，全局共用一份tasks和方法
export const taskStore = new TaskStore()