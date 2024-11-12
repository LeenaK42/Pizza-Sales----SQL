create database pizzahut;
use pizzahut;

#  Retrieve the total number of orders placed.

select count(order_id) as Total_Orders from orders;

# Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
FROM
    order_details o
        INNER JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
# Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

#Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.quantity)
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY COUNT(od.quantity) DESC
LIMIT 1;

#List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) as Quantity
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        INNER JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;

#--------------------------------------------------------------------------------------------------------
#Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) as Quantity
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        INNER JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by Quantity desc;   

#Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) AS Hour, COUNT(order_id) AS Order_count
FROM
    orders
GROUP BY HOUR(time);

#Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) as pizza_count from pizza_types
group by category;

#Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 2)
FROM
    (SELECT 
        date, SUM(od.quantity) AS quantity
    FROM
        order_details od
    INNER JOIN orders o ON od.order_id = o.order_id
    GROUP BY date) AS order_quantity;

#Determine the top 3 most ordered pizza types based on revenue.																												

SELECT 
    pt.name,
    ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
FROM
    order_details o
        INNER JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        INNER JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Total_revenue DESC
LIMIT 3;

#-------------------------------------------------------------------------------------------------------

#Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT(ROUND((SUM(od.quantity * p.price) / (SELECT 
                            ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
                        FROM
                            order_details o
                                INNER JOIN
                            pizzas p ON o.pizza_id = p.pizza_id)) * 100,
                    2),
            '%') AS revenue
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;
    
#Analyze the cumulative revenue generated over time.

select date,
round(sum(revenue) over(order by date),2) as cum_revenue
from
(SELECT o.date,
    ROUND(SUM(od.quantity * p.price), 2) AS Revenue
FROM order_details od
INNER JOIN pizzas p 
ON od.pizza_id = p.pizza_id
inner join orders o
on od.order_id=o.order_id
group by o.date) as sales; 

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pt.category, pt.name,
sum(od.quantity*p.price) as revenue
from pizza_types pt
inner join pizzas p
on pt.pizza_type_id=p.pizza_type_id
inner join order_details od
on od.pizza_id=p.pizza_id
group by pt.category, pt.name) as a) as b
where rn<=3;

     










