import { User } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import router from '@ohos.router';

@Entry
@Component
struct UserInfoPage {
  @State user: User = new User();
  @State loading: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['user']) {
      this.user = params['user'] as User;
    }
  }

  async saveUserInfo() {
    this.loading = true;
    try {
      // 这里可以替换为实际的API调用
      // await ApiService.updateUserInfo(this.user.id, this.user);
      router.back();
    } catch (error) {
      console.error('保存用户信息失败:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 头像编辑
      Column() {
        Stack() {
          Circle({ width: 100, height: 100 })
            .fill('#E0E0E0')

          if (this.user.avatar) {
            Image(this.user.avatar)
              .width(100)
              .height(100)
              .borderRadius(50)
          } else {
            Text(this.user.username.charAt(0))
              .fontSize(40)
              .fontColor('#666666')
          }
        }
        .width(100)
        .height(100)
        .margin({ bottom: 8 })

        Text('点击更换头像')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 用户信息表单
      Column() {
        Row() {
          Text('用户名')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)

          TextInput({ placeholder: '请输入用户名', text: this.user.username })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.user.username = value;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Divider()

        Row() {
          Text('手机号')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)

          Text(this.user.phone)
            .fontSize(16)
            .fontColor('#666666')
            .layoutWeight(1)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Divider()

        Row() {
          Text('收货地址')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)

          TextInput({ placeholder: '请输入收货地址', text: this.user.address })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.user.address = value;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ bottom: 20 })

      // 保存按钮
      Button('保存')
        .width('90%')
        .height(45)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#FF6B00')
        .borderRadius(25)
        .enabled(!this.loading)
        .onClick(() => {
          this.saveUserInfo();
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
    .backgroundColor('#F5F5F5')
  }
}
