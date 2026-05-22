export function getPriorityText(pri:number):string{
  switch (pri){
    case 0:
      return '低'
    case 1:
      return '中'
    case 2:
      return '高'
    default :
      return ''
  }
}