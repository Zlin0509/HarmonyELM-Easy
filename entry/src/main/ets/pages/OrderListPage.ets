import { Order } from '../models/Restaurant';
import { CartItem } from '../models/Restaurant';
import { Dish } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import router from '@ohos.router';

@Component
export struct OrderListPage {
  @State orders: Order[] = [];
  @State loading: boolean = true;
  @State selectedTab: number = 0; // 0: 全部, 1: 待支付, 2: 进行中, 3: 已完成

  aboutToAppear() {
    this.loadOrders();
  }

  async loadOrders() {
    this.loading = true;
    try {
      // 这里可以替换为实际的API调用
      this.orders = await ApiService.getUserOrders(1); // 1是用户ID，实际应该从登录信息获取
      
      // 模拟数据
      // const dish1: Dish = {
      //   id: 1,
      //   restaurantId: 1,
      //   name: '香辣鸡腿堡',
      //   image: '',
      //   price: 25,
      //   description: '',
      //   category: '',
      //   stock: 100
      // };
      //
      // const cartItem1: CartItem = {
      //   dish: dish1,
      //   quantity: 2,
      //   restaurantId: 1,
      //   restaurantName: '肯德基'
      // };
      //
      // const order1: Order = {
      //   id: 1,
      //   userId: 1,
      //   restaurantId: 1,
      //   restaurantName: '肯德基',
      //   items: [cartItem1],
      //   totalPrice: 50,
      //   status: 'pending',
      //   createTime: new Date().toISOString(),
      //   address: '北京市朝阳区xxx',
      //   phone: '13800138000'
      // };
      //
      // const dish2: Dish = {
      //   id: 2,
      //   restaurantId: 2,
      //   name: '巨无霸',
      //   image: '',
      //   price: 28,
      //   description: '',
      //   category: '',
      //   stock: 100
      // };
      //
      // const cartItem2: CartItem = {
      //   dish: dish2,
      //   quantity: 1,
      //   restaurantId: 2,
      //   restaurantName: '麦当劳'
      // };
      //
      // const order2: Order = {
      //   id: 2,
      //   userId: 1,
      //   restaurantId: 2,
      //   restaurantName: '麦当劳',
      //   items: [cartItem2],
      //   totalPrice: 28,
      //   status: 'delivering',
      //   createTime: new Date(Date.now() - 3600000).toISOString(),
      //   address: '北京市朝阳区xxx',
      //   phone: '13800138000'
      // };
      //
      // this.orders = [order1, order2];
    } catch (error) {
      console.error('加载订单列表失败:', error);
    } finally {
      this.loading = false;
    }
  }

  getFilteredOrders(): Order[] {
    if (this.selectedTab === 0) {
      return this.orders;
    }
    const statusMap: Record<number, string[]> = {
      1: ['pending'],
      2: ['confirmed', 'preparing', 'delivering'],
      3: ['completed']
    };
    return this.orders.filter(order => statusMap[this.selectedTab]?.includes(order.status));
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'pending': '待支付',
      'confirmed': '已确认',
      'preparing': '制作中',
      'delivering': '配送中',
      'completed': '已完成',
      'cancelled': '已取消'
    };
    return statusMap[status] || status;
  }

  getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'pending': '#FF9800',
      'confirmed': '#2196F3',
      'preparing': '#9C27B0',
      'delivering': '#00BCD4',
      'completed': '#4CAF50',
      'cancelled': '#F44336'
    };
    return colorMap[status] || '#666666';
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('我的订单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .padding({ left: 16, right: 16 })

      // 订单状态标签
      Row() {
        Text('全部')
          .fontSize(14)
          .fontColor(this.selectedTab === 0 ? '#FF6B00' : '#666666')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === 0 ? '#FFF5F0' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = 0;
          })

        Text('待支付')
          .fontSize(14)
          .fontColor(this.selectedTab === 1 ? '#FF6B00' : '#666666')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === 1 ? '#FFF5F0' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = 1;
          })

        Text('进行中')
          .fontSize(14)
          .fontColor(this.selectedTab === 2 ? '#FF6B00' : '#666666')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === 2 ? '#FFF5F0' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = 2;
          })

        Text('已完成')
          .fontSize(14)
          .fontColor(this.selectedTab === 3 ? '#FF6B00' : '#666666')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === 3 ? '#FFF5F0' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = 3;
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 订单列表
      if (this.loading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 200 })
      } else if (this.getFilteredOrders().length === 0) {
        Column() {
          Image($r('app.media.foreground'))
            .width(120)
            .height(120)
            .opacity(0.3)
            .margin({ bottom: 20 })

          Text('暂无订单')
            .fontSize(18)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredOrders(), (order: Order) => {
            ListItem() {
              this.OrderCard(order)
            }
          }, (order: Order) => order.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  OrderCard(order: Order) {
    Column() {
      // 订单头部
      Row() {
        Text(order.restaurantName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text(this.getStatusText(order.status))
          .fontSize(14)
          .fontColor(this.getStatusColor(order.status))
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 订单商品
      ForEach(order.items, (item: CartItem) => {
        Row() {
          Text(item.dish.name)
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)

          Text(`x${item.quantity}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ right: 12 })

          Text(`¥${(item.dish.price * item.quantity).toFixed(2)}`)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 8 })
      }, (item: CartItem) => `${item.dish.id}-${item.quantity}`)

      Divider()
        .margin({ top: 8, bottom: 8 })

      // 订单底部
      Row() {
        Text(`共${order.items.length}件商品 合计：`)
          .fontSize(12)
          .fontColor('#999999')

        Text(`¥${order.totalPrice.toFixed(2)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B00')
          .layoutWeight(1)

        Button('查看详情')
          .fontSize(12)
          .fontColor('#FF6B00')
          .backgroundColor(Color.Transparent)
          .borderColor('#FF6B00')
          .borderWidth(1)
          .borderRadius(15)
          .width(80)
          .height(30)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/OrderPage',
              params: { order: order }
            }).catch((err: Error) => {
              console.error(`Failed to push url. Code: ${err.message}`);
            });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
    .borderRadius(8)
  }
}
