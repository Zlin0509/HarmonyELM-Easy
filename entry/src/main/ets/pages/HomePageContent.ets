import { Restaurant } from '../models/Restaurant';
import { ApiService } from '../services/ApiService';
import { CartService } from '../services/CartService';
import router from '@ohos.router';
import { when } from '@ohos/hypium';

@Component
export struct HomePageContent {
  @State restaurants: Restaurant[] = [];
  @State loading: boolean = true;
  @State searchText: string = '';
  @State cartCount: number = 0;

  aboutToAppear() {
    this.loadRestaurants();
    // 订阅购物车变化
    CartService.subscribe((items) => {
      this.cartCount = CartService.getTotalCount();
    });
    this.cartCount = CartService.getTotalCount();
  }

  async loadRestaurants() {
    this.loading = true;
    try {
      this.restaurants = await ApiService.getRestaurants();
    } catch (error) {
      console.error('加载商家列表失败:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        Search({ value: this.searchText, placeholder: '搜索商家、菜品' })
          .searchButton('搜索')
          .onChange((value: string) => {
            this.searchText = value;
          })
          .layoutWeight(1)
          .height(40)
          .margin({ left: 16, right: 8 })

        // 购物车图标
        Stack() {
          Image($r('app.media.foreground'))
            .width(32)
            .height(32)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CartPage'
              }).catch((err: Error) => {
                console.error(`Failed to push url. Code: ${err.message}`);
              });
            })

          if (this.cartCount > 0) {
            Text(`${this.cartCount}`)
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor(Color.Red)
              .borderRadius(10)
              .width(20)
              .height(20)
              .textAlign(TextAlign.Center)
              .position({ x: 20, y: -5 })
          }
        }
        .width(40)
        .height(40)
        .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })

      if (this.loading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 200 })
      } else {
        // 商家列表
        List() {
          ForEach(this.restaurants, (restaurant: Restaurant) => {
            ListItem() {
              this.RestaurantCard(restaurant)
            }
          }, (item: Restaurant) => item.id.toString())
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
  RestaurantCard(restaurant: Restaurant) {
    Row() {
      // 商家图片
      Image(restaurant.image)
        .width(100)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      // 商家信息
      Column() {
        Text(restaurant.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        Row() {
          Text(`评分 ${restaurant.rating}`)
            .fontSize(12)
            .fontColor('#FF6B00')
            .margin({ right: 12 })

          Text(`月售${restaurant.sales}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 12 })

          Text(restaurant.deliveryTime)
            .fontSize(12)
            .fontColor('#999999')
        }
        .margin({ bottom: 4 })

        Row() {
          ForEach(restaurant.tags, (tag: string) => {
            Text(tag)
              .fontSize(10)
              .fontColor('#666666')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ right: 6 })
          }, (item: string, index: number) => index.toString())
        }
        .margin({ bottom: 4 })

        Row() {
          Text(`起送¥${restaurant.minPrice}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 12 })

          Text(`配送费¥${restaurant.deliveryFee}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 12 })

          Text(restaurant.distance)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/RestaurantDetailPage',
        params: { restaurant: restaurant }
      }).catch((err: Error) => {
        console.error(`Failed to push url. Code: ${err.message}`);
      });
    })
  }
}
