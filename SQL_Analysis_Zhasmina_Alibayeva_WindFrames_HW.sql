Task 1
WITH enriched_sales AS (
    SELECT
        c.country_region,
        t.calendar_year,
        ch.channel_desc,
        s.amount_sold
    FROM sh.sales s
    JOIN sh.times t ON s.time_id = t.time_id
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries c ON cu.country_id = c.country_id
    WHERE t.calendar_year BETWEEN 1999 AND 2001
      AND c.country_region IN ('Americas', 'Asia', 'Europe')
),
total_sales AS (
    SELECT
        country_region,
        calendar_year,
        channel_desc,
        SUM(amount_sold) AS amount_sold
    FROM enriched_sales
    GROUP BY country_region, calendar_year, channel_desc
),
channel_totals AS (
    SELECT
        country_region,
        calendar_year,
        SUM(amount_sold) AS total_region_sales
    FROM total_sales
    GROUP BY country_region, calendar_year
),
with_percentages AS (
    SELECT
        t.country_region,
        t.calendar_year,
        t.channel_desc,
        t.amount_sold,
        ROUND(t.amount_sold * 100.0 / c.total_region_sales, 2) AS pct_by_channels
    FROM total_sales t
    JOIN channel_totals c
      ON t.country_region = c.country_region
     AND t.calendar_year = c.calendar_year
),
with_previous AS (
    SELECT
        wp.*,
        LAG(pct_by_channels) OVER (
            PARTITION BY country_region, channel_desc
            ORDER BY calendar_year
        ) AS pct_previous_period
    FROM with_percentages wp
),
final_report AS (
    SELECT
        country_region,
        calendar_year,
        channel_desc,
        amount_sold,
        pct_by_channels AS "% BY CHANNELS",
        pct_previous_period AS "% PREVIOUS PERIOD",
        ROUND(pct_by_channels - pct_previous_period, 2) AS "% DIFF"
    FROM with_previous
)
SELECT *
FROM final_report
ORDER BY country_region, calendar_year, channel_desc;

Task 2

WITH sales_with_time AS (
    SELECT
        s.amount_sold,
        t.time_id,
        t.day_name,
        t.calendar_week_number,
        t.calendar_year
    FROM sh.sales s
    JOIN sh.times t ON s.time_id = t.time_id
    WHERE t.calendar_year = 1999
      AND t.calendar_week_number IN (49, 50, 51)
),
aggregated_by_day AS (
    SELECT
        time_id,
        day_name,
        calendar_week_number,
        calendar_year,
        SUM(amount_sold) AS daily_sales
    FROM sales_with_time
    GROUP BY time_id, day_name, calendar_week_number, calendar_year
),
cumulative_sales AS (
    SELECT *,
        SUM(daily_sales) OVER (ORDER BY time_id) AS cum_sum
    FROM aggregated_by_day
),
centered_avg AS (
    SELECT
        a1.*,
        CASE 
            WHEN day_name = 'Monday' THEN (
                SELECT ROUND(AVG(daily_sales), 2)
                FROM aggregated_by_day a2
                WHERE a2.time_id BETWEEN a1.time_id - INTERVAL '2 days' AND a1.time_id + INTERVAL '1 day'
                  AND EXTRACT(DOW FROM a2.time_id) IN (0, 6, 1, 2)  -- Sun(0), Sat(6), Mon(1), Tue(2)
            )
            WHEN day_name = 'Friday' THEN (
                SELECT ROUND(AVG(daily_sales), 2)
                FROM aggregated_by_day a2
                WHERE a2.time_id BETWEEN a1.time_id - INTERVAL '1 day' AND a1.time_id + INTERVAL '2 days'
                  AND EXTRACT(DOW FROM a2.time_id) IN (4, 5, 6, 0)  -- Thu(4), Fri(5), Sat(6), Sun(0)
            )
            ELSE (
                SELECT ROUND(AVG(daily_sales), 2)
                FROM aggregated_by_day a2
                WHERE a2.time_id BETWEEN a1.time_id - INTERVAL '1 day' AND a1.time_id + INTERVAL '1 day'
            )
        END AS centered_3_day_avg
    FROM cumulative_sales a1
)
SELECT 
    time_id,
    calendar_week_number,
    calendar_year,
    day_name,
    daily_sales,
    cum_sum AS CUM_SUM,
    centered_3_day_avg AS CENTERED_3_DAY_AVG
FROM centered_avg
ORDER BY time_id;
