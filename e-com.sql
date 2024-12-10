use `e-com`;

-- Basic User and Session Insights
-- Total number of sessions and unique users:
create view num_sec_session as
select count(distinct session_id) as total_session, 
count(distinct user_id) as total_user
from eweb;

-- Average session duration:
create view avg_session as
select avg(session_duration) as avg_session_duration
from eweb;

-- Distribution of sessions by device type or traffic source:
create view dist_by_device_type as
select device_type, count(*) as total_sessions
from eweb
group by device_type;

create view dist_by_traffic_source as
select traffic_source, count(*) as total_sessions
from eweb
group by traffic_source;

-- Engagement Metrics:
-- Average number of page views and product views per session
create view page_and_product_view_per_session as
select 
avg(page_views) as avg_page_view,
avg(product_views) as avg_product_view
from eweb;

-- Percentage of sessions with cart additions, checkout initiations, and purchases:
create view percentage_cart_checkout_purchase as
select
round(100 * sum(case when cart_additions > 0 then 1 else 0 end) / count(*),2) per_cart_additions,
round(100 * sum(case when checkout_initiated > 0 then 1 else 0 end) / count(*),2) per_check_initiations,
round(100 * sum(case when purchase_completed > 0 then 1 else 0 end) / count(*),2) per_purchase_completed
from eweb;

-- Conversion Funnel Analysis
-- Conversion rates at each stage:
create view rate_at_each_stage as
select
round(100 * sum(case when cart_additions > 0 then 1 else 0 end) / count(*), 2) as cart_addition_rate,
ROUND(100.0 * SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END), 2) AS checkout_rate,
ROUND(100.0 * SUM(CASE WHEN purchase_completed > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END), 2) AS purchase_rate
FROM eweb;

-- Funnel performance by traffic source:
create view performance_by_traffic as
SELECT 
    traffic_source, 
    ROUND(100.0 * SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS cart_addition_rate,
    ROUND(100.0 * SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END), 2) AS checkout_rate,
    ROUND(100.0 * SUM(CASE WHEN purchase_completed > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END), 2) AS purchase_rate
FROM eweb 
GROUP BY traffic_source;

-- Funnel performance by device type:
create view performance_by_device as
SELECT 
    device_type, 
    ROUND(100.0 * SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS cart_addition_rate,
    ROUND(100.0 * SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END), 2) AS checkout_rate,
    ROUND(100.0 * SUM(CASE WHEN purchase_completed > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN checkout_initiated > 0 THEN 1 ELSE 0 END), 2) AS purchase_rate
FROM eweb 
GROUP BY device_type;



-- Session trends by day, week, or month:
create view session_trend_by_date as
select 
date(session_start_time) as session_date,
count(*) total_sessions
from eweb
group by date(session_start_time)
order by session_date;

create view session_trend_by_year_month as
select 
extract(year from session_start_time) as year,
extract(month from session_start_time) as month,
count(*) total_sessions
from eweb
group by year, month
order by year, month;

-- Peak times of the day for session start:
create view session_start_by_day_hour as
select 
extract(day from session_start_time) as session_day,
extract(hour from session_start_time) as session_hour,
count(*) total_sessions
from eweb
group by session_day, session_hour
order by session_day, session_hour;

-- User-Level Metrics
-- Number of sessions per user:
create view num_session_per_user as
select user_id,
count(*) session_count
from eweb
where user_id is not null
group by user_id
order by user_id;

-- Average session duration per user:
create view avg_session_per_user as
select user_id,
avg(session_duration) avg_session
from eweb
where user_id is not null
group by user_id
order by user_id;

-- Behavior Analysis
-- Correlation between page views and product views, and purchases:
create view cor_btw_page_product_view as
WITH averages AS (
    SELECT 
        AVG(page_views) AS avg_page_views, 
        AVG(product_views) AS avg_product_views
    FROM eweb
)
SELECT 
    SUM((page_views - avg_page_views) * (product_views - avg_product_views)) /
    SQRT(
        SUM(POWER(page_views - avg_page_views, 2)) * 
        SUM(POWER(product_views - avg_product_views, 2))
    ) AS correlation_coefficient
FROM eweb, averages;

-- Correlation between product views and purchases:
create view cor_btw_product_purchase as
WITH averages AS (
    SELECT 
        AVG(product_views) AS avg_product_views, 
        AVG(purchase_completed) AS avg_purchase_completed
    FROM eweb
)
SELECT 
    SUM((product_views - avg_product_views) * (purchase_completed - avg_purchase_completed)) /
    SQRT(
        SUM(POWER(product_views - avg_product_views, 2)) * 
        SUM(POWER(purchase_completed - avg_purchase_completed, 2))
    ) AS correlation_coefficient
FROM eweb, averages;

-- Traffic Source Effectiveness
-- Compare conversion rates across traffic sources:
create view conversion_rate_across_traffic as
SELECT 
    traffic_source, 
    ROUND(100.0 * SUM(purchase_completed) / COUNT(*), 2) AS conversion_rate 
FROM eweb 
GROUP BY traffic_source;


-- Analyze session duration and engagement by traffic source:
create view session_duration_engagement_by_traffic as
SELECT 
    traffic_source, 
    AVG(session_duration) AS avg_session_duration, 
    AVG(page_views) AS avg_page_views 
FROM eweb 
GROUP BY traffic_source;



-- Compare sessions with and without user IDs:
create view session_with_without_user as
SELECT 
    CASE 
        WHEN user_id IS NULL THEN 'No User ID'
        ELSE 'Has User ID'
    END AS user_id_status, 
    AVG(session_duration) AS avg_session_duration, 
    AVG(page_views) AS avg_page_views 
FROM eweb
GROUP BY user_id_status;


-- Advanced Segmentation
-- Segment sessions based on conversion outcomes:
create view session_based_conversion_outcome as
SELECT 
    CASE 
        WHEN purchase_completed > 0 THEN 'Purchased'
        WHEN checkout_initiated > 0 THEN 'Checkout Initiated'
        WHEN cart_additions > 0 THEN 'Cart Added'
        ELSE 'Browsed Only'
    END AS segment, 
    COUNT(*) AS session_count 
FROM eweb
GROUP BY segment 
ORDER BY session_count DESC;


-- Identify high-value sessions:
create view high_value_session as
SELECT 
    session_id, 
    page_views, 
    product_views, 
    purchase_completed 
FROM eweb
WHERE page_views > 15 AND purchase_completed = 1 
ORDER BY page_views ;