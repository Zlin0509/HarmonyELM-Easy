import router from '@ohos.router';

@Entry
@Component
struct AddressPage {
  @State addresses: string[] = [
    '北京市朝阳区xxx街道xxx号',
    '北京市海淀区xxx街道xxx号'
  ];

  build() {
    Column() {
      // 添加导航栏
      Row() {
        // 返回按钮
        Button() {
          Text('← 返回')
            .fontSize(16)
        }
        .width(80)
        .height(40)
        .fontColor('#007DFF')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back()
        })

        // 标题 - 使用Blank确保居中
        Blank()
        Text('收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()

        // 右侧添加等宽空白占位，保持对称
        Blank()
          .width(80)
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween) // 使用SpaceBetween布局
      .alignItems(VerticalAlign.Center)

      // 地址列表
      List() {
        ForEach(this.addresses, (address: string, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(address)
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 4 })

                Text('默认地址')
                  .fontSize(12)
                  .fontColor('#FF6B00')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Image($r('app.media.foreground'))
                .width(24)
                .height(24)
                .onClick(() => {
                  // TODO: 编辑地址
                })
            }
            .width('100%')
            .padding(16)
          }
        }, (address: string, index: number) => `${index}`)
      }
      .layoutWeight(1)
      .width('100%')

      // 添加地址按钮
      Button('+ 添加新地址')
        .width('90%')
        .height(45)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#FF6B00')
        .borderRadius(25)
        .margin({ bottom: 20 })
        .onClick(() => {
          // TODO: 添加地址
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
