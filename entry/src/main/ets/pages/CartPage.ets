import { CartItem } from '../models/Restaurant';
import { CartService } from '../services/CartService';
import { Order } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import router from '@ohos.router';

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = [];
  @State totalPrice: number = 0;
  @State loading: boolean = false;

  aboutToAppear() {
    this.loadCart();
    CartService.subscribe(() => {
      this.loadCart();
    });
  }

  loadCart() {
    this.cartItems = CartService.getCartItems();
    this.totalPrice = CartService.getTotalPrice();
  }

  async createOrder() {
    if (this.cartItems.length === 0) {
      return;
    }

    this.loading = true;
    try {
      // 创建订单
      let order: Order = {
        id: 0,
        userId: 1, // 实际应该从用户登录信息获取
        restaurantId: this.cartItems[0].restaurantId,
        restaurantName: this.cartItems[0].restaurantName,
        items: this.cartItems,
        totalPrice: this.totalPrice,
        status: 'pending',
        createTime: new Date().toISOString(),
        address: '北京市朝阳区xxx', // 实际应该从用户信息获取
        phone: '13800138000' // 实际应该从用户信息获取
      };

      // 调用API创建订单
      // let createdOrder = await ApiService.createOrder(order);
      
      // 模拟成功
      console.log('订单创建成功:', order);
      
      // 清空购物车
      CartService.clearCart();
      
      // 跳转到订单页面
      router.pushUrl({
        url: 'pages/OrderPage',
        params: { order: order }
      }).catch((err: Error) => {
        console.error(`Failed to push url. Code: ${err.message}`);
      });
    } catch (error) {
      console.error('创建订单失败:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 添加返回按钮
      Row() {
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
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10 })
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      if (this.cartItems.length === 0) {
        Column() {
          Image($r('app.media.foreground'))
            .width(120)
            .height(120)
            .opacity(0.3)
            .margin({ bottom: 20 })

          Text('购物车是空的')
            .fontSize(18)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.cartItems, (item: CartItem) => {
            ListItem() {
              this.CartItemCard(item)
            }
          }, (item: CartItem) => `${item.dish.id}-${item.restaurantId}`)
        }
        .layoutWeight(1)
        .width('100%')
      }

      // 底部结算栏
      if (this.cartItems.length > 0) {
        Row() {
          Column() {
            Text('合计')
              .fontSize(14)
              .fontColor('#666666')

            Text(`¥${this.totalPrice.toFixed(2)}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B00')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('去结算')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF6B00')
            .borderRadius(25)
            .width(120)
            .height(45)
            .enabled(!this.loading)
            .onClick(() => {
              this.createOrder();
            })
        }
        .width('100%')
        .height(70)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: -2 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  CartItemCard(item: CartItem) {
    Row() {
      Image(item.dish.image)
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Text(item.dish.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        Text(`¥${item.dish.price.toFixed(2)}`)
          .fontSize(14)
          .fontColor('#FF6B00')
          .margin({ bottom: 8 })

        Row() {
          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
            .onClick(() => {
              CartService.updateQuantity(item.dish.id, item.restaurantId, item.quantity - 1);
            })

          Text(`${item.quantity}`)
            .fontSize(16)
            .width(40)
            .textAlign(TextAlign.Center)

          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
            .onClick(() => {
              CartService.updateQuantity(item.dish.id, item.restaurantId, item.quantity + 1);
            })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(`¥${(item.dish.price * item.quantity).toFixed(2)}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Image($r('app.media.foreground'))
          .width(20)
          .height(20)
          .onClick(() => {
            CartService.removeFromCart(item.dish.id, item.restaurantId);
          })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
}
