import http from '@ohos.net.http';
import { Restaurant } from '../models/Restaurant';
import { Dish } from '../models/Restaurant';
import { Order } from '../models/Restaurant';
import { User } from '../models/Restaurant';

// API基础配置
const BASE_URL = 'http://192.168.31.242:3000/api';

// API响应类型
interface ApiResponse {
  code?: number;
  success?: boolean;
  data?: string | number | boolean | ESObject | ESObject[];
  message?: string;
}

// 请求数据接口
type Primitive = string | number | boolean;
type RequestData = Record<string, Primitive | ESObject | ESObject[]>;

// 更新订单状态请求接口
interface UpdateOrderStatusRequest {
  status: string;
}

// 用户登录请求接口
interface LoginRequest {
  phone: string;
  password: string;
}

// HTTP请求头接口
interface HttpHeaders {
  'Content-Type': string;
}

export class ApiService {
  // 通用HTTP请求方法
  private static async request<T>(url: string, method: http.RequestMethod = http.RequestMethod.GET, data?: RequestData): Promise<T> {
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp();
      const headers: HttpHeaders = {
        'Content-Type': 'application/json'
      };
      let requestOptions: http.HttpRequestOptions = {
        method: method,
        header: headers,
        extraData: data ? JSON.stringify(data) : undefined,
        connectTimeout: 60000,
        readTimeout: 60000
      };

      httpRequest.request(BASE_URL + url, requestOptions)
        .then((data: http.HttpResponse) => {
          if (data.responseCode === 200) {
            try {
              let result: ApiResponse = JSON.parse(data.result.toString()) as ApiResponse;
              if (result.code === 200 || result.success) {
                resolve((result.data || result) as T);
              } else {
                reject(new Error(result.message || '请求失败'));
              }
            } catch (e) {
              reject(new Error('数据解析失败'));
            }
          } else {
            reject(new Error(`HTTP错误: ${data.responseCode}`));
          }
        })
        .catch((err: Error) => {
          reject(err);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  // 获取商家列表
  static async getRestaurants(): Promise<Restaurant[]> {
    return ApiService.request<Restaurant[]>('/restaurants');
  }

  // 获取商家详情
  static async getRestaurantById(id: number): Promise<Restaurant> {
    return ApiService.request<Restaurant>(`/restaurants/${id}`);
  }

  // 获取商家菜品列表
  static async getDishesByRestaurant(restaurantId: number): Promise<Dish[]> {
    return ApiService.request<Dish[]>(`/restaurants/${restaurantId}/dishes`);
  }

  // 获取菜品详情
  static async getDishById(id: number): Promise<Dish> {
    return ApiService.request<Dish>(`/dishes/${id}`);
  }

  // 创建订单
  static async createOrder(order: Order): Promise<Order> {
    return ApiService.request<Order>('/orders', http.RequestMethod.POST, order as ESObject as RequestData);
  }

  // 获取用户订单列表
  static async getUserOrders(userId: number): Promise<Order[]> {
    return ApiService.request<Order[]>(`/users/${userId}/orders`);
  }

  // 获取订单详情
  static async getOrderById(id: number): Promise<Order> {
    return ApiService.request<Order>(`/orders/${id}`);
  }

  // 更新订单状态
  static async updateOrderStatus(orderId: number, status: string): Promise<Order> {
    const requestData: UpdateOrderStatusRequest = { status: status };
    return ApiService.request<Order>(`/orders/${orderId}/status`, http.RequestMethod.PUT, requestData as RequestData);
  }

  // 用户登录
  static async login(phone: string, password: string): Promise<User> {
    const requestData: LoginRequest = { phone: phone, password: password };
    return ApiService.request<User>('/auth/login', http.RequestMethod.POST, requestData as RequestData);
  }

  // 用户注册
  static async register(user: User): Promise<User> {
    return ApiService.request<User>('/auth/register', http.RequestMethod.POST, user as ESObject as RequestData);
  }

  // 获取用户信息
  static async getUserInfo(userId: number): Promise<User> {
    return ApiService.request<User>(`/users/${userId}`);
  }

  // 更新用户信息
  static async updateUserInfo(userId: number, user: User): Promise<User> {
    return ApiService.request<User>(`/users/${userId}`, http.RequestMethod.PUT, user as ESObject as RequestData);
  }
}
