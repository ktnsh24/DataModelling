USE `northwind_schema`;
-- Currently, data in the database include redundant data. Tables such as `customer`s, `employees`, `suppliers`, and `categories` 
-- are in the normalized state but still include redundant data. For analytics purpose, we only need those transactions 
-- which occur in the given time.
-- In the case of `customers`, we only need those customers who made some transactions in a given period.
-- In the case of `suppliers`, we only need those suppliers who supplied something in a given period.
-- In the case of `employees`, we only need those employees who attended customers in a given period.
-- Table `orders` is in the denormalized state and include no redundant data. However for the 
-- the purpose of dimensional modeling, we can normalize the `orders` table further.
-- Table `products` in the denormalized state but include redundant data.

-- Grain- print all the order based on 'order date' made by different customers, products they bought, 
-- supplier who is a supplier of the product, and the category where product belongs.

-- stage_table
DROP TABLE IF EXISTS `stage_table`;
CREATE TABLE `stage_table` (`stage_pri_key` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT) AS
SELECT o.`o_order_id`, YEAR(o.`o_order_date`) AS `o_order_year`, 
MONTH(o.`o_order_date`) AS `o_order_month`, DAY(o.`o_order_date`) AS `o_order_day`, 
YEAR(o.`o_shipped_date`) AS `o_shipped_year`, 
MONTH(o.`o_shipped_date`) AS `o_shipped_month`, DAY(o.`o_shipped_date`) AS `o_shipped_day`,
o.`o_order_date`, o.`o_shipped_date`, o.`o_ship_via`, o.`o_freight`, o.`o_ship_name`, o.`o_ship_address`,
o.`o_ship_city`, o.`o_ship_region`, o.`o_ship_postal_code`, o.`o_ship_country`,
c.*, e.*, p.`p_product_id`, p.`p_product_name`, p.`p_quantity_per_unit`, 
p.`p_unit_price`, p.`p_units_in_stock`, p.`p_units_on_order`, p.`p_reorder_level`, p.`p_discontinued`,
ca.*, s.*
FROM `orders` o
JOIN `customers` c  
ON c.`c_customer_id` = o.`o_customer_id`
JOIN `employees` e
ON e.`e_employee_id` = o.`o_employee_id`
JOIN `products` p
ON p.`p_product_id` = o.`o_product_id`
JOIN `categories` ca
ON ca.`ca_category_id` = p.`p_category_id`
JOIN `suppliers` s
ON s.`s_supplier_id` = p.`p_supplier_id`
ORDER BY o.`o_order_date`
;

-- DIM_CUSTOMER

DROP TABLE IF EXISTS `dim_customers`;
CREATE TABLE `dim_customers` (
  `dim_customers_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `c_customer_id`    CHARACTER VARYING(60) NOT NULL,
  `c_company_name`       TEXT NOT NULL,
  `c_contact_name`    TEXT DEFAULT NULL,
  `c_contact_title`    TEXT DEFAULT NULL,
  `c_address`      TEXT DEFAULT NULL,
  `c_city`    TEXT DEFAULT NULL,
  `c_region` TEXT DEFAULT NULL,
  `c_postal_code`    TEXT DEFAULT NULL,
  `c_country`    TEXT DEFAULT NULL,
  `c_phone`    TEXT DEFAULT NULL,
  `c_fax`    TEXT DEFAULT NULL
  );
  
INSERT INTO `dim_customers` (`c_customer_id`, `c_company_name`, `c_contact_name`, `c_contact_title`, `c_address`, 
 `c_city`, `c_region`, `c_postal_code`, `c_country`, `c_phone`, `c_fax`)
SELECT DISTINCT st.c_customer_id, st.c_company_name, st.c_contact_name, st.c_contact_title, st.c_address, 
st.c_city, st.c_region, st.c_postal_code, st.c_country, st.c_phone, st.c_fax
FROM `stage_table` st;

 -- DIM_ORDERS
 
DROP TABLE IF EXISTS `dim_orders`;
CREATE TABLE `dim_orders` (
`dim_orders_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`o_order_id` INTEGER NOT NULL,
`o_ship_via` INTEGER DEFAULT NULL,
`o_freight` REAL DEFAULT NULL,
`o_ship_name` CHARACTER VARYING(40) DEFAULT NULL,
`o_ship_address` CHARACTER VARYING(60) DEFAULT NULL,
`o_ship_city` CHARACTER VARYING(15) DEFAULT NULL,
`o_ship_region` CHARACTER VARYING(15) DEFAULT NULL,
`o_ship_postal_code` CHARACTER VARYING(10) DEFAULT NULL,
`o_ship_country` CHARACTER VARYING(15) DEFAULT NULL
  );

  
INSERT INTO `dim_orders` (`o_order_id`, `o_ship_via`, `o_freight`, `o_ship_name`, `o_ship_address`,
 `o_ship_city`, `o_ship_region`, `o_ship_postal_code`, `o_ship_country`)
SELECT DISTINCT st.o_order_id, st.o_ship_via, st.o_freight, st.o_ship_name, st.o_ship_address,
st.o_ship_city, st.o_ship_region, st.o_ship_postal_code, st.o_ship_country
FROM `stage_table` st;

-- DIM_ORDER_DATE

DROP TABLE IF EXISTS `dim_order_date`;
CREATE TABLE `dim_order_date` (
`dim_orders_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`o_order_date` DATE NOT NULL,
`o_order_year` SMALLINT NOT NULL,
`o_order_month` SMALLINT NOT NULL, 
`o_order_day` SMALLINT NOT NULL
  );
  
INSERT INTO `dim_order_date` (`o_order_date`, `o_order_year`, `o_order_month`, `o_order_day`)
SELECT DISTINCT st.o_order_date, st.o_order_year, st.o_order_month, st.o_order_day
FROM `stage_table` st;

-- DIM_SHIPPED_DATE

DROP TABLE IF EXISTS `dim_shipped_date`;
CREATE TABLE `dim_shipped_date` (
`dim_shipped_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`o_shipped_date` DATE DEFAULT NULL,
`o_shipped_year` SMALLINT DEFAULT NULL,
`o_shipped_month` SMALLINT DEFAULT NULL, 
`o_shipped_day` SMALLINT DEFAULT NULL
  );
  
INSERT INTO `dim_shipped_date` (`o_shipped_date`, `o_shipped_year`, `o_shipped_month`, `o_shipped_day`)
SELECT DISTINCT st.o_shipped_date, st.o_shipped_year, st.o_shipped_month, st.o_shipped_day
FROM `stage_table` st;

-- DIM_EMPLOYEES

DROP TABLE IF EXISTS `dim_employees`;
CREATE TABLE `dim_employees` (
	`dim_employees_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `e_employee_id` INTEGER NOT NULL,
    `e_last_name` TEXT NOT NULL,
    `e_first_name` TEXT NOT NULL,
    `e_title` TEXT NOT NULL,
    `e_title_of_courtesy` TEXT NOT NULL,
    `e_birthdate` DATE NOT NULL,
    `e_hiredate` DATE NOT NULL,
    `e_address` TEXT NOT NULL,
    `e_city` TEXT NOT NULL,
    `e_region` TEXT DEFAULT NULL,
    `e_postal_code` TEXT NOT NULL,
    `e_country` TEXT NOT NULL,
    `e_homephone` TEXT DEFAULT NULL,
    `e_extension` TEXT DEFAULT NULL,
    `e_notes` TEXT DEFAULT NULL,
    `e_reports_to` INTEGER DEFAULT NULL,
    `e_photo_path` TEXT NOT NULL
);
  
INSERT INTO `dim_employees` (`e_employee_id`, `e_last_name`, `e_first_name`, `e_title`, `e_title_of_courtesy`,
`e_birthdate`, `e_hiredate`, `e_address`, `e_city`, `e_region`, `e_postal_code`, `e_country`,`e_homephone`,
 `e_extension`, `e_notes`, `e_reports_to`, `e_photo_path`)
SELECT DISTINCT st.e_employee_id, st.e_last_name, st.e_first_name, st.e_title, st.e_title_of_courtesy, 
st.e_birthdate, st.e_hiredate, st.e_address, st.e_city, st.e_region, st.e_postal_code, st.e_country, 
st.e_homephone, st.e_extension, st.e_notes, st.e_reports_to, st.e_photo_path
FROM `stage_table` st;

-- DIM_PRODUCTS

DROP TABLE IF EXISTS `dim_products`;  
CREATE TABLE `dim_products` (
	`dim_products_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `p_product_id` INTEGER NOT NULL,
    `p_product_name` CHARACTER VARYING(40) NOT NULL,
    `p_units_on_order` INTEGER DEFAULT NULL,
    `p_reorder_level` INTEGER DEFAULT NULL,
    `p_discontinued` INTEGER NOT NULL
);

INSERT INTO `dim_products` (`p_product_id`, `p_product_name`, `p_units_on_order`, `p_reorder_level`, `p_discontinued`)
SELECT DISTINCT st.p_product_id, st.p_product_name, st.p_units_on_order, st.p_reorder_level, st.p_discontinued
FROM `stage_table` st;

-- DIM_CATEGORIES

DROP TABLE IF EXISTS `dim_categories`;  
CREATE TABLE `dim_categories` (
	`dim_categories_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`ca_category_id` INTEGER NOT NULL,
    `ca_category_name` TEXT NOT NULL,
    `ca_description` TEXT DEFAULT NULL
);

INSERT INTO `dim_categories` (`ca_category_id`, `ca_category_name`, `ca_description`)
SELECT DISTINCT st.ca_category_id, st.ca_category_name, st.ca_description
FROM `stage_table` st;

-- DIM_SUPPLIERS

DROP TABLE IF EXISTS `dim_suppliers`;
CREATE TABLE `dim_suppliers` (
	`dim_suppliers_id` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`s_supplier_id` INTEGER NOT NULL,
    `s_company_name` CHARACTER VARYING(40) NOT NULL,
    `s_contact_name` CHARACTER VARYING(30) DEFAULT NULL,
    `s_contact_title` CHARACTER VARYING(30) DEFAULT NULL,
    `s_address` CHARACTER VARYING(60) DEFAULT NULL,
    `s_city` CHARACTER VARYING(15) DEFAULT NULL,
    `s_region` CHARACTER VARYING(15) DEFAULT NULL,
    `s_postal_code` CHARACTER VARYING(10) DEFAULT NULL,
    `s_country` CHARACTER VARYING(15) DEFAULT NULL,
    `s_phone` CHARACTER VARYING(24) DEFAULT NULL,
    `s_fax` CHARACTER VARYING(24) DEFAULT NULL,
    `s_home_page` TEXT DEFAULT NULL
  );

INSERT INTO `dim_suppliers` (`s_supplier_id`, `s_company_name`, `s_contact_name`, `s_contact_title`, `s_address`,
 `s_city`, `s_region`, `s_postal_code`, `s_country`, `s_phone`, `s_fax`, `s_home_page` )
SELECT DISTINCT st.s_supplier_id, st.s_company_name, st.s_contact_name, st.s_contact_title, st.s_address, 
st.s_city, st.s_region, st.s_postal_code, st.s_country, st.s_phone, st.s_fax, st.s_home_page
FROM `stage_table` st;

-- FACT_MODEL_ONE

DROP TABLE IF EXISTS `fact_model`;  
CREATE TABLE `fact_model` (
`fact_primary_key` INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
`c_customer_id`    CHARACTER VARYING(60) NOT NULL,
`o_order_id` INTEGER NOT NULL,
`e_employee_id` INTEGER NOT NULL,
`s_supplier_id` INTEGER NOT NULL,
`ca_category_id` INTEGER NOT NULL,
`p_product_id` INTEGER NOT NULL,
`p_quantity_per_unit` CHARACTER VARYING(20) DEFAULT NULL,
`p_unit_price` REAL DEFAULT NULL,
`p_units_in_stock` INTEGER DEFAULT NULL,
`o_order_date` DATE NOT NULL,
`o_shipped_date` DATE DEFAULT NULL
);

INSERT INTO `fact_model` (`c_customer_id`, `o_order_id`, `e_employee_id`, `s_supplier_id`, `ca_category_id`,
`p_product_id`, `p_quantity_per_unit`, `p_unit_price`, `p_units_in_stock`, `o_order_date`, `o_shipped_date` )
SELECT DISTINCT dc.c_customer_id, dor.o_order_id, de.e_employee_id, ds.s_supplier_id, 
dca.ca_category_id, dp.p_product_id, st.p_quantity_per_unit, st.p_unit_price, st.p_units_in_stock, 
dod.o_order_date, dsd.o_shipped_date
FROM `stage_table` st
JOIN `dim_customers` dc ON
dc.`c_customer_id` = st.`c_customer_id`
JOIN `dim_orders` dor ON
dor.`o_order_id` = st.`o_order_id`
JOIN `dim_employees` de ON
de.`e_employee_id` = st.`e_employee_id`
JOIN `dim_suppliers` ds ON
ds.`s_supplier_id` = st.`s_supplier_id`
JOIN `dim_categories` dca ON
dca.`ca_category_id` = st.`ca_category_id`
JOIN `dim_products` dp ON
dp.`p_product_id` = st.`p_product_id`
JOIN `dim_order_date` dod ON
dod.`o_order_date` = st.`o_order_date`
JOIN `dim_shipped_date` dsd ON
dsd.`o_shipped_date` = st.`o_shipped_date`
ORDER BY dod.`o_order_date`;





