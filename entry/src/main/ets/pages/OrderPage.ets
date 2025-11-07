import { Order } from '../models/Restaurant';
import { CartItem } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import router from '@ohos.router';

@Entry
@Component
struct OrderPage {
  @State order: Order = new Order();
  @State loading: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['order']) {
      this.order = params['order'] as Order;
    }
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'pending': '待确认',
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
      // 订单状态
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

        Blank()

        Text(this.getStatusText(this.order.status))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getStatusColor(this.order.status))

        Blank()

        // 右侧空白占位，保持对称
        Blank()
          .width(80)
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 商家信息
      Column() {
        Text(this.order.restaurantName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 订单详情
      Column() {
        Text('订单详情')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })

        ForEach(this.order.items, (item: CartItem) => {
          Row() {
            Text(item.dish.name)
              .fontSize(14)
              .layoutWeight(1)

            Text(`x${item.quantity}`)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ right: 12 })

            Text(`¥${(item.dish.price * item.quantity).toFixed(2)}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .margin({ bottom: 8 })
        }, (item: CartItem) => `${item.dish.id}-${item.quantity}`)

        Divider()
          .margin({ top: 8, bottom: 8 })

        Row() {
          Text('合计')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          Text(`¥${this.order.totalPrice.toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B00')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 配送信息
      Column() {
        Text('配送信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })

        Row() {
          Text('配送地址：')
            .fontSize(14)
            .fontColor('#999999')
            .width(80)

          Text(this.order.address)
            .fontSize(14)
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('联系电话：')
            .fontSize(14)
            .fontColor('#999999')
            .width(80)

          Text(this.order.phone)
            .fontSize(14)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 订单时间
      Column() {
        Text(`下单时间：${new Date(this.order.createTime).toLocaleString()}`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
    .backgroundColor('#F5F5F5')
  }
}
