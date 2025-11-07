import { HomePageContent } from './HomePageContent';
import { OrderListPage } from './OrderListPage';
import { UserCenterPage } from './UserCenterPage';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // 首页
      TabContent() {
        HomePageContent()
      }
      .tabBar(this.TabBuilder('首页', 0))

      // 订单
      TabContent() {
        OrderListPage()
      }
      .tabBar(this.TabBuilder('订单', 1))

      // 我的
      TabContent() {
        UserCenterPage()
      }
      .tabBar(this.TabBuilder('我的', 2))
    }
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder
  TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === targetIndex ? '#FF6B00' : '#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}
