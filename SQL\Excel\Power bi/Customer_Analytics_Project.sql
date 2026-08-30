-- ==========================================
-- SECTION 1: DATABASE SETUP & INITIAL DATA CHECK
-- ==========================================
USE customer_analytics;
DESCRIBE customer_data;
SELECT COUNT(*) AS total_rows
FROM customer_data;
SELECT 
    data_quality_flag,
    COUNT(*) AS records
FROM customer_data
GROUP BY data_quality_flag;
SHOW COLUMNS FROM customer_data;
-- ==========================================
-- SECTION 2: DATA VALIDATION & QUALITY CHECKS
-- ==========================================
ALTER TABLE customer_data
RENAME COLUMN `ï»¿customer_id` TO customer_id;
DESCRIBE customer_data;
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_records
FROM customer_data;
SELECT COUNT(*) AS total_rows
FROM customer_data;
SELECT
    SUM(age < 18) AS invalid_age,
    SUM(total_orders < 0) AS invalid_orders,
    SUM(avg_order_value_clean < 0) AS invalid_order_value,
    SUM(email_open_rate_clean < 0) AS invalid_email_negative,
    SUM(email_open_rate_clean > 1) AS invalid_email_over_1,
    SUM(churn_risk < 0) AS invalid_churn_negative,
    SUM(churn_risk > 1) AS invalid_churn_over_1
FROM customer_data;
-- ==========================================
-- SECTION 3: DATA QUALITY CORRECTION
-- ==========================================
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_data
SET data_quality_flag =
    CASE
        WHEN age < 18
          OR total_orders < 0
          OR avg_order_value_clean < 0
          OR email_open_rate_clean < 0
          OR email_open_rate_clean > 100
          OR churn_risk < 0
          OR churn_risk > 1
        THEN 'Check Data'
        ELSE 'Valid'
    END;
    SET SQL_SAFE_UPDATES = 1;
    SELECT
    data_quality_flag,
    COUNT(*) AS records
FROM customer_data
GROUP BY data_quality_flag;
SELECT
    SUM(age < 18) AS invalid_age,
    SUM(total_orders < 0) AS invalid_orders,
    SUM(avg_order_value_clean < 0) AS invalid_order_value,
    SUM(email_open_rate_clean < 0) AS invalid_email_negative,
    SUM(email_open_rate_clean > 100) AS invalid_email_over_100,
    SUM(churn_risk < 0) AS invalid_churn_negative,
    SUM(churn_risk > 1) AS invalid_churn_over_1
FROM customer_data
WHERE data_quality_flag = 'Check Data';
SELECT
    MIN(email_open_rate_clean) AS min_email_open_rate,
    MAX(email_open_rate_clean) AS max_email_open_rate,
    COUNT(*) AS total_records
FROM customer_data;
SELECT
    customer_id,
    email_open_rate_clean,
    churn_risk
FROM customer_data
WHERE email_open_rate_clean > 100
ORDER BY email_open_rate_clean DESC
LIMIT 20;
-- ==========================================
-- SECTION 4: CLEAN ANALYSIS VIEW
-- ==========================================
CREATE OR REPLACE VIEW valid_customer_data AS
SELECT *
FROM customer_data
WHERE data_quality_flag = 'Valid';
-- ==========================================
-- SECTION 5: CUSTOMER & BUSINESS ANALYSIS
-- ==========================================
SELECT COUNT(*) AS valid_records
FROM valid_customer_data;
SELECT
    COUNT(DISTINCT customer_id) AS total_unique_customers,
    COUNT(*) AS total_records,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(SUM(estimated_customer_value), 2) AS total_estimated_value,
    ROUND(AVG(loyalty_score), 2) AS avg_loyalty_score,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk
FROM valid_customer_data;
SELECT
    country,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_records,
    ROUND(SUM(estimated_customer_value), 2) AS total_estimated_value,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk
FROM valid_customer_data
GROUP BY country
ORDER BY total_estimated_value DESC;
SELECT
    preferred_category,
    COUNT(*) AS total_records,
    ROUND(SUM(estimated_customer_value), 2) AS total_estimated_value,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk
FROM valid_customer_data
GROUP BY preferred_category
ORDER BY total_estimated_value DESC;
SELECT
    customer_value_segment,
    COUNT(*) AS total_records,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(SUM(estimated_customer_value), 2) AS total_estimated_value
FROM valid_customer_data
GROUP BY customer_value_segment
ORDER BY total_estimated_value DESC;
-- ==========================================
-- SECTION 6: CHURN & RETENTION ANALYSIS
-- ==========================================
SELECT
    customer_priority,
    COUNT(*) AS total_records,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk
FROM valid_customer_data
GROUP BY customer_priority
ORDER BY total_records DESC;
SELECT
    customer_id,
    country,
    preferred_category,
    estimated_customer_value,
    churn_risk,
    loyalty_score,
    recency_segment
FROM valid_customer_data
WHERE customer_priority = 'Critical - Retain'
ORDER BY estimated_customer_value DESC;
SELECT
    recency_segment,
    COUNT(*) AS total_records,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value
FROM valid_customer_data
GROUP BY recency_segment
ORDER BY avg_churn_risk DESC;
SELECT
    loyalty_segment,
    COUNT(*) AS total_records,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value
FROM valid_customer_data
GROUP BY loyalty_segment
ORDER BY avg_churn_risk DESC;
SELECT
    CASE
        WHEN email_open_rate_clean < 30 THEN 'Low Engagement'
        WHEN email_open_rate_clean < 70 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END AS email_engagement,
    COUNT(*) AS total_records,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value
FROM valid_customer_data
GROUP BY email_engagement
ORDER BY avg_churn_risk DESC;
-- ==========================================
-- SECTION 7: FRAUD & RISK ANALYSIS
-- ==========================================
SELECT
    fraud_status,
    COUNT(*) AS total_records,
    ROUND(AVG(avg_order_value_clean), 2) AS avg_order_value,
    ROUND(AVG(estimated_customer_value), 2) AS avg_customer_value,
    ROUND(AVG(churn_risk), 3) AS avg_churn_risk
FROM valid_customer_data
GROUP BY fraud_status
ORDER BY total_records DESC;
SELECT
    country,
    COUNT(*) AS total_records,
    SUM(CASE WHEN is_fraudulent = 1 THEN 1 ELSE 0 END) AS fraudulent_records,
    ROUND(
        100.0 * SUM(CASE WHEN is_fraudulent = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fraud_rate_percent
FROM valid_customer_data
GROUP BY country
ORDER BY fraud_rate_percent DESC;
SELECT
    preferred_category,
    COUNT(*) AS total_records,
    SUM(CASE WHEN is_fraudulent = 1 THEN 1 ELSE 0 END) AS fraudulent_records,
    ROUND(
        100.0 * SUM(CASE WHEN is_fraudulent = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fraud_rate_percent
FROM valid_customer_data
GROUP BY preferred_category
ORDER BY fraud_rate_percent DESC;
-- ==========================================
-- SECTION 8: ADVANCED SQL ANALYSIS
-- CTEs | Window Functions | Subqueries
-- ==========================================
WITH ranked_customers AS (
    SELECT
        customer_id,
        country,
        estimated_customer_value,
        churn_risk,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY estimated_customer_value DESC
        ) AS customer_rank
    FROM valid_customer_data
)
SELECT
    customer_id,
    country,
    estimated_customer_value,
    churn_risk,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 5
ORDER BY country, customer_rank;
WITH country_summary AS (
    SELECT
        country,
        SUM(estimated_customer_value) AS total_estimated_value,
        AVG(churn_risk) AS avg_churn_risk
    FROM valid_customer_data
    GROUP BY country
)
SELECT
    country,
    ROUND(total_estimated_value, 2) AS total_estimated_value,
    ROUND(avg_churn_risk, 3) AS avg_churn_risk,
    RANK() OVER (ORDER BY total_estimated_value DESC) AS value_rank
FROM country_summary
ORDER BY value_rank;
SELECT
    customer_id,
    country,
    estimated_customer_value,
    churn_risk,
    loyalty_score,
    customer_priority
FROM valid_customer_data
WHERE estimated_customer_value >
      (SELECT AVG(estimated_customer_value)
       FROM valid_customer_data)
  AND churn_risk >
      (SELECT AVG(churn_risk)
       FROM valid_customer_data)
ORDER BY estimated_customer_value DESC;
WITH customer_summary AS (
    SELECT
        customer_id,
        MAX(country) AS country,
        SUM(estimated_customer_value) AS total_customer_value,
        AVG(churn_risk) AS avg_churn_risk,
        AVG(loyalty_score) AS avg_loyalty_score,
        COUNT(*) AS number_of_records
    FROM valid_customer_data
    GROUP BY customer_id
)
SELECT
    customer_id,
    country,
    ROUND(total_customer_value, 2) AS total_customer_value,
    ROUND(avg_churn_risk, 3) AS avg_churn_risk,
    ROUND(avg_loyalty_score, 2) AS avg_loyalty_score,
    number_of_records
FROM customer_summary
ORDER BY total_customer_value DESC
LIMIT 20;