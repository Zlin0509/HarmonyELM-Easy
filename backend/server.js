// Node.js + Express + MySQL 后端服务器示例
// 安装依赖: npm install express mysql2 cors body-parser

const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// 中间件
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// MySQL数据库配置
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: 'Zgl126842',
    database: 'eleme_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

async function initDatabase() {
    try {
        const connection = await pool.getConnection();

        // 创建商家表
        await connection.query(`
      CREATE TABLE IF NOT EXISTS restaurants (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        image VARCHAR(255),
        rating DECIMAL(3,1) DEFAULT 0,
        sales INT DEFAULT 0,
        delivery_time VARCHAR(20),
        delivery_fee DECIMAL(10,2) DEFAULT 0,
        min_price DECIMAL(10,2) DEFAULT 0,
        distance VARCHAR(20),
        tags VARCHAR(255),
        address VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

        // 创建菜品表
        await connection.query(`
      CREATE TABLE IF NOT EXISTS dishes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        restaurant_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        image VARCHAR(255),
        price DECIMAL(10,2) NOT NULL,
        description TEXT,
        category VARCHAR(50),
        stock INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
      )
    `);

        // 创建用户表
        await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        phone VARCHAR(20) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        address VARCHAR(255),
        avatar VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

        // 创建订单表
        await connection.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        restaurant_id INT NOT NULL,
        restaurant_name VARCHAR(100),
        total_price DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        address VARCHAR(255),
        phone VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
      )
    `);

        // 创建订单项表
        await connection.query(`
      CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        dish_id INT NOT NULL,
        dish_name VARCHAR(100),
        dish_price DECIMAL(10,2),
        quantity INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (dish_id) REFERENCES dishes(id)
      )
    `);

        connection.release();
        console.log('数据库表初始化完成');
    } catch (error) {
        console.error('数据库初始化失败:', error);
    }
}

// API路由

function normalizeRestaurant(row) {
    return {
        id: row.id,
        name: row.name,
        image: row.image,
        rating: Number(row.rating),
        sales: Number(row.sales),
        deliveryTime: row.delivery_time,
        deliveryFee: Number(row.delivery_fee),
        minPrice: Number(row.min_price),
        distance: row.distance,
        tags: row.tags ? row.tags.split(',').map(tag => tag.trim()) : [],
        address: row.address,
    };
}


function normalizeDish(row) {
    return {
        ...row,
        price: row.price ? Number(row.price) : 0,
        stock: row.stock ? Number(row.stock) : 0,
    };
}

app.get('/api/restaurants', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM restaurants ORDER BY sales DESC');
        // 统一格式化
        const restaurants = rows.map(normalizeRestaurant);
        res.json({
            code: 200,
            data: restaurants,
            message: '成功'
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
});

// ✅ 获取商家详情
app.get('/api/restaurants/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM restaurants WHERE id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({
                code: 404,
                message: '商家不存在'
            });
        }
        // 格式化单条记录
        const restaurant = normalizeRestaurant(rows[0]);
        res.json({
            code: 200,
            data: restaurant,
            message: '成功'
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
});


// 获取商家菜品列表
app.get('/api/restaurants/:id/dishes', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM dishes WHERE restaurant_id = ? ORDER BY category, id',
            [req.params.id]
        );
        const dishes = rows.map(normalizeDish);
        res.json({ code: 200, data: dishes, message: '成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 获取菜品详情
app.get('/api/dishes/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM dishes WHERE id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ code: 404, message: '菜品不存在' });
        }
        const dish = normalizeDish(rows[0]);
        res.json({ code: 200, data: dish, message: '成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 创建订单
app.post('/api/orders', async (req, res) => {
    try {
        const { userId, restaurantId, restaurantName, items, totalPrice, address, phone } = req.body;

        const connection = await pool.getConnection();
        await connection.beginTransaction();

        try {
            // 插入订单
            const [orderResult] = await connection.query(
                `INSERT INTO orders (user_id, restaurant_id, restaurant_name, total_price, status, address, phone)
         VALUES (?, ?, ?, ?, 'pending', ?, ?)`,
                [userId, restaurantId, restaurantName, totalPrice, address, phone]
            );

            const orderId = orderResult.insertId;

            // 插入订单项
            for (const item of items) {
                await connection.query(
                    `INSERT INTO order_items (order_id, dish_id, dish_name, dish_price, quantity)
           VALUES (?, ?, ?, ?, ?)`,
                    [orderId, item.dish.id, item.dish.name, item.dish.price, item.quantity]
                );
            }

            await connection.commit();

            // 获取完整订单信息
            const [orderRows] = await connection.query(
                `SELECT o.*,
         JSON_ARRAYAGG(
           JSON_OBJECT(
             'id', oi.dish_id,
             'name', oi.dish_name,
             'price', oi.dish_price,
             'quantity', oi.quantity
           )
         ) as items
         FROM orders o
         LEFT JOIN order_items oi ON o.id = oi.order_id
         WHERE o.id = ?
         GROUP BY o.id`,
                [orderId]
            );

            connection.release();
            res.json({ code: 200, data: orderRows[0], message: '订单创建成功' });
        } catch (error) {
            await connection.rollback();
            connection.release();
            throw error;
        }
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 获取用户订单列表
app.get('/api/users/:userId/orders', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
            [req.params.userId]
        );
        res.json({ code: 200, data: rows, message: '成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 获取订单详情
app.get('/api/orders/:id', async (req, res) => {
    try {
        const [orderRows] = await pool.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
        if (orderRows.length === 0) {
            return res.status(404).json({ code: 404, message: '订单不存在' });
        }

        const [itemRows] = await pool.query(
            'SELECT * FROM order_items WHERE order_id = ?',
            [req.params.id]
        );

        const order = orderRows[0];
        order.items = itemRows;

        res.json({ code: 200, data: order, message: '成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 更新订单状态
app.put('/api/orders/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await pool.query('UPDATE orders SET status = ? WHERE id = ?', [status, req.params.id]);
        const [rows] = await pool.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
        res.json({ code: 200, data: rows[0], message: '订单状态更新成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 用户登录
app.post('/api/auth/login', async (req, res) => {
    try {
        const { phone, password } = req.body;
        const [rows] = await pool.query(
            'SELECT id, username, phone, address, avatar FROM users WHERE phone = ? AND password = ?',
            [phone, password] // 实际应用中应该使用加密密码
        );
        if (rows.length === 0) {
            return res.status(401).json({ code: 401, message: '用户名或密码错误' });
        }
        res.json({ code: 200, data: rows[0], message: '登录成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 用户注册
app.post('/api/auth/register', async (req, res) => {
    try {
        const { username, phone, password, address } = req.body;
        const [result] = await pool.query(
            'INSERT INTO users (username, phone, password, address) VALUES (?, ?, ?, ?)',
            [username, phone, password, address] // 实际应用中应该加密密码
        );
        const [rows] = await pool.query(
            'SELECT id, username, phone, address, avatar FROM users WHERE id = ?',
            [result.insertId]
        );
        res.json({ code: 200, data: rows[0], message: '注册成功' });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ code: 400, message: '手机号已存在' });
        }
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 获取用户信息
app.get('/api/users/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT id, username, phone, address, avatar FROM users WHERE id = ?',
            [req.params.id]
        );
        if (rows.length === 0) {
            return res.status(404).json({ code: 404, message: '用户不存在' });
        }
        res.json({ code: 200, data: rows[0], message: '成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 更新用户信息
app.put('/api/users/:id', async (req, res) => {
    try {
        const { username, address, avatar } = req.body;
        await pool.query(
            'UPDATE users SET username = ?, address = ?, avatar = ? WHERE id = ?',
            [username, address, avatar, req.params.id]
        );
        const [rows] = await pool.query(
            'SELECT id, username, phone, address, avatar FROM users WHERE id = ?',
            [req.params.id]
        );
        res.json({ code: 200, data: rows[0], message: '更新成功' });
    } catch (error) {
        res.status(500).json({ code: 500, message: error.message });
    }
});

// 启动服务器
app.listen(PORT, async () => {
    console.log(`服务器运行在 http://localhost:${PORT}`);
    await initDatabase();
});