--CREATE TABLE sales (
--  "customer_id" VARCHAR(1),
--  "order_date" DATE,
--  "product_id" INTEGER
--);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

--CREATE TABLE menu (
--  "product_id" INTEGER,
--  "product_name" VARCHAR(5),
--  "price" INTEGER
--);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

--CREATE TABLE members (
--  "customer_id" VARCHAR(1),
--  "join_date" DATE
--);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


-- 1. What is the total amount each customer spent at the restaurant?
SELECT DISTINCT(customer_id) , SUM(menu.price) AS Amount_spent
FROM sales 
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT DISTINCT(customer_id), COUNT(DISTINCT(order_date)) AS Days_Visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT
    DISTINCT(s.customer_id),
    m.product_name AS FirstPurchasedItem
FROM
    sales s
INNER JOIN
    menu m ON s.product_id = m.product_id
WHERE
    s.order_date = (
        SELECT
            MIN(order_date)
        FROM
            sales
		WHERE 
		    customer_id = s.customer_id
    )
ORDER BY s.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 
menu.product_name, COUNT(menu.product_name) AS order_times
FROM menu
INNER JOIN sales ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY order_times DESC;

-- 5. Which item was the most popular for each customer?
SELECT TOP 1
menu.product_name,COUNT(sales.product_id) AS no_of_orders
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
GROUP BY sales.product_id,menu.product_name
ORDER BY no_of_orders DESC;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT menu.product_name,(sales.customer_id)
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE join_date < order_date;

-- 7. Which item was purchased just before the customer became a member?
SELECT menu.product_name,(sales.customer_id)
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE join_date > order_date;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT DISTINCT(members.customer_id),menu.product_name, SUM(menu.price) AS amount_spent
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE join_date > order_date
GROUP BY members.customer_id, menu.product_name;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH order_points AS (
    SELECT
        s.customer_id,
        m.price * 10 AS total_points
    FROM
        sales s
        JOIN menu m ON s.product_id = m.product_id
)
SELECT
    customer_id,
    SUM(total_points) AS total_customer_points
FROM
    order_points
GROUP BY
    customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?
WITH order_points AS (
    SELECT
        s.customer_id,
        m.price * m.price AS total_points
    FROM
        sales s
        JOIN menu m ON s.product_id = m.product_id
		JOIN members ON members.customer_id = s.customer_id
	WHERE join_date < order_date
)
SELECT
    customer_id,
    SUM(total_points) AS total_customer_points
FROM
    order_points
WHERE customer_id IN ('A','B')
GROUP BY
    customer_id;
