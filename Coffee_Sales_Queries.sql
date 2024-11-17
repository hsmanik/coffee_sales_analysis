-- coffee sales data analysis
select * from city;
select * from customers;
select * from products;
select * from sales;

-- task 1 : Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select city_name, round((population * 0.25)/1000000, 2) as coffe_cosnumers_in_millions, city_rank
from city
order by 2 desc;

-- task 2 : Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select ci.city_name, sum(total) as total_revenue
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
where quarter(s.sale_date) = 4 and year(s.sale_date) = 2023
group by 1
order by 2 desc;

-- task 3 : Sales Count for Each Product
-- How many units of each coffee product have been sold?

select p.product_name, count(s.sale_id) as total_orders
from products as p
right join sales as s
on p.product_id = s.product_id
group by 1
order by 2 desc;

-- task 4 : Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select ci.city_name, sum(s.total) as total_revenue, count(distinct s.customer_id) as total_customers, round(sum(s.total)/count(distinct s.customer_id),2) as per_city_avg_sale
from customers as c
join sales as s
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc;

-- task 5 : City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

with city_table as (
select city_name, round(population * 0.25,2) as coffee_consumers
from city
),
customers_table as (
select ci.city_name, count(distinct c.customer_id) as unique_customers
from city as ci
join customers as c
on ci.city_id = c.city_id
join sales as s
on s.customer_id = c.customer_id
group by 1
)
select ct.city_name, ct.coffee_consumers, cit.unique_customers
from city_table as ct
join customers_table as cit
on cit.city_name = ct.city_name;

-- task 6: Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

with ranked_sales as (
select ci.city_name, 
	p.product_name,
    count(s.sale_id) as volume, 
    row_number() over(partition by ci.city_name order by sum(s.total) desc) as ranking
from products as p
join sales as s
on p.product_id = s.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,2
)
select city_name, product_name, volume, ranking
from ranked_sales
where ranking <=3
order by city_name, ranking;


-- task 7: Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select ci.city_name, count(distinct c.customer_id) as unique_customers
from city as ci
left join customers as c
on ci.city_id = c.city_id
join sales as s
on s.customer_id = c.customer_id
where s.product_id <= 14
group by 1
order by 2 desc;

-- task 8 : Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with city_table as (
select ci.city_name,
	sum(s.total) as total_revenue, 
    count(distinct s.customer_id) as total_customers, 
    round(sum(s.total)/count(distinct s.customer_id),2) as per_city_avg_sale
from customers as c
join sales as s
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc
),
city_rent as(
select city_name, estimated_rent from city
)
select cr.city_name, cr.estimated_rent, ct.per_city_avg_sale, ct.total_customers,
	round(cr.estimated_rent/ct.total_customers,2) as avg_rent_per_cust
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 3 desc;


-- task 9: Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city

with monthly_sales as(
select ci.city_name, 
	month(s.sale_date) as month, 
    year(s.sale_date) as year, 
    sum(s.total) as total_sales
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,2,3
order by 1,3,2
),
growth_ratio as (
select *,
    lag(total_sales, 1) over(partition by city_name) as last_month_sale
from monthly_sales
)
select *,
	round(((total_sales-last_month_sale)/last_month_sale) * 100,2) as percentage_change
from growth_ratio;


-- task 10 : Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with city_table as (
select ci.city_name,
	sum(s.total) as total_revenue, 
    count(distinct s.customer_id) as total_customers, 
    round(sum(s.total)/count(distinct s.customer_id),2) as per_city_avg_sale
from customers as c
join sales as s
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc
),
city_rent as(
select city_name,estimated_rent, round((population * 0.25) / 1000000,2) as estimated_coffee_consumer_in_millions from city
)
select cr.city_name,total_revenue, cr.estimated_rent, ct.per_city_avg_sale, ct.total_customers, cr.estimated_coffee_consumer_in_millions,
	round(cr.estimated_rent/ct.total_customers,2) as avg_rent_per_cust
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 2 desc;


