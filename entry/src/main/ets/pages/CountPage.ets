import { taskDB } from "../database/TaskDatabase"
@Component
export struct CountPage {
  //今日学习总时长
  @State todayMinute:number=0
  //目标学习时长
  @State targetMinute:number=120
  //近七天学习时长
  @State weekData:number[]=[]
  //Canvas画布
  private settings:RenderingContextSettings=new RenderingContextSettings(true)
  private ctx:CanvasRenderingContext2D=
    new CanvasRenderingContext2D(this.settings)
  //===============================函数======================================
  async aboutToAppear(){//todo:这个到底什么时候执行
    //从数据库中获取今日学习总时长
    this.todayMinute=await taskDB.queryTodayStudyMinute()
    //从数据库中获取近七天学习时长
    this.weekData=await taskDB.queryLast7Days()

  }

  //=============================UI=============================================
  build() {
    Column({space:20}){
      //今日学习进度------------------------------------
      Column({space:10}){
        Text(`今日已学习 ${this.todayMinute} 分钟/目标 ${this.targetMinute} 分钟`)
          .fontSize(20)
        Row({space:10}){
          Progress({
            value:this.todayMinute,//当前进度
            total:this.targetMinute,//总进度，目前定好120//todo：后续可自己选择
            type:ProgressType.Capsule//进度条类型
          })
            .height(30)
            .width(100)
          //进度百分比
          Text(
            `${Math.floor(this.todayMinute/this.targetMinute*100)}%`
          )
        }
      }
      //近期日学习柱状图//todo:柱状图
      Column(){
        Text("近七日学习情况")
          .fontSize(20)
        //柱状图(绑定ctx)
          Canvas(this.ctx)
            .width(300)
            .height(200)
            .backgroundColor('#f5f5f5')
            .onReady(()=>{
              const baseY=180
              this.weekData.forEach((v,i)=>{
                const h=(v/Math.max(...this.weekData))*baseY
                //柱子
                this.ctx.fillStyle='#66f5f5f5'
                //(x,baseY-h,w,h)
                //起始20，宽20，
                this.ctx.fillRect(20+i*30,baseY-h,20,h)
                //柱子上的数字
                this.ctx.fillStyle='#333'
                this.ctx.font='16px'
                this.ctx.textAlign='center'
                this.ctx.fillText(v.toString(),30+i*30,baseY-5)
              })
            })
        }
    }
    .width("100%")
    .height("100%")
  }
}