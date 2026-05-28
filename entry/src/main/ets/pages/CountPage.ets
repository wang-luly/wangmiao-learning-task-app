import { common } from '@kit.AbilityKit'
import { isSimulationMode } from "../config/AppConfig"
import { taskDB } from "../database/TaskDatabase"
import { TitleTextModifier } from "../theme/AppStyles"
import { getPageSafeInsets } from "../utils/SafeAreaUtil"
@Component
export struct CountPage {
  //解决CountPage无法实时更新页面数据的bug
  @Prop @Watch('onRefreshTick') refreshTick:number=0
  @State topInset: number = 0
  @State bottomInset: number = 0
  //今日学习总时长
  @State todayMinute:number=0
  //目标学习时长
  @State targetMinute:number=240
  //近七天学习时长
  @State weekData:number[]=[]
  @State weekLabels: string[] = []
  //Canvas画布
  private settings:RenderingContextSettings=new RenderingContextSettings(true)
  //2D画笔ctx
  private ctx:CanvasRenderingContext2D=
    new CanvasRenderingContext2D(this.settings)
  //===============================函数======================================
  /**
   * 生命周期函数
   */
  async aboutToAppear(){
    const insets = await getPageSafeInsets(this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.topInset = insets.top
    this.bottomInset = insets.bottom
    //第一次调用加载学习数据函数，后续用onRefreshTick函数
    await this.loadStudyData()
    // if(isSimulationMode()){
    //   this.weekData=[30,50,60,40,20,10,90]
    //   this.todayMinute=100
    // }
    // else{
    //   this.todayMinute=await taskDB.queryTodayStudyMinute()
    //   this.weekData=await taskDB.queryLast7Days()
    // }
    // this.weekLabels = this.buildWeekLabels()
    // this.drawWeekChart()
  }

  /**
   * 实时监测,得到最新数据库里的学习数据函数
   */
  onRefreshTick():void{
    void this.loadStudyData()
  }

  /**
   * 加载数据函数
   */
  async loadStudyData():Promise<void>{
    if(isSimulationMode()){
      this.weekData=[30,50,60,40,20,10,90]
      this.todayMinute=100
    }
    else{
      this.todayMinute=await taskDB.queryTodayStudyMinute()
      this.weekData=await taskDB.queryLast7Days()
    }
    this.weekLabels = this.buildWeekLabels()
    this.drawWeekChart()
  }

  /** 生成近 7 天日期标签，如 5/18 */
  buildWeekLabels(): string[] {
    const labels: string[] = []
    for (let i = 6; i >= 0; i--) {
      const d = new Date()
      d.setDate(d.getDate() - i)
      labels.push(`${d.getMonth() + 1}/${d.getDate()}`)
    }
    return labels
  }
  /** 黑金主题柱状图 */
  drawWeekChart(): void {
    const W = 320
    const H = 220
    const padL = 20
    const padR = 16
    const padT = 24
    const padB = 36
    const chartW = W - padL - padR
    const chartH = H - padT - padB
    const baseY = padT + chartH

    this.ctx.clearRect(0, 0, W, H)

    const maxVal = Math.max(...this.weekData, 1)
    const dayCount = 7

    this.ctx.strokeStyle = '#2A2A2A'
    this.ctx.lineWidth = 1
    for (let i = 0; i <= 3; i++) {
      const y = padT + (chartH * i) / 3
      this.ctx.beginPath()
      this.ctx.moveTo(padL, y)
      this.ctx.lineTo(W - padR, y)
      this.ctx.stroke()
    }

    const barGap = 10
    const barW = (chartW - barGap * (dayCount - 1)) / dayCount

    for (let index = 0; index < dayCount; index++) {
      const value = this.weekData[index] ?? 0
      const barH = (value / maxVal) * chartH
      const x = padL + index * (barW + barGap)
      const y = baseY - barH

      if (barH > 0) {
        const gradient = this.ctx.createLinearGradient(x, y, x, baseY)
        gradient.addColorStop(0, '#E8D5A3')
        gradient.addColorStop(1, '#8B7355')
        this.ctx.fillStyle = gradient
        this.ctx.fillRect(x, y, barW, barH)
      }

      this.ctx.fillStyle = '#E8D5A3'
      this.ctx.font = '25px sans-serif'
      this.ctx.textAlign = 'center'
      this.ctx.textBaseline = 'bottom'
      const labelY = value === 0 ? baseY - 6 : y - 4
      this.ctx.fillText(`${value}`, x + barW / 2, labelY)

      this.ctx.fillStyle = '#9A9A9A'
      this.ctx.font = '25px sans-serif'
      this.ctx.textBaseline = 'top'
      this.ctx.fillText(this.weekLabels[index] ?? '', x + barW / 2, baseY + 8)
    }
  }
  //=============================UI=============================================
  build() {
    Column({ space: 24 }) {
      // 今日进度卡片
      Column({ space: 12 }) {
        Text(`今日已学习 ${this.todayMinute} 分钟`)
          .attributeModifier(new TitleTextModifier())
        Text(`目标 ${this.targetMinute} 分钟`)
          .attributeModifier(new TitleTextModifier())

        Row({ space: 12 }) {
          Progress({
            value: this.todayMinute,
            total: this.targetMinute,
            type: ProgressType.Capsule//胶囊形
          })
            .height(10)
            .width('80%')
            .color($r('app.color.gold_primary'))
            .backgroundColor($r('app.color.border_subtle'))

          Text(`${Math.min(100, Math.floor(this.todayMinute / this.targetMinute * 100))}%`)
            .fontSize(14)
            .fontColor($r('app.color.gold_primary'))
            .width(48)
            .textAlign(TextAlign.End)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.bg_secondary'))
      .borderRadius(12)
      .border({ width: 1, color: $r('app.color.border_subtle') })

      // 近七日柱状图卡片
      Column({ space: 12 }) {
        Text('近七日学习情况(min)')
          .attributeModifier(new TitleTextModifier())
        Canvas(this.ctx)
          .width(320)
          .height(220)
          .backgroundColor($r('app.color.bg_elevated'))
          .borderRadius(8)
          .onReady(() => {
            this.drawWeekChart()
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.bg_secondary'))
      .borderRadius(12)
      .border({ width: 1, color: $r('app.color.border_subtle') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_primary'))
    .padding({
      left: 16,
      right: 16,
      top: 16 + this.topInset,
      bottom: 16 + this.bottomInset
    })
  }
}
