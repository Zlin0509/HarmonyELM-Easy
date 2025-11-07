// 商家模型
export class Restaurant {
  id: number = 0;
  name: string = '';
  image: string = '';
  rating: number = 0;
  sales: number = 0;
  deliveryTime: string = '';
  deliveryFee: number = 0;
  minPrice: number = 0;
  distance: string = '';
  tags: string[] = [];
  address: string = '';
}

// 菜品模型
export class Dish {
  id: number = 0;
  restaurantId: number = 0;
  name: string = '';
  image: string = '';
  price: number = 0;
  description: string = '';
  category: string = '';
  stock: number = 0;
}

// 购物车项模型
export class CartItem {
  dish: Dish = new Dish();
  quantity: number = 0;
  restaurantId: number = 0;
  restaurantName: string = '';
}

// 订单模型
export class Order {
  id: number = 0;
  userId: number = 0;
  restaurantId: number = 0;
  restaurantName: string = '';
  items: CartItem[] = [];
  totalPrice: number = 0;
  status: string = ''; // pending, confirmed, preparing, delivering, completed, cancelled
  createTime: string = '';
  address: string = '';
  phone: string = '';
}

// 用户模型
export class User {
  id: number = 0;
  username: string = '';
  phone: string = '';
  address: string = '';
  avatar: string = '';
}
