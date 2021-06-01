USE store_schema;

-- In this OLTP system, table customers is in a normalized state but include redundant data. 
-- Redundant data mean here is, customer id 1 never made any transactions. customer id 1 never 
-- ordered anything in a given period of time. 
-- Other tables such as products, shippers, and order statuses are also in a normalized state but include redundant data.


DROP TABLE IF EXISTS stage_table;
CREATE TABLE stage_table (pri_key INT NOT NULL PRIMARY KEY AUTO_INCREMENT) AS
SELECT o.order_id, o.order_date, YEAR(o.order_date) AS order_year, 
MONTH(o.order_date) AS order_month, DAY(o.order_date) AS order_day, o.shipped_date,
c.*, s.shipper_id, s.name AS shipper_name, oi.quantity, oi.unit_price AS item_unit_price, os.order_status_id, os.name AS order_status, p.*
FROM orders o
JOIN customers c 
ON c.customer_id = o.customer_id
JOIN shippers s
ON s.shipper_id = o.shipper_id
JOIN order_items oi
ON oi.order_id = o.order_id
JOIN order_statuses os
ON os.order_status_id = o.status
JOIN products p
ON p.product_id = oi.product_id
;


-- DIM_CUSTOMER

DROP TABLE IF EXISTS dim_customers;
CREATE TABLE dim_customers (
  `dim_customer_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `customer_id` INTEGER NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `birth_date` DATE DEFAULT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `address` VARCHAR(50) DEFAULT NULL,
  `city` VARCHAR(50) DEFAULT NULL,
  `state` CHAR(2) DEFAULT NULL,
  `points` INTEGER DEFAULT NULL
  );
  
INSERT INTO dim_customers (`customer_id`, `first_name`, 
`last_name`, `birth_date`, `phone`,`address`, `city`, `state`, `points`)
SELECT DISTINCT st.customer_id, st.first_name, st.last_name, st.birth_date, st.phone, 
st.address, st.city, st.state, st.points
FROM stage_table st;

 -- DIM_ORDERS
 
DROP TABLE IF EXISTS dim_order_statuses;
CREATE TABLE dim_order_statuses (
  `dim_order_statuses_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `order_status_id`      INTEGER NOT NULL,
  `name`   TEXT DEFAULT NULL
  );
  
INSERT INTO dim_order_statuses ( `order_status_id`, `name`)
SELECT DISTINCT st.order_status_id, st.order_status
FROM stage_table st;

-- DIM_ORDER_DATE

DROP TABLE IF EXISTS dim_order_date;
CREATE TABLE dim_order_date (
`dim_order_date_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `order_date`	DATE NOT NULL,
  `order_year`   SMALLINT NOT NULL,
  `order_month` SMALLINT NOT NULL,  
  `order_day` SMALLINT NOT NULL
  );
  
INSERT INTO dim_order_date (`order_date`, `order_year`, `order_month`, `order_day`)
SELECT DISTINCT st.order_date, st.order_year, st.order_month, st.order_day
FROM stage_table st;

-- DIM_PRODUCTS

DROP TABLE IF EXISTS dim_products;
CREATE TABLE dim_products (
`dim_product_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`product_id` INTEGER NOT NULL,
`name`   TEXT NOT NULL,
`quantity_in_stock`     INTEGER DEFAULT NULL,
`unit_price`   DECIMAL(4,2) NOT NULL
);
  
INSERT INTO dim_products (`product_id`, `name`, `quantity_in_stock`, `unit_price`)
SELECT DISTINCT st.product_id, st.name, st.quantity_in_stock, st.unit_price
FROM stage_table st;

-- DIM_SHIPPERS

DROP TABLE IF EXISTS dim_shippers;  
CREATE TABLE dim_shippers (
`dim_shippers_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`shipper_id`        INTEGER NOT NULL,
`shipper_name`        TEXT NOT NULL
);

INSERT INTO dim_shippers (`shipper_id`, `shipper_name`  )
SELECT DISTINCT st.shipper_id, st.shipper_name
FROM stage_table st;



-- FACT_SALES MODEL

DROP TABLE IF EXISTS fact_sales;  
CREATE TABLE fact_sales (
`fact_sales_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`customer_id` INTEGER NOT NULL,
`order_status_id`	INTEGER NOT NULL,
`product_id` INTEGER NOT NULL,
`shipper_id` INTEGER NOT NULL,
`quantity`     DECIMAL(4,2) NOT NULL,
`item_unit_price` DECIMAL(4,2) NOT NULL,
`order_date`     DATE NOT NULL
);

INSERT INTO fact_sales ( `customer_id`, `order_status_id`, `product_id`,
`shipper_id`, `quantity`, `item_unit_price`, `order_date`)
SELECT DISTINCT dc.customer_id, dos.order_status_id, dp.product_id, ds.shipper_id, 
st.quantity, st.item_unit_price, dod.order_date
FROM stage_table st 
JOIN dim_customers dc ON
dc.customer_id = st.customer_id
JOIN dim_order_statuses dos ON
dos.order_status_id = st.order_status_id
JOIN dim_order_date dod ON
dod.order_date = st.order_date
JOIN dim_products dp ON
dp.product_id = st.product_id
JOIN dim_shippers ds ON
ds.shipper_id = st.shipper_id
ORDER BY dod.order_date;




