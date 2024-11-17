CREATE DATABASE coffee_db;

-- create schemas
drop table if exists city;
create table city(
	city_id	int primary key,
    city_name varchar(55),
    population bigint,
    estimated_rent float,
    city_rank int
    );
    
drop table if exists customers;
create table customers (
	customer_id int primary key,
    customer_name varchar(105),
    city_id int
);

drop table if exists products;
create table products(
	product_id int primary key,	
	product_name varchar(55),
	price float
);

drop table if exists sales;
create table sales (
	sale_id	int primary key,
    sale_date date,
    product_id int,
    customer_id	int,
    total float,
    rating int
);

-- Add foreign key to link customers and city
ALTER TABLE customers
ADD CONSTRAINT fk_city
FOREIGN KEY (city_id)
REFERENCES city(city_id);

-- Add foreign key to link sales and products
ALTER TABLE sales
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Add foreign key to link sales and customers
ALTER TABLE sales
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

