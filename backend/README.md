# 饿了么后端API服务器

## 安装依赖

```bash
npm install
```

## 配置数据库

1. 创建MySQL数据库：
```sql
CREATE DATABASE eleme_db;
```

2. 修改 `server.js` 中的数据库配置：
```javascript
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'your_password', // 修改为你的MySQL密码
  database: 'eleme_db'
};
```

## 启动服务器

```bash
npm start
```

或者使用开发模式（自动重启）：
```bash
npm run dev
```

服务器将在 `http://localhost:3000` 启动

## API接口

### 商家相关
- `GET /api/restaurants` - 获取商家列表
- `GET /api/restaurants/:id` - 获取商家详情
- `GET /api/restaurants/:id/dishes` - 获取商家菜品列表

### 菜品相关
- `GET /api/dishes/:id` - 获取菜品详情

### 订单相关
- `POST /api/orders` - 创建订单
- `GET /api/users/:userId/orders` - 获取用户订单列表
- `GET /api/orders/:id` - 获取订单详情
- `PUT /api/orders/:id/status` - 更新订单状态

### 用户相关
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/users/:id` - 获取用户信息
- `PUT /api/users/:id` - 更新用户信息

## 数据库表结构

- `restaurants` - 商家表
- `dishes` - 菜品表
- `users` - 用户表
- `orders` - 订单表
- `order_items` - 订单项表

服务器启动时会自动创建这些表。
