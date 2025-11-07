import { Restaurant } from '../models/Restaurant';
import { Dish } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import { CartService } from '../services/CartService';
import router from '@ohos.router';

@Entry
@Component
struct RestaurantDetailPage {
  @State restaurant: Restaurant = new Restaurant();
  @State dishes: Dish[] = [];
  @State loading: boolean = true;
  @State selectedCategory: string = '';
  @State categories: string[] = [];
  @State cartCount: number = 0;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['restaurant']) {
      this.restaurant = params['restaurant'] as Restaurant;
    }
    this.loadDishes();
    CartService.subscribe((items) => {
      this.cartCount = CartService.getTotalCount();
    });
    this.cartCount = CartService.getTotalCount();
  }

  async loadDishes() {
    this.loading = true;
    try {
      this.dishes = await ApiService.getDishesByRestaurant(this.restaurant.id);
      this.categories = Array.from(new Set(this.dishes.map(d => d.category)));
      if (this.categories.length > 0) {
        this.selectedCategory = this.categories[0];
      }
    } catch (error) {
      console.error('加载菜品失败:', error);
    } finally {
      this.loading = false;
    }
  }

  getFilteredDishes(): Dish[] {
    if (!this.selectedCategory) {
      return this.dishes;
    }
    return this.dishes.filter(d => d.category === this.selectedCategory);
  }

  build() {
    Column() {
      // 顶部商家信息
      Column() {
        // 使用Stack来在图片上叠加返回按钮
        Stack() {
          Image(this.restaurant.image)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)

          // 返回按钮
          Button() {
            Text('←')
              .fontSize(20)
              .fontColor(Color.Black)
          }
          .width(40)
          .height(40)
          .backgroundColor('#00000040')
          .borderRadius(20)
          .position({ x: 10, y: 10 })
          .onClick(() => {
            router.back()
          })
        }
        .width('100%')
        .height(200)

        Column() {
          Text(this.restaurant.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Row() {
            Text(`评分 ${this.restaurant.rating}`)
              .fontSize(14)
              .fontColor('#FF6B00')
              .margin({ right: 16 })

            Text(`月售${this.restaurant.sales}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ right: 16 })

            Text(this.restaurant.deliveryTime)
              .fontSize(14)
              .fontColor('#666666')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
      }

      // 分类标签
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? '#FF6B00' : '#666666')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.selectedCategory === category ? '#FFF5F0' : Color.White)
              .borderRadius(20)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category;
              })
          }, (item: string, index: number) => index.toString())
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // 菜品列表
      if (this.loading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 100 })
      } else {
        List() {
          ForEach(this.getFilteredDishes(), (dish: Dish) => {
            ListItem() {
              this.DishCard(dish)
            }
          }, (item: Dish) => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
      }

      // 底部购物车栏
      if (this.cartCount > 0) {
        Row() {
          Stack() {
            Image($r('app.media.foreground'))
              .width(40)
              .height(40)

            if (this.cartCount > 0) {
              Text(`${this.cartCount}`)
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor(Color.Red)
                .borderRadius(10)
                .width(20)
                .height(20)
                .textAlign(TextAlign.Center)
                .position({ x: 25, y: -5 })
            }
          }
          .width(50)
          .height(50)

          Column() {
            Text(`¥${CartService.getTotalPrice().toFixed(2)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text(`另需配送费¥${this.restaurant.deliveryFee}`)
              .fontSize(12)
              .fontColor('#FFFFFF80')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

            Button('去结算')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF6B00')
            .borderRadius(25)
            .width(100)
            .height(40)
            .onClick(() => {
              router.pushUrl({ url: 'pages/CartPage' }).catch((err: Error) => {
                console.error(`Failed to push url. Code: ${err.message}`);
              });
            })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#333333')
        .onClick(() => {
          router.pushUrl({ url: 'pages/CartPage' }).catch((err: Error) => {
            console.error(`Failed to push url. Code: ${err.message}`);
          });
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  getDishQuantity(dishId: number): number {
    let cartItem = CartService.getCartItems().find(item => 
      item.dish.id === dishId && item.restaurantId === this.restaurant.id
    );
    return cartItem ? cartItem.quantity : 0;
  }

  @Builder
  DishCard(dish: Dish) {
    Row() {
      Image(dish.image)
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Text(dish.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        Text(dish.description)
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        Row() {
          Text(`¥${dish.price.toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B00')
            .layoutWeight(1)

          Row() {
            if (this.getDishQuantity(dish.id) > 0) {
              Image($r('app.media.foreground'))
                .width(24)
                .height(24)
                .onClick(() => {
                  CartService.updateQuantity(dish.id, this.restaurant.id, this.getDishQuantity(dish.id) - 1);
                })

              Text(`${this.getDishQuantity(dish.id)}`)
                .fontSize(16)
                .width(30)
                .textAlign(TextAlign.Center)

              Image($r('app.media.foreground'))
                .width(24)
                .height(24)
                .onClick(() => {
                  CartService.updateQuantity(dish.id, this.restaurant.id, this.getDishQuantity(dish.id) + 1);
                })
            } else {
              Button('+')
                .fontSize(18)
                .fontColor(Color.White)
                .backgroundColor('#FF6B00')
                .borderRadius(15)
                .width(30)
                .height(30)
                .onClick(() => {
                  CartService.addToCart(dish, this.restaurant.id, this.restaurant.name);
                })
            }
          }
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
}
