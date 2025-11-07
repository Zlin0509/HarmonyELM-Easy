import { CartItem } from '../models/Restaurant';
import { Dish } from '../models/Restaurant';

// 购物车服务（本地存储）
export class CartService {
  private static cartItems: CartItem[] = [];
  private static listeners: ((items: CartItem[]) => void)[] = [];

  // 添加商品到购物车
  static addToCart(dish: Dish, restaurantId: number, restaurantName: string): void {
    let existingItem = CartService.cartItems.find(item => 
      item.dish.id === dish.id && item.restaurantId === restaurantId
    );

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      CartService.cartItems.push({
        dish: dish,
        quantity: 1,
        restaurantId: restaurantId,
        restaurantName: restaurantName
      });
    }
    CartService.notifyListeners();
  }

  // 从购物车移除商品
  static removeFromCart(dishId: number, restaurantId: number): void {
    CartService.cartItems = CartService.cartItems.filter(item => 
      !(item.dish.id === dishId && item.restaurantId === restaurantId)
    );
    CartService.notifyListeners();
  }

  // 更新商品数量
  static updateQuantity(dishId: number, restaurantId: number, quantity: number): void {
    let item = CartService.cartItems.find(item => 
      item.dish.id === dishId && item.restaurantId === restaurantId
    );
    if (item) {
      if (quantity <= 0) {
        CartService.removeFromCart(dishId, restaurantId);
      } else {
        item.quantity = quantity;
        CartService.notifyListeners();
      }
    }
  }

  // 获取购物车所有商品
  static getCartItems(): CartItem[] {
    return [...CartService.cartItems];
  }

  // 获取购物车总价
  static getTotalPrice(): number {
    return CartService.cartItems.reduce((total, item) => {
      return total + (item.dish.price * item.quantity);
    }, 0);
  }

  // 获取购物车商品总数
  static getTotalCount(): number {
    return CartService.cartItems.reduce((total, item) => {
      return total + item.quantity;
    }, 0);
  }

  // 清空购物车
  static clearCart(): void {
    CartService.cartItems = [];
    CartService.notifyListeners();
  }

  // 订阅购物车变化
  static subscribe(listener: (items: CartItem[]) => void): () => void {
    CartService.listeners.push(listener);
    return () => {
      CartService.listeners = CartService.listeners.filter(l => l !== listener);
    };
  }

  // 通知监听器
  private static notifyListeners(): void {
    CartService.listeners.forEach(listener => listener([...CartService.cartItems]));
  }
}
