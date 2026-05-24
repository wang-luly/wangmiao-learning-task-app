
/** 一级标题 */
@Extend(Text)
export function titleText() {
    .fontSize(18)
    .fontWeight(FontWeight.Medium)
    .fontColor($r('app.color.text_primary'))
    .letterSpacing(0.5)
}

/** 辅助说明文字 */
@Extend(Text)
export function captionText() {
    .fontSize(13)
    .fontColor($r('app.color.text_secondary'))
}

/** 任务卡片外框 */
@Extend(Row)
export function taskCardRow() {
  .width('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.bg_secondary'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_subtle') })
}

/** 列表分区标题栏（「学习任务」那一行） */
@Extend(Row)
export function sectionHeaderRow() {
  .width('100%')
    .height(48)
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.bg_elevated'))
    .borderRadius(8)
    .border({ width: 1, color: $r('app.color.border_subtle') })
}

/** 金色描边小按钮（卡片「开始」） */
@Extend(Button)
export function goldOutlineButton() {
  .height(32)
    .padding({ left: 14, right: 14 })
    .fontSize(13)
    .fontColor($r('app.color.gold_primary'))
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
    .border({ width: 1, color: $r('app.color.gold_dim') })
}

/** 弹窗主按钮（确定）— 弹窗改 UI 时用 */
@Extend(Button)
export function goldFillButton() {
  .height(40)
    .fontSize(15)
    .fontColor($r('app.color.bg_primary'))
    .backgroundColor($r('app.color.gold_primary'))
    .borderRadius(8)
}

/** 弹窗次按钮（取消） */
@Extend(Button)
export function ghostButton() {
    .height(40)
    .fontSize(15)
    .fontColor($r('app.color.text_secondary'))
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
}