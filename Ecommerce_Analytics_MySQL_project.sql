DROP DATABASE IF EXISTS ecommerce_analytics_db;
CREATE DATABASE ecommerce_analytics_db;
USE ecommerce_analytics_db;

-- ============================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS
-- LARGE DATASET VERSION
-- 6 TABLES | 500 CUSTOMERS | 50 CATEGORIES | 1000 PRODUCTS
-- 5000 ORDERS | 12000+ ORDER ITEMS | 5000 PAYMENTS
-- MySQL 8.x / MySQL Workbench
-- ============================================================
SET SESSION cte_max_recursion_depth = 20000;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    signup_date DATE NOT NULL
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    department VARCHAR(80) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_qty INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    shipping_city VARCHAR(60) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    transaction_ref VARCHAR(50) NOT NULL UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 1. CATEGORIES: 50 realistic categories
-- ============================================================

INSERT INTO categories (category_id, category_name, department) VALUES
(1,'Smartphones','Electronics'),
(2,'Laptops','Electronics'),
(3,'Tablets','Electronics'),
(4,'Televisions','Electronics'),
(5,'Cameras','Electronics'),
(6,'Headphones','Electronics'),
(7,'Speakers','Electronics'),
(8,'Smart Watches','Electronics'),
(9,'Gaming Consoles','Electronics'),
(10,'Computer Accessories','Electronics'),
(11,'Chargers & Adapters','Mobile Accessories'),
(12,'Power Banks','Mobile Accessories'),
(13,'Mobile Cases','Mobile Accessories'),
(14,'Screen Protectors','Mobile Accessories'),
(15,'Cables','Mobile Accessories'),
(16,'Kitchen Appliances','Home Appliances'),
(17,'Air Conditioners','Home Appliances'),
(18,'Refrigerators','Home Appliances'),
(19,'Washing Machines','Home Appliances'),
(20,'Vacuum Cleaners','Home Appliances'),
(21,'Men Clothing','Fashion'),
(22,'Women Clothing','Fashion'),
(23,'Kids Clothing','Fashion'),
(24,'Footwear','Fashion'),
(25,'Bags & Luggage','Fashion'),
(26,'Watches','Fashion'),
(27,'Jewellery','Fashion'),
(28,'Beauty & Makeup','Beauty'),
(29,'Skincare','Beauty'),
(30,'Hair Care','Beauty'),
(31,'Perfumes','Beauty'),
(32,'Fitness Equipment','Sports'),
(33,'Sportswear','Sports'),
(34,'Outdoor Sports','Sports'),
(35,'Yoga & Wellness','Sports'),
(36,'Fiction Books','Books'),
(37,'Business Books','Books'),
(38,'Technology Books','Books'),
(39,'Academic Books','Books'),
(40,'Cooking Books','Books'),
(41,'Staples','Grocery'),
(42,'Snacks','Grocery'),
(43,'Beverages','Grocery'),
(44,'Breakfast Foods','Grocery'),
(45,'Organic Foods','Grocery'),
(46,'Pet Supplies','Grocery'),
(47,'Home Decor','Home & Living'),
(48,'Furniture','Home & Living'),
(49,'Bedding','Home & Living'),
(50,'Storage & Organization','Home & Living');

-- ============================================================
-- 2. CUSTOMERS: 500 generated realistic records
-- ============================================================

INSERT INTO customers
(customer_id, customer_name, email, city, state, signup_date)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM nums WHERE n < 500
),
names AS (
    SELECT
        n,
        ELT(MOD(n-1,20)+1,
        'Aarav','Vivaan','Aditya','Arjun','Rohan','Kabir','Yash','Rahul','Karan','Manav',
        'Priya','Ananya','Isha','Neha','Sneha','Pooja','Tanya','Simran','Meera','Kritika') AS first_name,
        ELT(MOD(n-1,20)+1,
        'Sharma','Verma','Gupta','Singh','Mehta','Khan','Patel','Joshi','Kapoor','Malhotra',
        'Jain','Das','Rao','Nair','Bansal','Mishra','Kaur','Iyer','Shah','Sen') AS last_name
    FROM nums
)
SELECT
    n,
    CONCAT(first_name,' ',last_name),
    CONCAT(LOWER(first_name),'.',LOWER(last_name),n,'@mail.com'),
    ELT(MOD(n-1,20)+1,
        'Delhi','Mumbai','Bengaluru','Pune','Jaipur','Chandigarh','Hyderabad','Kolkata',
        'Ahmedabad','Chennai','Lucknow','Amritsar','Surat','Noida','Kochi','Bhopal',
        'Indore','Nagpur','Patna','Guwahati'),
    ELT(MOD(n-1,20)+1,
        'Delhi','Maharashtra','Karnataka','Maharashtra','Rajasthan','Chandigarh','Telangana',
        'West Bengal','Gujarat','Tamil Nadu','Uttar Pradesh','Punjab','Gujarat',
        'Uttar Pradesh','Kerala','Madhya Pradesh','Madhya Pradesh','Maharashtra',
        'Bihar','Assam'),
    DATE_ADD('2024-01-01', INTERVAL MOD(n*17,900) DAY)
FROM names;

-- ============================================================
-- 3. PRODUCTS: 1000 generated realistic records
-- ============================================================

INSERT INTO products
(product_id, product_name, category_id, price, stock_qty)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM nums WHERE n < 1000
)
SELECT
    n,
    CONCAT(
        ELT(MOD(n-1,20)+1,
        'Premium','Smart','Classic','Pro','Ultra','Advanced','Essential','Elite','Eco','Power',
        'Digital','Modern','Max','Plus','Prime','Comfort','Performance','Urban','NextGen','Value'),
        ' ',
        ELT(MOD(n*3-1,20)+1,
        'Series','Edition','Model','Collection','Gear','Device','Kit','Pack','System','Set',
        'Line','Range','Hub','Box','Choice','Select','Flex','Core','One','X'),
        ' ', LPAD(n,4,'0')
    ),
    MOD(n-1,50)+1,
    ROUND(
        CASE MOD(n-1,10)
        WHEN 0 THEN 499 + MOD(n*137,1500)
        WHEN 1 THEN 1299 + MOD(n*211,5000)
        WHEN 2 THEN 2499 + MOD(n*317,10000)
        WHEN 3 THEN 4999 + MOD(n*421,20000)
        WHEN 4 THEN 7999 + MOD(n*173,30000)
        WHEN 5 THEN 999 + MOD(n*97,7000)
        WHEN 6 THEN 1599 + MOD(n*193,12000)
        WHEN 7 THEN 2999 + MOD(n*271,18000)
        WHEN 8 THEN 699 + MOD(n*83,4000)
        ELSE 1999 + MOD(n*151,9000)
        END, 2
    ),
    10 + MOD(n*37,491)
FROM nums;

-- ============================================================
-- 4. ORDERS: 5000 generated orders
-- ============================================================

INSERT INTO orders
(order_id, customer_id, order_date, order_status, payment_method, shipping_city)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM nums WHERE n < 5000
)
SELECT
    100000+n,
    MOD(n*37-1,500)+1,
    DATE_ADD('2026-01-01', INTERVAL MOD(n*7,210) DAY),
    CASE
        WHEN MOD(n,100) < 4 THEN 'Cancelled'
        WHEN MOD(n,100) < 9 THEN 'Processing'
        WHEN MOD(n,100) < 20 THEN 'Shipped'
        ELSE 'Delivered'
    END,
    ELT(MOD(n-1,5)+1,'UPI','Card','Net Banking','Cash on Delivery','Wallet'),
    ELT(MOD(n*37-1,20)+1,
        'Delhi','Mumbai','Bengaluru','Pune','Jaipur','Chandigarh','Hyderabad','Kolkata',
        'Ahmedabad','Chennai','Lucknow','Amritsar','Surat','Noida','Kochi','Bhopal',
        'Indore','Nagpur','Patna','Guwahati')
FROM nums;

-- ============================================================
-- 5. ORDER ITEMS: 3 items per order = 15,000 rows
-- ============================================================

INSERT INTO order_items
(order_item_id, order_id, product_id, quantity, unit_price, discount_pct)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM nums WHERE n < 15000
)
SELECT
    n,
    100000 + CEIL(n/3),
    MOD(n*83-1,1000)+1,
    MOD(n*17,4)+1,
    p.price,
    ELT(MOD(n-1,6)+1,0,5,10,15,8,12)
FROM nums
JOIN products p ON p.product_id = MOD(n*83-1,1000)+1;

-- ============================================================
-- 6. PAYMENTS: one payment per order = 5000 rows
-- Payment amount is calculated from order items.
-- ============================================================

INSERT INTO payments
(payment_id, order_id, payment_date, amount, payment_status, transaction_ref)
SELECT
    o.order_id - 99500,
    o.order_id,
    o.order_date,
    ROUND(
        COALESCE(SUM(
            oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)
        ),0),2
    ),
    CASE
        WHEN o.order_status = 'Cancelled' THEN 'Refunded'
        WHEN MOD(o.order_id,100) < 5 THEN 'Pending'
        ELSE 'Paid'
    END,
    CONCAT('TXN',o.order_id)
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY o.order_id,o.order_date,o.order_status;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_customers_signup ON customers(signup_date);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- ============================================================
-- ANALYTICAL VIEWS
-- ============================================================

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_pct/100)),2) AS revenue
FROM products p
JOIN categories c ON p.category_id=c.category_id
JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id,p.product_name,c.category_name;

CREATE OR REPLACE VIEW vw_customer_value AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(
        CASE WHEN pay.payment_status='Paid' THEN pay.amount ELSE 0 END
    ),0),2) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON c.customer_id=o.customer_id
LEFT JOIN payments pay ON o.order_id=pay.order_id
GROUP BY c.customer_id,c.customer_name,c.city;

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(payment_date,'%Y-%m') AS month,
    ROUND(SUM(amount),2) AS revenue,
    COUNT(*) AS paid_transactions
FROM payments
WHERE payment_status='Paid'
GROUP BY DATE_FORMAT(payment_date,'%Y-%m');

-- ============================================================
-- PROJECT KPI / ANALYTICAL QUERIES
-- ============================================================

-- Q1: Database size
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'Categories',COUNT(*) FROM categories
UNION ALL SELECT 'Products',COUNT(*) FROM products
UNION ALL SELECT 'Orders',COUNT(*) FROM orders
UNION ALL SELECT 'Order Items',COUNT(*) FROM order_items
UNION ALL SELECT 'Payments',COUNT(*) FROM payments;

-- Q2: Overall KPIs
SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT ROUND(SUM(amount),2) FROM payments WHERE payment_status='Paid') AS total_revenue,
    (SELECT ROUND(AVG(amount),2) FROM payments WHERE payment_status='Paid') AS avg_paid_order;

-- Q3: Top 10 products by revenue
SELECT product_name, category_name, units_sold, revenue
FROM vw_product_performance
ORDER BY revenue DESC
LIMIT 10;

-- Q4: Revenue by category
SELECT
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)),2) AS revenue
FROM categories c
JOIN products p ON c.category_id=p.category_id
JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.category_id,c.category_name
ORDER BY revenue DESC;

-- Q5: Top 20 customers
SELECT customer_name,city,total_orders,lifetime_value
FROM vw_customer_value
ORDER BY lifetime_value DESC
LIMIT 20;

-- Q6: Monthly revenue trend
SELECT * FROM vw_monthly_revenue ORDER BY month;

-- Q7: Revenue by city
SELECT
    o.shipping_city,
    ROUND(SUM(CASE WHEN p.payment_status='Paid' THEN p.amount ELSE 0 END),2) AS revenue
FROM orders o
JOIN payments p ON o.order_id=p.order_id
GROUP BY o.shipping_city
ORDER BY revenue DESC;

-- Q8: Order status distribution
SELECT order_status,COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Q9: Payment method performance
SELECT
    payment_method,
    COUNT(*) AS orders,
    ROUND(AVG(p.amount),2) AS avg_payment,
    ROUND(SUM(CASE WHEN p.payment_status='Paid' THEN p.amount ELSE 0 END),2) AS paid_revenue
FROM orders o
JOIN payments p ON o.order_id=p.order_id
GROUP BY payment_method
ORDER BY paid_revenue DESC;

-- Q10: Average order value
SELECT ROUND(AVG(order_value),2) AS average_order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id=oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY o.order_id
) x;

-- Q11: Customers with more than 10 orders
SELECT
    c.customer_id,c.customer_name,c.city,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name,c.city
HAVING COUNT(o.order_id)>10
ORDER BY order_count DESC;

-- Q12: Low-stock products
SELECT product_id,product_name,stock_qty
FROM products
WHERE stock_qty < 50
ORDER BY stock_qty;

-- Q13: High-value orders
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)),2) AS order_value
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY o.order_id,c.customer_name,o.order_date
HAVING order_value > 100000
ORDER BY order_value DESC;

-- Q14: Top 3 customers in each city using window function
WITH customer_revenue AS (
    SELECT
        c.city,
        c.customer_id,
        c.customer_name,
        SUM(CASE WHEN p.payment_status='Paid' THEN p.amount ELSE 0 END) AS total_paid
    FROM customers c
    JOIN orders o ON c.customer_id=o.customer_id
    JOIN payments p ON o.order_id=p.order_id
    GROUP BY c.city,c.customer_id,c.customer_name
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY city
               ORDER BY total_paid DESC
           ) AS city_rank
    FROM customer_revenue
)
SELECT city,customer_name,ROUND(total_paid,2) AS total_paid,city_rank
FROM ranked
WHERE city_rank <= 3
ORDER BY city,city_rank;

-- Q15: Top 5 products within every department
WITH product_revenue AS (
    SELECT
        c.department,
        p.product_id,
        p.product_name,
        SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)) AS revenue
    FROM categories c
    JOIN products p ON c.category_id=p.category_id
    JOIN order_items oi ON p.product_id=oi.product_id
    JOIN orders o ON oi.order_id=o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.department,p.product_id,p.product_name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY department
               ORDER BY revenue DESC
           ) AS product_rank
    FROM product_revenue
)
SELECT department,product_name,ROUND(revenue,2) AS revenue,product_rank
FROM ranked
WHERE product_rank <= 5
ORDER BY department,product_rank;

-- Q16: Category revenue using CTE
WITH category_sales AS (
    SELECT
        c.category_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)) AS revenue
    FROM categories c
    JOIN products p ON c.category_id=p.category_id
    JOIN order_items oi ON p.product_id=oi.product_id
    JOIN orders o ON oi.order_id=o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.category_id,c.category_name
)
SELECT category_name,units_sold,ROUND(revenue,2) AS revenue
FROM category_sales
ORDER BY revenue DESC;

-- Q17: Repeat customers
SELECT
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS orders_count
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name,c.city
HAVING COUNT(o.order_id) >= 5
ORDER BY orders_count DESC;

-- Q18: Discount analysis
SELECT
    discount_pct,
    COUNT(*) AS item_lines,
    SUM(quantity) AS units,
    ROUND(SUM(quantity*unit_price),2) AS gross_sales
FROM order_items
GROUP BY discount_pct
ORDER BY discount_pct;

-- Q19: Department performance
SELECT
    c.department,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount_pct/100)),2) AS revenue
FROM categories c
JOIN products p ON c.category_id=p.category_id
JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.department
ORDER BY revenue DESC;

-- Q20: Pending and refunded payments
SELECT
    payment_status,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount),2) AS amount
FROM payments
WHERE payment_status IN ('Pending','Refunded')
GROUP BY payment_status;

-- ============================================================
-- END OF PROJECT
-- ============================================================