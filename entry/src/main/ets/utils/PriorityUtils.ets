export function getPriorityText(pri:number):string{
  switch (pri){
    case 0:
      return '低优先级'
    case 1:
      return '中优先级'
    case 2:
      return '高优先级'
    default :
      return ''
  }
}