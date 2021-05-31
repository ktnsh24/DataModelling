DROP DATABASE IF EXISTS `northwind_schema`;
CREATE DATABASE `northwind_schema`;
USE `northwind_schema`;

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
    `ca_category_id` INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `ca_category_name` TEXT NOT NULL,
    `ca_description` TEXT DEFAULT NULL
);

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `c_customer_id` CHARACTER VARYING(60) PRIMARY KEY NOT NULL,
    `c_company_name` TEXT NOT NULL,
    `c_contact_name` TEXT DEFAULT NULL,
    `c_contact_title` TEXT DEFAULT NULL,
    `c_address` TEXT DEFAULT NULL,
    `c_city` TEXT DEFAULT NULL,
    `c_region` TEXT DEFAULT NULL,
    `c_postal_code` TEXT DEFAULT NULL,
    `c_country` TEXT DEFAULT NULL,
    `c_phone` TEXT DEFAULT NULL,
    `c_fax` TEXT DEFAULT NULL
);

DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers` (
    `s_supplier_id` INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
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

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
    `e_employee_id` INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
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



DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
    `p_product_id` INTEGER PRIMARY KEY NOT NULL,
    `p_product_name` CHARACTER VARYING(40) NOT NULL,
    `p_supplier_id` INTEGER,
    `p_category_id` INTEGER,
    `p_quantity_per_unit` CHARACTER VARYING(20) DEFAULT NULL,
    `p_unit_price` REAL DEFAULT NULL,
    `p_units_in_stock` INTEGER DEFAULT NULL,
    `p_units_on_order` INTEGER DEFAULT NULL,
    `p_reorder_level` INTEGER DEFAULT NULL,
    `p_discontinued` INTEGER NOT NULL,
	KEY `fk_product_suppliers_idx` (`p_supplier_id`),
    KEY `fk_product_category_idx` (`p_category_id`),
    CONSTRAINT `fk_product_suppliers` FOREIGN KEY (`p_supplier_id`) REFERENCES `suppliers` (`s_supplier_id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_product_category` FOREIGN KEY (`p_category_id`) REFERENCES `categories` (`ca_category_id`) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
    `o_order_id` INTEGER PRIMARY KEY NOT NULL,
    `o_customer_id` CHARACTER VARYING(60) NOT NULL,
    `o_employee_id` INTEGER NOT NULL,
    `o_product_id` INTEGER NOT NULL,
    `o_order_date` DATE,
    `o_required_date` DATE,
    `o_shipped_date` DATE,
    `o_ship_via` INTEGER DEFAULT NULL,
    `o_freight` REAL DEFAULT NULL,
    `o_ship_name` CHARACTER VARYING(40) DEFAULT NULL,
    `o_ship_address` CHARACTER VARYING(60) DEFAULT NULL,
    `o_ship_city` CHARACTER VARYING(15) DEFAULT NULL,
    `o_ship_region` CHARACTER VARYING(15) DEFAULT NULL,
    `o_ship_postal_code` CHARACTER VARYING(10) DEFAULT NULL,
    `o_ship_country` CHARACTER VARYING(15) DEFAULT NULL,
    KEY `fk_order_customers_idx` (`o_customer_id`),
    KEY `fk_order_employees_idx` (`o_employee_id`),
    KEY `fk_orders_products_idx` (`o_product_id`),
    CONSTRAINT `fk_order_customers` FOREIGN KEY (`o_customer_id`) REFERENCES `customers` (`c_customer_id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_order_employees` FOREIGN KEY (`o_employee_id`) REFERENCES `employees` (`e_employee_id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_products` FOREIGN KEY (`o_product_id`) REFERENCES `products` (`p_product_id`) ON UPDATE CASCADE
);


