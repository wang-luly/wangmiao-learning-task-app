import { TaskItem } from "../model/TaskItem";
import { taskDB } from "../database/TaskDatabase";
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
  }
  //更新任务
  async updateTask(task: TaskItem) {
    //函数内部id匹配，修改相应任务
    await taskDB.updateTask(task)//自动找数据库里id
    let index = this.tasks.findIndex(t => t.id === task.id)
    if (index !== -1) {
      //引用赋值
      let newTask=TaskItem.copyTask(task)
      this.tasks[index]=newTask
      this.tasks=[...this.tasks]//强制出发数组响应式更新
    }
  }
  //删除任务
  async removeTask(id: string) {
    await taskDB.deleteTask(id)
    this.tasks = this.tasks.filter(t => t.id !== id)
  }
  //得到今日任务
  getToday() {
    let now = new Date()
    return this.tasks.filter(t =>
    t.dueTime.getFullYear() === now.getFullYear() &&
      t.dueTime.getMonth() === now.getMonth() &&
      t.dueTime.getDate() === now.getDate()
    )
  }
}
//单例模式taskStore，全局公用一份tasks和方法
export const taskStore = new TaskStore()