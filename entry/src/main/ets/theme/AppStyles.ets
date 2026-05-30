
/** 一级标题 */
export class TitleTextModifier implements AttributeModifier<TextAttribute>{
  //applyNormalAttribute是必须要重写的方法
  applyNormalAttribute(instance: TextAttribute): void {
    //instance为重写方法参数，类型为要修改style的类型
    instance.fontSize(18)
    instance.fontWeight(FontWeight.Medium)
    instance.fontColor($r('app.color.text_primary'))
    instance.letterSpacing(0.5)
  }
}

/** 辅助说明文字 */
export class AuxiliaryModifier implements AttributeModifier<TextAttribute>{
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(13)
    instance.fontColor($r('app.color.text_secondary'))
  }
}

/** 任务卡片外框 */
export class TaskCardMarginModifier implements AttributeModifier<RowAttribute>{
  applyNormalAttribute(instance: RowAttribute): void {
    instance.width('100%')
    instance.padding({left:12,right:12,top:14,bottom:14})
    instance.backgroundColor($r('app.color.bg_secondary'))
    instance.borderRadius(12)
    instance.border({ width: 1, color: $r('app.color.border_subtle') })
  }
}

/** 列表分区标题栏（学习任务那一行） */
export class HeaderRowModifier implements AttributeModifier<RowAttribute> {
  applyNormalAttribute(instance: RowAttribute): void {
    instance.width('100%')
    instance.height(48)
    instance.padding({ left: 12, right: 12 })
    instance.backgroundColor($r('app.color.bg_elevated'))
    instance.borderRadius(8)
    instance.border({ width: 1, color: $r('app.color.border_subtle') })
  }

}

/** 金色描边小按钮（卡片「开始」） */
export class GoldenOutlineButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height(32)
    instance.padding({ left: 14, right: 14 })
    instance.fontSize(13)
    instance.fontColor($r('app.color.gold_primary'))
    instance.backgroundColor(Color.Transparent)
    instance.borderRadius(8)
    instance.border({ width: 1, color: $r('app.color.gold_dim') })
  }

}

/** 弹窗主按钮（确定）— 弹窗改 UI 时用 */
export class GoldenFillButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height(40)
    instance.fontSize(15)
    instance.fontColor($r('app.color.bg_primary'))
    instance.backgroundColor($r('app.color.gold_primary'))
    instance.borderRadius(8)
  }

}


/** 弹窗次按钮（取消） */

export class GHostButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height(40)
    instance.fontSize(15)
    instance.fontColor($r('app.color.text_secondary'))
    instance.backgroundColor(Color.Transparent)
    instance.borderRadius(8)
  }

}