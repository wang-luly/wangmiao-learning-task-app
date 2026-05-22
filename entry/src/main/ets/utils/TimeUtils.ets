//标准时间格式函数
export function formatTime(time:Date):string{
  let year=time.getFullYear()
  let month=time.getMonth()+1
  let day=time.getDate()
  return `${year}-${month.toString().padStart(2,'0')}-${day.toString().padStart(2,'0')}`
}
