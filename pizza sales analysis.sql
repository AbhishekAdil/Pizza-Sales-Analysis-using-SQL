CREATE DATABASE pizzahut;

-- import orders table data into sql
-- create a orders table

CREATE TABLE orders(
	order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY(order_id)
);

SELECT * FROM orders;

-- import order_details table data into sql
-- create a order_details table

CREATE TABLE order_details(
	order_details_id INT NOT NULL,
	order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY(order_details_id)
);

SELECT * FROM order_details;

/* Basic */

/* Q1: Retrive the total number of orders placed.*/

SELECT COUNT(order_id) AS total_order FROM orders;

/* Q2: Calculate the total revenue generated from pizza sales. */

SELECT ROUND(SUM(pizzas.price * order_details.quantity), 2) AS total_revenue
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id;

/* Q3: Identify the highest - priced pizza. */

SELECT pizza_types.name, pizza_types.category, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

/* Q4: Identify the most common pizza size ordered. */

SELECT pizzas.size, COUNT(order_details.order_id) AS common_pizza_size
FROM pizzas 
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY common_pizza_size DESC
LIMIT 1;

/* Q5: List top 5 most ordered pizza types along with their quantities. */

SELECT pizza_types.name, pizza_types.category,
SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name, pizza_types.category
ORDER BY quantity DESC
LIMIT 5;


/* Intermediate */

/* Q1: Join the necessary tables to find the total quantity of each pizza category
orderes. */

SELECT pizza_types.category,
SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

/* Q2: Determine the distribution of orders by hour of the day. */

SELECT HOUR(order_time) AS hour_of_the_day, COUNT(order_id) AS orders
FROM orders
GROUP BY hour_of_the_day
ORDER BY orders DESC;

/* Q3: Join relevant tables to find the category-wise distribution of pizzas. */

SELECT category, COUNT(name) FROM pizza_types
GROUP BY category;

/* Q4: Group the orders by date and calculate the average number of pizzas ordered
 per day. */

SELECT ROUND(AVG(quantity), 0) AS avg_order_per_day
FROM (SELECT orders.order_date, SUM(order_details.quantity) AS quantity
	FROM orders 
    JOIN order_details 
    ON orders.order_id = order_details.order_id 
    GROUP BY orders.order_date) AS order_per_day;

/* Q5: Determine the top 3 most ordered pizza based on revenue. */

SELECT pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/* Advanced*/

/* Q1: Calculate the percentage contribution of each pizza type to total revenue. */

WITH total_sales AS(
	SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total
    FROM order_details
    JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
)
SELECT pizza_types.category,
ROUND(SUM(order_details.quantity * pizzas.price) / 
(SELECT total FROM total_sales) * 100, 2) AS revenue
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

/* Q2: Analyze the cumulative revenue generated over time. */

SELECT order_date, revenue,
SUM(revenue) OVER(ORDER BY order_date) as cum_revenue
FROM(
	SELECT orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders
    ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
    ) as per_day_revenue;

/* Q3: Determine the top 3 most ordered pizza types based on revenue 
for each pizza category. */

SELECT category, name, revenue 
FROM
(
SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) as pizza_ranking
FROM 
(
SELECT pizza_types.category, pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name
) AS pizza_revenue
) AS ranking_pizza_revenue
WHERE pizza_ranking <= 3;