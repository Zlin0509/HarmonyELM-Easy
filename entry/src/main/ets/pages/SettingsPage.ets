import router from '@ohos.router';

@Entry
@Component
struct SettingsPage {
  @State notifications: boolean = true;
  @State autoUpdate: boolean = false;

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

        // 标题
        Blank()
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()

        // 右侧空白占位，保持对称
        Blank()
          .width(80)
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      // 通知设置
      Column() {
        Row() {
          Text('消息通知')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.notifications })
            .onChange((isOn: boolean) => {
              this.notifications = isOn;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Divider()

        Row() {
          Text('自动更新')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.autoUpdate })
            .onChange((isOn: boolean) => {
              this.autoUpdate = isOn;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 其他设置
      Column() {
        Row() {
          Text('清除缓存')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text('128MB')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ right: 8 })

          Image($r('app.media.foreground'))
            .width(20)
            .height(20)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // TODO: 清除缓存
        })

        Divider()

        Row() {
          Text('检查更新')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text('v1.0.0')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ right: 8 })

          Image($r('app.media.foreground'))
            .width(20)
            .height(20)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // TODO: 检查更新
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ bottom: 20 })

      // 退出登录
      Button('退出登录')
        .width('90%')
        .height(45)
        .fontSize(16)
        .fontColor('#F44336')
        .backgroundColor(Color.Transparent)
        .borderColor('#F44336')
        .borderWidth(1)
        .borderRadius(25)
        .onClick(() => {
          // TODO: 退出登录
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
    .backgroundColor('#F5F5F5')
  }
}
