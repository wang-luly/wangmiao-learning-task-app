import { common } from '@kit.AbilityKit'
import { isSimulationMode } from "../config/AppConfig"
import { taskDB } from "../database/TaskDatabase"
import { GoldenOutlineButtonModifier, TitleTextModifier } from "../theme/AppStyles"
import { sendNotify } from "../utils/NotificationUtils"
import { getPageSafeInsets } from "../utils/SafeAreaUtil"
import { AppMotion } from "../theme/AppMotion"

@Component
export struct CountPage {
  @State topInset: number = 0
  @State bottomInset: number = 0
  @State chartAnim: number = 0
  @State cardOpacity: number = 0
  //今日学习总时长
  @State todayMinute:number=0
  //目标学习时长
  @State targetMinute:number=240
  //近七天学习时长
  @State weekData:number[]=[]
  @State weekLabels: string[] = []
  //Canvas画布
  private settings:RenderingContextSettings=new RenderingContextSettings(true)
  private ctx:CanvasRenderingContext2D=
    new CanvasRenderingContext2D(this.settings)
  private chartAnimTimer: number = -1
  //===============================函数======================================
  async aboutToAppear(){//这个页面会执行一次
    const insets = await getPageSafeInsets(this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.topInset = insets.top
    this.bottomInset = insets.bottom
    if(isSimulationMode()){
      this.weekData=[30,50,60,40,20,10,90]
      this.todayMinute=100
    }
    else{
      //从数据库中获取今日学习总时长
      this.todayMinute=await taskDB.queryTodayStudyMinute()
      //从数据库中获取近七天学习时长
      this.weekData=await taskDB.queryLast7Days()
    }
    this.weekLabels = this.buildWeekLabels()
    this.getUIContext().animateTo({ duration: AppMotion.NORMAL, curve: Curve.EaseOut }, () => {
      this.cardOpacity = 1
    })
    this.playChartAnim()
  }

  aboutToDisappear() {
    if (this.chartAnimTimer !== -1) {
      clearInterval(this.chartAnimTimer)
      this.chartAnimTimer = -1
    }
  }

  playChartAnim() {
    if (this.chartAnimTimer !== -1) {
      clearInterval(this.chartAnimTimer)
    }
    const steps = 36
    let step = 0
    this.chartAnim = 0
    this.drawWeekChart()
    this.chartAnimTimer = setInterval(() => {
      step++
      this.chartAnim = Math.min(1, step / steps)
      this.drawWeekChart()
      if (step >= steps) {
        clearInterval(this.chartAnimTimer)
        this.chartAnimTimer = -1
      }
    }, Math.floor(AppMotion.CHART / steps))
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

    // 横向网格线
    this.ctx.strokeStyle = '#2A2A2A'
    this.ctx.lineWidth = 1
    for (let i = 0; i <= 3; i++) {
      const y = padT + (chartH * i) / 3
      this.ctx.beginPath()
      this.ctx.moveTo(padL, y)
      this.ctx.lineTo(W - padR, y)
      this.ctx.stroke()
    }

    const count = this.weekData.length > 0 ? this.weekData.length : 7
    const barGap = 10
    const barW = (chartW - barGap * (count - 1)) / count

    this.weekData.forEach((value, index) => {
      const barH = (value / maxVal) * chartH * this.chartAnim
      const x = padL + index * (barW + barGap)
      const y = baseY - barH

      // 金色渐变柱
      const gradient = this.ctx.createLinearGradient(x, y, x, baseY)
      gradient.addColorStop(0, '#E8D5A3')
      gradient.addColorStop(1, '#8B7355')
      this.ctx.fillStyle = gradient
      this.ctx.fillRect(x, y, barW, barH)

      // 柱顶数值
      this.ctx.fillStyle = '#E8D5A3'
      this.ctx.font = '14px sans-serif'
      this.ctx.textAlign = 'center'
      this.ctx.textBaseline = 'bottom'
      if (this.chartAnim > 0.85) {
        this.ctx.fillText(value.toString(), x + barW / 2, y - 4)
      }

      // 底部日期
      this.ctx.fillStyle = '#9A9A9A'
      this.ctx.font = '11px sans-serif'
      this.ctx.textBaseline = 'top'
      this.ctx.fillText(this.weekLabels[index] ?? '', x + barW / 2, baseY + 8)
    })
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
            type: ProgressType.Capsule
          })
            .height(10)
            .width('100%')
            .color($r('app.color.gold_primary'))
            .backgroundColor($r('app.color.border_subtle'))
            .animation({ duration: AppMotion.SLOW, curve: Curve.EaseOut })

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
      .opacity(this.cardOpacity)
      .translate({ y: (1 - this.cardOpacity) * 24 })
      .animation({ duration: AppMotion.NORMAL, curve: Curve.EaseOut })

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
            if (this.chartAnim > 0) {
              this.drawWeekChart()
            }
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.bg_secondary'))
      .borderRadius(12)
      .border({ width: 1, color: $r('app.color.border_subtle') })
      .opacity(this.cardOpacity)
      .animation({ duration: AppMotion.NORMAL })

      Button('发布通知')
        .attributeModifier(new GoldenOutlineButtonModifier())
        .onClick(() => {
          sendNotify('通知', '证明通知功能可以正确进行')
        })
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