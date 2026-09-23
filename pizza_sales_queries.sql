

create table pizzas(
pizza_id varchar(100) primary key,
pizza_type_id varchar(100),	
size varchar(10),		
price numeric(10,2)		
);

select * from pizzas;

create table pizza(
pizza_type_id	varchar(100),
name	varchar(100),
category	varchar(100),
ingredients	text
);

select * from pizza;

create table orders(
order_id int primary key,
date date,
time time
);

select * from orders;


create table orderr(
order_details_id int primary key,
order_id int,	
pizza_id varchar(100),	
quantity int	
);

select * from orderr;


--1.Retrieve the total number of orders placed.

SELECT
	COUNT(ORDER_ID)
FROM
	ORDERS;

--2.Calculate the total revenue generated from pizza sales.

SELECT
	SUM(O.QUANTITY * P.PRICE) AS REVENUE
FROM
	ORDERR O
	JOIN PIZZAS P ON O.PIZZA_ID = P.PIZZA_ID;


--3.Identify the highest-priced pizza.

SELECT
	*
FROM
	PIZZAS;

SELECT
	PI.NAME,
	P.PRICE
FROM
	PIZZAS P
	JOIN PIZZA PI ON P.PIZZA_TYPE_ID = PI.PIZZA_TYPE_ID
ORDER BY
	PRICE DESC
LIMIT
	1;

	
--4.Identify the most common pizza size ordered.

SELECT
	P.SIZE,
	SUM(O.QUANTITY) AS TOTAL
FROM
	PIZZAS P
	JOIN ORDERR O ON P.PIZZA_ID = O.PIZZA_ID
GROUP BY
	P.SIZE
ORDER BY
	TOTAL DESC;


--5.List the top 5 most ordered pizza types along with their quantities.

SELECT
	PI.NAME,
	SUM(O.QUANTITY) AS TOTAL_QUANTITY
FROM
	PIZZA PI
	JOIN PIZZAS P ON PI.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
	JOIN ORDERR O ON O.PIZZA_ID = P.PIZZA_ID
GROUP BY
	PI.NAME
ORDER BY
	TOTAL_QUANTITY DESC
LIMIT
	5;






--Intermediate:

--6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT
	PI.CATEGORY,
	SUM(O.QUANTITY) AS TOTAL_QUANTITY
FROM
	PIZZA PI
	JOIN PIZZAS P ON PI.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
	JOIN ORDERR O ON P.PIZZA_ID = O.PIZZA_ID
GROUP BY
	PI.CATEGORY
ORDER BY
	TOTAL_QUANTITY DESC;



--7.Determine the distribution of orders by hour of the day.

SELECT
	EXTRACT(
		HOUR
		FROM
			TIME
	) AS BY_HOUR,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
GROUP BY
	BY_HOUR
ORDER BY
	ORDER_COUNT DESC;


--8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT
	CATEGORY,
	COUNT(NAME) AS PIZZA_TYPE
FROM
	PIZZA
GROUP BY
	CATEGORY;








--9.Group the orders by date and calculate the average number of pizzas ordered per day.




SELECT
	ROUND(AVG(TOTAL_QUANTITY), 0) AS AVERAGE_PIZZAS_ORDERED_PER_DAY
FROM
	(
		SELECT
			O.DATE,
			SUM(OS.QUANTITY) AS TOTAL_QUANTITY
		FROM
			ORDERS O
			JOIN ORDERR OS ON O.ORDER_ID = OS.ORDER_ID
		GROUP BY
			O.DATE
	) AS ORDERS_DATA;










--10.Determine the top 3 most ordered pizza types based on revenue.



SELECT
	PI.NAME,
	SUM(OS.QUANTITY * P.PRICE) AS REVENUE
FROM
	ORDERR OS
	JOIN PIZZAS P ON OS.PIZZA_ID = P.PIZZA_ID
	JOIN PIZZA PI ON PI.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
GROUP BY
	PI.NAME
ORDER BY
	REVENUE DESC
LIMIT
	3;







--Advanced:



--11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT
	CATEGORY,
	ROUND(REVENUE * 100.0 / SUM(REVENUE) OVER (), 2) AS PERCENTAGE_CONTRIBUTION
FROM
	(
		SELECT
			PI.CATEGORY,
			SUM(P.PRICE * OS.QUANTITY) AS REVENUE
		FROM
			PIZZAS P
			JOIN ORDERR OS ON P.PIZZA_ID = OS.PIZZA_ID
			JOIN PIZZA PI ON PI.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
		GROUP BY
			PI.CATEGORY
		ORDER BY
			REVENUE DESC
	) AS DATA;




--12.Analyze the cumulative revenue generated over time.



SELECT
	DATE,
	REVENUE,
	SUM(REVENUE) OVER (
		ORDER BY
			DATE
	) AS CUMULATIVE_REVENUE
FROM
	(
		SELECT
			O.DATE,
			SUM(P.PRICE * OS.QUANTITY) AS REVENUE
		FROM
			PIZZAS P
			JOIN ORDERR OS ON P.PIZZA_ID = OS.PIZZA_ID
			JOIN ORDERS O ON O.ORDER_ID = OS.ORDER_ID
		GROUP BY
			O.DATE
	) AS SALES;



--13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT
	NAME,
	CATEGORY,
	REVENUE
FROM
	(
		SELECT
			NAME,
			CATEGORY,
			REVENUE,
			RANK() OVER (
				PARTITION BY
					CATEGORY
				ORDER BY
					REVENUE DESC
			) AS REV
		FROM
			(
				SELECT
					PI.NAME,
					PI.CATEGORY,
					SUM(P.PRICE * OS.QUANTITY) AS REVENUE
				FROM
					PIZZAS P
					JOIN ORDERR OS ON OS.PIZZA_ID = P.PIZZA_ID
					JOIN PIZZA PI ON PI.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
				GROUP BY
					PI.NAME,
					PI.CATEGORY
			) AS INFO
	) AS RANKED_INFO
WHERE
	REV <= 3;
