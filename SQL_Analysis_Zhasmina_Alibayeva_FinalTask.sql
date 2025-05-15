Task 1
WITH sales_per_region AS (
    SELECT
        ch.channel_desc,
        co.country_region,
        ROUND(SUM(s.quantity_sold), 2) AS sales
    FROM sh.sales s
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON cu.country_id = co.country_id
    GROUP BY ch.channel_desc, co.country_region
),
with_max_sales AS (
    SELECT *,
        MAX(sales) OVER (PARTITION BY channel_desc) AS max_sales_per_channel
    FROM sales_per_region
),
with_percent AS (
    SELECT
        channel_desc,
        country_region,
        sales,
        ROUND(100.0 * sales / max_sales_per_channel, 2) || '%' AS "SALES %"
    FROM with_max_sales
)
SELECT *
FROM with_percent
ORDER BY sales DESC;

Task 2
--Determine the sales for each subcategory from 1998 to 2001.
SELECT
    p.prod_subcategory,
    t.calendar_year,
    SUM(s.amount_sold) AS total_sales
FROM sh.sales s
JOIN sh.products p ON s.prod_id = p.prod_id
JOIN sh.times t ON s.time_id = t.time_id
WHERE t.calendar_year BETWEEN 1997 AND 2001
GROUP BY p.prod_subcategory, t.calendar_year
ORDER BY p.prod_subcategory, t.calendar_year;

--Calculate the sales for the previous year for each subcategory.
WITH yearly_sales AS (
    SELECT
    p.prod_subcategory,
    t.calendar_year,
    SUM(s.amount_sold) AS total_sales
FROM sh.sales s
JOIN sh.products p ON s.prod_id = p.prod_id
JOIN sh.times t ON s.time_id = t.time_id
WHERE t.calendar_year BETWEEN 1997 AND 2001
GROUP BY p.prod_subcategory, t.calendar_year
ORDER BY p.prod_subcategory, t.calendar_year
)
SELECT *,
    LAG(total_sales) OVER (
        PARTITION BY prod_subcategory
        ORDER BY calendar_year
    ) AS previous_year_sales
FROM yearly_sales;
--Identify subcategories where the sales from 1998 to 2001 are consistently higher than the previous year.
WITH yearly_sales AS (
    SELECT
        p.prod_subcategory,
        t.calendar_year,
        SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.products p ON s.prod_id = p.prod_id
    JOIN sh.times t ON s.time_id = t.time_id
    WHERE t.calendar_year BETWEEN 1997 AND 2001
    GROUP BY p.prod_subcategory, t.calendar_year
),
with_lag AS (
    SELECT *,
        LAG(total_sales) OVER (
            PARTITION BY prod_subcategory
            ORDER BY calendar_year
        ) AS previous_year_sales
    FROM yearly_sales
),
growth_flags AS (
    SELECT *,
        CASE 
            WHEN total_sales > previous_year_sales THEN 1
            ELSE 0
        END AS is_growth
    FROM with_lag
    WHERE calendar_year BETWEEN 1998 AND 2001
)
SELECT *
FROM growth_flags
ORDER BY prod_subcategory, calendar_year;

--Generate a dataset with a single column containing the identified prod_subcategory values.
WITH yearly_sales AS (
    SELECT
        p.prod_subcategory,
        t.calendar_year,
        SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.products p ON s.prod_id = p.prod_id
    JOIN sh.times t ON s.time_id = t.time_id
    WHERE t.calendar_year BETWEEN 1997 AND 2001
    GROUP BY p.prod_subcategory, t.calendar_year
),
with_lag AS (
    SELECT *,
        LAG(total_sales) OVER (
            PARTITION BY prod_subcategory
            ORDER BY calendar_year
        ) AS previous_year_sales
    FROM yearly_sales
),
growth_flags AS (
    SELECT *,
        CASE 
            WHEN total_sales > previous_year_sales THEN 1
            ELSE 0
        END AS is_growth
    FROM with_lag
    WHERE calendar_year BETWEEN 1998 AND 2001
),
summary AS (
    SELECT
        prod_subcategory,
        COUNT(*) AS years_checked,
        SUM(is_growth) AS years_with_growth
    FROM growth_flags
    GROUP BY prod_subcategory
)
SELECT prod_subcategory
FROM summary
WHERE years_checked = 3 AND years_with_growth = 3
ORDER BY prod_subcategory;

Task 3
WITH filtered_sales AS (
    SELECT
        t.calendar_year,
        t.calendar_quarter_desc,
        p.prod_category,
        ch.channel_desc,
        ROUND(SUM(s.amount_sold), 2) AS sales
    FROM sh.sales s
    JOIN sh.times t ON s.time_id = t.time_id
    JOIN sh.products p ON s.prod_id = p.prod_id
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    WHERE t.calendar_year IN (1999, 2000)
      AND p.prod_category IN ('Electronics', 'Hardware', 'Software/Other')
      AND ch.channel_desc IN ('Partners', 'Internet')
    GROUP BY t.calendar_year, t.calendar_quarter_desc, p.prod_category, ch.channel_desc
),
with_first_quarter_sales AS (
    SELECT *,
        FIRST_VALUE(sales) OVER (
            PARTITION BY calendar_year, prod_category
            ORDER BY calendar_quarter_desc
        ) AS first_q_sales
    FROM filtered_sales
),
with_diff_and_cumsum AS (
    SELECT
        calendar_year,
        calendar_quarter_desc,
        prod_category,
        channel_desc,
        sales AS "SALES$",
        CASE 
            WHEN sales = first_q_sales THEN 'N/A'
            ELSE ROUND((sales - first_q_sales) * 100.0 / first_q_sales, 2) || '%'
        END AS "DIFF_PERCENT",
        ROUND(SUM(sales) OVER (
            PARTITION BY calendar_year, prod_category, channel_desc
            ORDER BY calendar_quarter_desc
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2) AS "CUM_SUM$"
    FROM with_first_quarter_sales
)
SELECT *
FROM with_diff_and_cumsum
ORDER BY calendar_year, calendar_quarter_desc, "SALES$" DESC;
