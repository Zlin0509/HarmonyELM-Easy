import { User } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import router from '@ohos.router';

@Component
export struct UserCenterPage {
  @State user: User = {
    id: 1,
    username: '用户',
    phone: '138****8000',
    address: '北京市朝阳区xxx',
    avatar: ''
  };
  @State loading: boolean = false;

  aboutToAppear() {
    this.loadUserInfo();
  }

  async loadUserInfo() {
    this.loading = true;
    try {
      // 这里可以替换为实际的API调用
      // this.user = await ApiService.getUserInfo(1); // 1是用户ID，实际应该从登录信息获取
    } catch (error) {
      console.error('加载用户信息失败:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 用户信息卡片
      Column() {
        Row() {
          // 头像
          Stack() {
            Circle({ width: 80, height: 80 })
              .fill('#E0E0E0')

            if (this.user.avatar) {
              Image(this.user.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
            } else {
              Text(this.user.username.charAt(0))
                .fontSize(32)
                .fontColor('#666666')
            }
          }
          .width(80)
          .height(80)
          .margin({ right: 16 })

          // 用户信息
          Column() {
            Text(this.user.username)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            Text(this.user.phone)
              .fontSize(14)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 编辑按钮
          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/UserInfoPage',
                params: { user: this.user }
              }).catch((err: Error) => {
                console.error(`Failed to push url. Code: ${err.message}`);
              });
            })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20, left: 16, right: 16 })
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 功能菜单
      Column() {
        this.MenuItem('收货地址', () => {
          router.pushUrl({
            url: 'pages/AddressPage'
          }).catch((err: Error) => {
            console.error(`Failed to push url. Code: ${err.message}`);
          });
        })

        Divider()

        this.MenuItem('我的收藏', () => {
          // TODO: 跳转到收藏页面
        })

        Divider()

        this.MenuItem('优惠券', () => {
          // TODO: 跳转到优惠券页面
        })

        Divider()

        this.MenuItem('客服中心', () => {
          // TODO: 跳转到客服页面
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 设置菜单
      Column() {
        this.MenuItem('设置', () => {
          router.pushUrl({
            url: 'pages/SettingsPage'
          }).catch((err: Error) => {
            console.error(`Failed to push url. Code: ${err.message}`);
          });
        })

        Divider()

        this.MenuItem('关于我们', () => {
          // TODO: 显示关于我们对话框
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)

      Image($r('app.media.foreground'))
        .width(20)
        .height(20)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }
}
