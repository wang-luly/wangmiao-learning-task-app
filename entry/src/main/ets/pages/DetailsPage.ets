//详情页内容
@Component
export struct DetailsPage{
  build() {
    Stack(){
      Image($r('app.media.detailBg'))
        .width("100%")
        .height("100%")
      Text("这是详情页")
    }
  }
}