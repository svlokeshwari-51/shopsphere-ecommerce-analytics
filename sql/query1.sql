CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(20),
    age INTEGER,
    state VARCHAR(50),
    signup_date DATE,
    acquisition_channel VARCHAR(50),
    city VARCHAR(100)
);

CREATE TABLE categories (
    category_id VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(150),
    category_id VARCHAR(20),
    brand VARCHAR(100),
    unit_cost NUMERIC(12,2)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date DATE,
    order_status VARCHAR(30)
);

CREATE TABLE order_items (
    order_item_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount_amount NUMERIC(12,2),
    gross_value NUMERIC(12,2),
    net_item_value NUMERIC(12,2)
);

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20),
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    payment_amount NUMERIC(12,2)
);

CREATE TABLE returns (
    return_id VARCHAR(20) PRIMARY KEY,
    order_item_id VARCHAR(20),
    return_date DATE,
    return_quantity INTEGER,
    refund_amount NUMERIC(12,2)
);

CREATE TABLE marketing (
    marketing_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    acquisition_date DATE,
    acquisition_channel VARCHAR(50),
    acquisition_cost NUMERIC(12,2)
);

CREATE TABLE experiment_sessions (
    session_id VARCHAR(30) PRIMARY KEY,
    experiment_id VARCHAR(30),
    customer_id VARCHAR(20),
    session_date DATE,
    variant VARCHAR(30),
    product_views INTEGER,
    added_to_cart INTEGER,
    purchased INTEGER
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

select count(*) from customers;
 select * from custome

ALTER USER postgres WITH PASSWORD 'okpostgres24';


select count(*) from experiment_sessions;
SELECT *
FROM experiment_sessions
LIMIT 5;

DROP TABLE orders;

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date TIMESTAMP,
    order_status VARCHAR(30),
    shipping_id VARCHAR(30),
    payment_id VARCHAR(30)
);
drop table orders;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'payments'
ORDER BY ordinal_position;


SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'returns', COUNT(*) FROM returns
UNION ALL
SELECT 'marketing', COUNT(*) FROM marketing
UNION ALL
SELECT 'experiment_sessions', COUNT(*) FROM experiment_sessions
ORDER BY table_name;


DROP TABLE IF EXISTS returns;

CREATE TABLE returns (
    return_id VARCHAR(20) PRIMARY KEY,
    order_item_id VARCHAR(20),
    return_date TIMESTAMP,
    return_reason VARCHAR(100),
    return_quantity INTEGER,
    refund_amount NUMERIC(12,2)
);

DROP TABLE IF EXISTS marketing;

CREATE TABLE marketing (
    marketing_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    acquisition_channel VARCHAR(50),
    campaign_id VARCHAR(30),
    acquisition_date TIMESTAMP,
    acquisition_cost NUMERIC(12,2)
);

DROP TABLE IF EXISTS payments;

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20),
    payment_method VARCHAR(50),
    payment_amount NUMERIC(12,2),
    payment_date TIMESTAMP,
    payment_status VARCHAR(30)
);

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
    SUM(net_item_value) AS total_revenue
FROM order_items;

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

select
    SUM(quantity) AS total_units_sold
FROM order_items;

SELECT
    SUM(net_item_value) AS net_sales
FROM order_items;

SELECT
    payment_status,
    COUNT(*) AS payment_count,
    SUM(payment_amount) AS payment_value
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;

SELECT
    COUNT(*) AS returned_items,
    SUM(return_quantity) AS returned_units,
    SUM(refund_amount) AS total_refunds
FROM returns;

SELECT
    COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled';

SELECT DISTINCT order_status
FROM orders;

SELECT
    SUM(oi.net_item_value) AS realized_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';

SELECT
    SUM(oi.quantity * p.unit_cost) AS total_product_cost
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

SELECT
    SUM(oi.net_item_value) AS revenue,
    SUM(oi.quantity * p.unit_cost) AS product_cost,
    SUM(oi.net_item_value - (oi.quantity * p.unit_cost)) AS profit
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

--which categor
SELECT
    SUM(oi.net_item_value) AS revenue,
    SUM(oi.quantity * p.unit_cost) AS product_cost,
    SUM(oi.net_item_value - (oi.quantity * p.unit_cost)) AS profit,
    ROUND(
        SUM(oi.net_item_value - (oi.quantity * p.unit_cost))
        / NULLIF(SUM(oi.net_item_value), 0) * 100,
        2
    ) AS profit_margin_pct
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';


SELECT
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.net_item_value) AS revenue,
    SUM(oi.quantity * p.unit_cost) AS product_cost,
    SUM(oi.net_item_value - (oi.quantity * p.unit_cost)) AS profit,
    ROUND(
        SUM(oi.net_item_value - (oi.quantity * p.unit_cost))
        / NULLIF(SUM(oi.net_item_value), 0) * 100,
        2
    ) AS profit_margin_pct
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY profit DESC;

--discount impact by category
SELECT
    c.category_name,
    SUM(oi.gross_value) AS gross_sales,
    SUM(oi.discount_amount) AS total_discount,
    SUM(oi.net_item_value) AS net_sales,
    SUM(oi.quantity * p.unit_cost) AS product_cost,
    SUM(
        oi.net_item_value - (oi.quantity * p.unit_cost)
    ) AS profit,
    ROUND(
        SUM(oi.discount_amount)
        / NULLIF(SUM(oi.gross_value), 0) * 100,
        2
    ) AS discount_rate_pct,
    ROUND(
        SUM(oi.net_item_value - (oi.quantity * p.unit_cost))
        / NULLIF(SUM(oi.net_item_value), 0) * 100,
        2
    ) AS profit_margin_pct
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY discount_rate_pct DESC;


--discount at different levels
SELECT
    CASE
        WHEN discount_amount = 0 THEN 'No Discount'
        WHEN discount_amount / NULLIF(gross_value, 0) < 0.10 THEN '0-10%'
        WHEN discount_amount / NULLIF(gross_value, 0) < 0.20 THEN '10-20%'
        WHEN discount_amount / NULLIF(gross_value, 0) < 0.30 THEN '20-30%'
        ELSE '30%+'
    END AS discount_band,

    COUNT(*) AS order_items,
    SUM(net_item_value) AS revenue,
    SUM(net_item_value - (quantity * p.unit_cost)) AS profit,

    ROUND(
        SUM(net_item_value - (quantity * p.unit_cost))
        / NULLIF(SUM(net_item_value), 0) * 100,
        2
    ) AS profit_margin_pct

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY discount_band
ORDER BY profit desc;

--overall return impact
SELECT
    COUNT(*) AS return_records,
    SUM(return_quantity) AS returned_units,
    SUM(refund_amount) AS total_refund
FROM returns;

SELECT
    SUM(oi.quantity) AS completed_units
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';

--return reasons

SELECT
    return_reason,
    COUNT(*) AS return_count,
    SUM(return_quantity) AS returned_units,
    SUM(refund_amount) AS refund_amount
FROM returns
GROUP BY return_reason
ORDER BY refund_amount DESC;

--returns by category

SELECT
    c.category_name,
    SUM(r.return_quantity) AS returned_units,
    SUM(r.refund_amount) AS refund_amount,
    COUNT(*) AS return_records
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY returned_units DESC;

--find products with most returns

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(r.return_quantity) AS returned_units,
    SUM(r.refund_amount) AS refund_amount
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY returned_units DESC
LIMIT 10;


--new vs retruning customers
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_orders DESC;

SELECT
    CASE
        WHEN completed_orders = 1 THEN 'One-time customer'
        ELSE 'Returning customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders
    FROM orders o
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
) customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;

--customer revenue with top 10

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.net_item_value) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY customer_revenue DESC
limit 10;

--customer acquisition channel

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.net_item_value) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;


--revenue per acquired customer

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    SUM(oi.net_item_value) AS revenue,
    ROUND(
        SUM(oi.net_item_value)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;

--acquisition cost

SELECT
    m.acquisition_channel,
    COUNT(DISTINCT m.customer_id) AS acquired_customers,
    SUM(m.acquisition_cost) AS acquisition_cost
FROM marketing m
GROUP BY m.acquisition_channel
ORDER BY acquisition_cost DESC;

--Customer Acquisition Cost vs Revenue
--Revenue per customer

WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.net_item_value) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    SUM(COALESCE(cr.revenue, 0)) AS revenue
FROM customers c
LEFT JOIN customer_revenue cr
    ON c.customer_id = cr.customer_id
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;

--Check marketing records per customer

SELECT
    customer_id,
    COUNT(*) AS marketing_records
FROM marketing
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY marketing_records DESC
LIMIT 10;

--marketing channel performance

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COALESCE(SUM(oi.net_item_value), 0) AS revenue
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;

--acquisition cost per customer

SELECT
    acquisition_channel,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(acquisition_cost) AS total_acquisition_cost,
    ROUND(
        SUM(acquisition_cost)
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS acquisition_cost_per_customer
FROM marketing
GROUP BY acquisition_channel
ORDER BY total_acquisition_cost DESC;

--city wise performance

SELECT
    COALESCE(c.city, 'Unknown') AS city,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.net_item_value) AS revenue,
    SUM(
        oi.net_item_value - (oi.quantity * p.unit_cost)
    ) AS profit
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY COALESCE(c.city, 'Unknown')
ORDER BY profit DESC;

--monthly revenue and profit

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(oi.net_item_value) AS revenue,
    SUM(
        oi.net_item_value - (oi.quantity * p.unit_cost)
    ) AS profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

--monthly revenue growth

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.net_item_value) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', o.order_date)
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue - LAG(revenue) OVER (ORDER BY month)
        )
        / NULLIF(
            LAG(revenue) OVER (ORDER BY month),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_sales
ORDER BY month;

--monthly profit margin

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(oi.net_item_value) AS revenue,
    SUM(
        oi.net_item_value - (oi.quantity * p.unit_cost)
    ) AS profit,
    ROUND(
        SUM(
            oi.net_item_value - (oi.quantity * p.unit_cost)
        )
        / NULLIF(SUM(oi.net_item_value), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

--customer order sequence

WITH customer_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS order_number
    FROM orders
    WHERE order_status = 'Completed'
)

SELECT *
FROM customer_orders
ORDER BY customer_id, order_number
LIMIT 50;

--One-time vs returning customers

WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN completed_orders = 1 THEN 'One-time'
        ELSE 'Returning'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_order_counts
GROUP BY
    CASE
        WHEN completed_orders = 1 THEN 'One-time'
        ELSE 'Returning'
    END
ORDER BY customer_count DESC;

--Time between purchases — LAG()

WITH customer_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM orders
    WHERE order_status = 'Completed'
)

SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    ROUND(
        EXTRACT(
            EPOCH FROM (order_date - previous_order_date)
        ) / 86400,
        2
    ) AS days_since_previous_order
FROM customer_orders
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_date
LIMIT 50;

--Rank customers by revenue

WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.net_item_value) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)

SELECT
    customer_id,
    revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank
LIMIT 20;

--Top customers by category

WITH customer_category_revenue AS (
    SELECT
        o.customer_id,
        c.category_name,
        SUM(oi.net_item_value) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN categories c
        ON p.category_id = c.category_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        c.category_name
),

ranked_customers AS (
    SELECT
        customer_id,
        category_name,
        revenue,
        RANK() OVER (
            PARTITION BY category_name
            ORDER BY revenue DESC
        ) AS category_rank
    FROM customer_category_revenue
)

SELECT
    customer_id,
    category_name,
    revenue,
    category_rank
FROM ranked_customers
WHERE category_rank <= 3
ORDER BY category_name, category_rank;

--Advanced customer Analytics
--1. Customer Purchase Frequency

SELECT
    completed_orders,
    COUNT(*) AS customer_count
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) customer_orders
GROUP BY completed_orders
ORDER BY completed_orders;

--Average Orders per Customer

SELECT
    ROUND(
        COUNT(DISTINCT order_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS average_orders_per_customer
FROM orders
WHERE order_status = 'Completed';

--Customer Revenue Segments

WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.net_item_value) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)

SELECT
    CASE
        WHEN revenue < 5000 THEN 'Low Value'
        WHEN revenue < 15000 THEN 'Medium Value'
        WHEN revenue < 30000 THEN 'High Value'
        ELSE 'Very High Value'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_customer_revenue
FROM customer_revenue
GROUP BY
    CASE
        WHEN revenue < 5000 THEN 'Low Value'
        WHEN revenue < 15000 THEN 'Medium Value'
        WHEN revenue < 30000 THEN 'High Value'
        ELSE 'Very High Value'
    END
ORDER BY total_revenue DESC;

--RFM analysis
--Step 1 — Calculate RFM values
WITH customer_rfm AS (
    SELECT
        o.customer_id,

        MAX(o.order_date) AS last_purchase_date,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(oi.net_item_value) AS monetary

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)

SELECT
    customer_id,
    last_purchase_date,
    frequency,
    ROUND(monetary, 2) AS monetary
FROM customer_rfm
ORDER BY monetary DESC
LIMIT 20;

--covert rfm values into scores

WITH customer_rfm AS (
    SELECT
        o.customer_id,
        MAX(o.order_date) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.net_item_value) AS monetary
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),

rfm_scores AS (
    SELECT
        customer_id,

        NTILE(5) OVER (
            ORDER BY last_purchase_date DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM customer_rfm
)

SELECT
    customer_id,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total_score
FROM rfm_scores
ORDER BY rfm_total_score DESC
LIMIT 20;

--find each customers first purchase month 

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC(
            'month',
            MIN(order_date)
        ) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)

SELECT *
FROM first_purchase
ORDER BY cohort_month, customer_id
LIMIT 50;

--Customer activity by month

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC(
            'month',
            MIN(order_date)
        ) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC(
            'month',
            o.order_date
        ) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Completed'
)

SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activity
GROUP BY cohort_month, activity_month
ORDER BY cohort_month, activity_month;

--Calculate cohort month number

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Completed'
)

SELECT
    cohort_month,
    activity_month,
    (
        DATE_PART(
            'year',
            AGE(activity_month, cohort_month)
        ) * 12
        +
        DATE_PART(
            'month',
            AGE(activity_month, cohort_month)
        )
    )::INT AS month_number,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activity
GROUP BY
    cohort_month,
    activity_month
ORDER BY
    cohort_monthWITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Completed'
),

cohort_activity AS (
    SELECT
        cohort_month,
        (
            DATE_PART(
                'year',
                AGE(activity_month, cohort_month)
            ) * 12
            +
            DATE_PART(
                'month',
                AGE(activity_month, cohort_month)
            )
        )::INT AS month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM customer_activity
    GROUP BY
        cohort_month,
        activity_month
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    ca.month_number,
    ca.active_customers,
    cs.cohort_customers,
    ROUND(
        ca.active_customers * 100.0
        / NULLIF(cs.cohort_customers, 0),
        2
    ) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs
    ON ca.cohort_month = cs.cohort_month
ORDER BY
    ca.cohort_month,
    ca.month_number;
    activity_month;

  --Calculate retention %

  WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Completed'
),

cohort_activity AS (
    SELECT
        cohort_month,
        (
            DATE_PART(
                'year',
                AGE(activity_month, cohort_month)
            ) * 12
            +
            DATE_PART(
                'month',
                AGE(activity_month, cohort_month)
            )
        )::INT AS month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM customer_activity
    GROUP BY
        cohort_month,
        activity_month
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    ca.month_number,
    ca.active_customers,
    cs.cohort_customers,
    ROUND(
        ca.active_customers * 100.0
        / NULLIF(cs.cohort_customers, 0),
        2
    ) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs
    ON ca.cohort_month = cs.cohort_month
ORDER BY
    ca.cohort_month,
    ca.month_number;


--Statistics & A/B Testing
--Understand the experiment

SELECT
    experiment_id,
    variant,
    COUNT(*) AS sessions
FROM experiment_sessions
GROUP BY experiment_id, variant
ORDER BY experiment_id, variant;

--Check whether the groups are reasonably balanced

select
    variant,
    COUNT(*) AS sessions,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS session_percentage
FROM experiment_sessions
GROUP BY variant
ORDER BY variant;

--Calculate conversion rate
SELECT
    variant,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    ROUND(
        SUM(purchased) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct
FROM experiment_sessions
GROUP BY variant
ORDER BY variant;

--Calculate conversion uplift

WITH conversion AS (
    SELECT
        variant,
        COUNT(*) AS sessions,
        SUM(purchased) AS purchases,
        SUM(purchased)::NUMERIC / COUNT(*) AS conversion_rate
    FROM experiment_sessions
    GROUP BY variant
)

SELECT
    MAX(CASE WHEN variant = 'Control'
        THEN conversion_rate END) AS control_conversion,

    MAX(CASE WHEN variant = 'Treatment'
        THEN conversion_rate END) AS treatment_conversion,

    ROUND(
        (
            MAX(CASE WHEN variant = 'Treatment'
                THEN conversion_rate END)
            -
            MAX(CASE WHEN variant = 'Control'
                THEN conversion_rate END)
        ) * 100,
        2
    ) AS absolute_uplift_percentage_points,

    ROUND(
        (
            MAX(CASE WHEN variant = 'Treatment'
                THEN conversion_rate END)
            /
            NULLIF(
                MAX(CASE WHEN variant = 'Control'
                    THEN conversion_rate END),
                0
            ) - 1
        ) * 100,
        2
    ) AS relative_uplift_pct

FROM conversion;

-- Validate with exact purchase counts

SELECT
    variant,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    ROUND(
        SUM(purchased)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        4
    ) AS conversion_rate_pct
FROM experiment_sessions
GROUP BY variant
ORDER BY variant;

SELECT
    customer_id,
    COUNT(DISTINCT variant) AS variants_seen
FROM experiment_sessions
GROUP BY customer_id
HAVING COUNT(DISTINCT variant) > 1
LIMIT 20;

-----------------

SELECT
    variant,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(
        SUM(purchased)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        4
    ) AS conversion_rate_pct
FROM experiment_sessions
GROUP BY variant
ORDER BY variant;

-------------------------

SELECT
    COUNT(*) AS customers_in_multiple_variants
FROM (
    SELECT customer_id
    FROM experiment_sessions
    GROUP BY customer_id
    HAVING COUNT(DISTINCT variant) > 1
) AS mixed_assignment;

---Check whether there are multiple experiments

SELECT
    experiment_id,
    variant,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(
        SUM(purchased)::NUMERIC / COUNT(*) * 100,
        4
    ) AS conversion_rate_pct
FROM experiment_sessions
GROUP BY experiment_id, variant
ORDER BY experiment_id, variant;

-----Find customers assigned to multiple variants within each experiment

SELECT
    experiment_id,
    COUNT(*) AS customers_in_multiple_variants
FROM (
    SELECT
        experiment_id,
        customer_id
    FROM experiment_sessions
    GROUP BY experiment_id, customer_id
    HAVING COUNT(DISTINCT variant) > 1
) AS mixed_assignment
GROUP BY experiment_id
ORDER BY experiment_id;

----check conversion at the customer level

WITH customer_summary AS (
    SELECT
        customer_id,
        MAX(CASE WHEN variant = 'Control' THEN 1 ELSE 0 END) AS saw_control,
        MAX(CASE WHEN variant = 'Treatment' THEN 1 ELSE 0 END) AS saw_treatment,
        MAX(CASE WHEN variant = 'Control' AND purchased = 1
                 THEN 1 ELSE 0 END) AS control_purchase,
        MAX(CASE WHEN variant = 'Treatment' AND purchased = 1
                 THEN 1 ELSE 0 END) AS treatment_purchase
    FROM experiment_sessions
    WHERE experiment_id = 'EXP_001'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN saw_control = 1 AND saw_treatment = 1 THEN 'Both variants'
        WHEN saw_control = 1 THEN 'Control only'
        WHEN saw_treatment = 1 THEN 'Treatment only'
    END AS exposure_group,
    COUNT(*) AS customers,
    SUM(control_purchase) AS customers_converted_in_control,
    SUM(treatment_purchase) AS customers_converted_in_treatment
FROM customer_summary
GROUP BY
    CASE
        WHEN saw_control = 1 AND saw_treatment = 1 THEN 'Both variants'
        WHEN saw_control = 1 THEN 'Control only'
        WHEN saw_treatment = 1 THEN 'Treatment only'
    END
ORDER BY exposure_group;

