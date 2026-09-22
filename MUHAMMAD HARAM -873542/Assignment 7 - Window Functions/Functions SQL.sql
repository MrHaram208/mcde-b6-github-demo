7.1
SELECT
    product_id,
    product_name,
    category_id,
    list_price,

    ROW_NUMBER() OVER (
        ORDER BY list_price DESC
    ) AS overall_row_number,

    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS category_row_number

FROM production.products;

7.2
SELECT
    product_id,
    product_name,
    category_id,
    list_price,

    ROW_NUMBER() OVER (
        ORDER BY list_price DESC
    ) AS overall_row_number,

    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS category_row_number

    7.3
    WITH monthly_revenue AS (
    SELECT
        o.store_id,
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS current_month_revenue
    FROM sales.orders AS o
    JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.store_id,
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    store_id,
    revenue_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (
        PARTITION BY store_id
        ORDER BY revenue_month
    ) AS previous_month_revenue,
    current_month_revenue -
        LAG(current_month_revenue) OVER (
            PARTITION BY store_id
            ORDER BY revenue_month
        ) AS revenue_difference
FROM monthly_revenue
ORDER BY store_id, revenue_month;

FROM production.products;

7.4
WITH monthly_revenue AS (
    SELECT
        o.store_id,
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS current_month_revenue
    FROM sales.orders AS o
    JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.store_id,
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    store_id,
    revenue_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (
        PARTITION BY store_id
        ORDER BY revenue_month
    ) AS previous_month_revenue,
    current_month_revenue -
        LAG(current_month_revenue) OVER (
            PARTITION BY store_id
            ORDER BY revenue_month
        ) AS revenue_difference
FROM monthly_revenue
ORDER BY store_id, revenue_month;

7.5
SELECT
    o.order_id,
    o.order_date,
    SUM(
        oi.quantity * oi.list_price * (1 - oi.discount)
    ) AS order_revenue,
    SUM(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount))
    ) OVER (
        ORDER BY o.order_date, o.order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM sales.orders AS o
JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.order_date
ORDER BY
    o.order_date,
    o.order_id;

    7.6
    When ORDER BY is specified in a window function, the default window frame is generally RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. FIRST_VALUE() works correctly because the first row of the partition is included in the frame for every row. However, LAST_VALUE() returns the last value within the current window frame, not necessarily the last row of the entire partition. Since the default frame ends at the current row, LAST_VALUE() may return the current row's value instead of the actual final value. Using RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING extends the frame to the entire partition, allowing LAST_VALUE() to return the actual last value.
