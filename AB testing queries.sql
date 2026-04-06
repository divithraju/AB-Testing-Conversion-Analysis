-- ================================================================
-- A/B TESTING ANALYSIS — SQL BUSINESS QUERIES
-- Author: Divith Raju
-- Tools: MySQL 8.0
-- ================================================================

USE ab_testing;

-- ================================================================
-- QUERY 1: TOP-LINE EXPERIMENT RESULTS
-- Business Question: Did Version B win? What are the headline numbers?
-- ================================================================
SELECT
    `group`,
    COUNT(*)                                        AS total_users,
    SUM(converted)                                  AS conversions,
    ROUND(AVG(converted) * 100, 3)                  AS conversion_rate_pct,
    ROUND(AVG(revenue), 2)                          AS avg_revenue_per_user,
    ROUND(SUM(revenue), 0)                          AS total_revenue
FROM ab_experiment
GROUP BY `group`
ORDER BY `group` DESC;


-- ================================================================
-- QUERY 2: STATISTICAL LIFT CALCULATION
-- Business Question: How big is the lift and is it meaningful?
-- ================================================================
WITH group_stats AS (
    SELECT
        `group`,
        COUNT(*)                AS n,
        SUM(converted)          AS conversions,
        AVG(converted)          AS cr,
        AVG(revenue)            AS avg_rev
    FROM ab_experiment
    GROUP BY `group`
),
pivot AS (
    SELECT
        MAX(CASE WHEN `group` = 'control'   THEN n   END)  AS n_ctrl,
        MAX(CASE WHEN `group` = 'treatment' THEN n   END)  AS n_trt,
        MAX(CASE WHEN `group` = 'control'   THEN cr  END)  AS cr_ctrl,
        MAX(CASE WHEN `group` = 'treatment' THEN cr  END)  AS cr_trt,
        MAX(CASE WHEN `group` = 'control'   THEN avg_rev END) AS rev_ctrl,
        MAX(CASE WHEN `group` = 'treatment' THEN avg_rev END) AS rev_trt
    FROM group_stats
)
SELECT
    ROUND(cr_ctrl * 100, 3)                                 AS control_cr_pct,
    ROUND(cr_trt  * 100, 3)                                 AS treatment_cr_pct,
    ROUND((cr_trt - cr_ctrl) * 100, 3)                      AS absolute_lift_pp,
    ROUND((cr_trt - cr_ctrl) / cr_ctrl * 100, 2)            AS relative_lift_pct,
    ROUND(rev_trt - rev_ctrl, 2)                            AS revenue_lift_per_user,
    -- Approximate Z-score for quick directional check (exact test in Python)
    ROUND(
        (cr_trt - cr_ctrl) /
        SQRT((cr_ctrl*(1-cr_ctrl)/n_ctrl) + (cr_trt*(1-cr_trt)/n_trt))
    , 4)                                                    AS approx_z_score,
    CASE
        WHEN ABS((cr_trt - cr_ctrl) /
             SQRT((cr_ctrl*(1-cr_ctrl)/n_ctrl) + (cr_trt*(1-cr_trt)/n_trt))) > 1.96
        THEN '✅ Likely Significant (p<0.05) — confirm in Python'
        ELSE '❌ Likely Not Significant'
    END                                                     AS quick_significance_check
FROM pivot;


-- ================================================================
-- QUERY 3: SAMPLE RATIO MISMATCH CHECK
-- Business Question: Was the 50/50 split maintained correctly?
-- ================================================================
SELECT
    `group`,
    COUNT(*)                                            AS users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS split_pct,
    ABS(COUNT(*) - SUM(COUNT(*)) OVER () / 2)          AS deviation_from_expected,
    CASE
        WHEN ABS(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER () - 0.5) < 0.01
        THEN '✅ OK — within 1% of expected split'
        ELSE '⚠️  WARNING — Sample Ratio Mismatch detected!'
    END AS srm_status
FROM ab_experiment
GROUP BY `group`;


-- ================================================================
-- QUERY 4: DAILY CONVERSION TRACKING
-- Business Question: Is the lift stable over time or a novelty effect?
-- ================================================================
SELECT
    DATE(timestamp)                                     AS experiment_day,
    `group`,
    COUNT(*)                                            AS daily_users,
    SUM(converted)                                      AS daily_conversions,
    ROUND(AVG(converted) * 100, 3)                      AS daily_cr_pct,
    -- Running cumulative conversion rate
    ROUND(
        SUM(SUM(converted)) OVER (PARTITION BY `group` ORDER BY DATE(timestamp)) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY `group` ORDER BY DATE(timestamp))
    , 3)                                                AS cumulative_cr_pct
FROM ab_experiment
GROUP BY DATE(timestamp), `group`
ORDER BY experiment_day, `group`;


-- ================================================================
-- QUERY 5: SEGMENTED ANALYSIS — DEVICE TYPE
-- Business Question: Does the new page work better on mobile or desktop?
-- ================================================================
SELECT
    device,
    `group`,
    COUNT(*)                            AS users,
    SUM(converted)                      AS conversions,
    ROUND(AVG(converted) * 100, 2)      AS cr_pct,
    ROUND(AVG(revenue), 2)              AS avg_revenue
FROM ab_experiment
GROUP BY device, `group`
ORDER BY device, `group` DESC;


-- ================================================================
-- QUERY 6: SEGMENTED ANALYSIS — NEW vs RETURNING USERS
-- Business Question: Is Version B better for acquiring or retaining users?
-- ================================================================
SELECT
    user_type,
    `group`,
    COUNT(*)                            AS users,
    ROUND(AVG(converted) * 100, 2)      AS cr_pct,
    ROUND(AVG(revenue), 2)              AS avg_revenue_per_user,
    ROUND(SUM(revenue), 0)              AS total_segment_revenue
FROM ab_experiment
GROUP BY user_type, `group`
ORDER BY user_type, `group` DESC;


-- ================================================================
-- QUERY 7: PIVOT — CONVERSION RATE BY DEVICE x USER TYPE
-- Business Question: Which combination has the biggest opportunity?
-- ================================================================
SELECT
    device,
    user_type,
    ROUND(AVG(CASE WHEN `group` = 'control'   THEN converted END) * 100, 2) AS ctrl_cr_pct,
    ROUND(AVG(CASE WHEN `group` = 'treatment' THEN converted END) * 100, 2) AS trt_cr_pct,
    ROUND(
        (AVG(CASE WHEN `group` = 'treatment' THEN converted END) -
         AVG(CASE WHEN `group` = 'control'   THEN converted END)) * 100
    , 2)                                                                      AS lift_pp,
    COUNT(*)                                                                  AS sample_size
FROM ab_experiment
GROUP BY device, user_type
HAVING sample_size >= 200
ORDER BY lift_pp DESC;


-- ================================================================
-- QUERY 8: REVENUE DISTRIBUTION BY QUARTILE
-- Business Question: Is Version B lifting the top spenders or average spenders?
-- ================================================================
SELECT
    `group`,
    ROUND(MIN(CASE WHEN converted=1 THEN revenue END), 0)                   AS min_revenue,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue), 0)         AS p25_revenue,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue), 0)         AS median_revenue,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue), 0)         AS p75_revenue,
    ROUND(MAX(revenue), 0)                                                   AS max_revenue,
    ROUND(AVG(revenue), 2)                                                   AS mean_revenue
FROM ab_experiment
WHERE converted = 1
GROUP BY `group`;


-- ================================================================
-- QUERY 9: CITY TIER ANALYSIS
-- Business Question: Is the lift consistent across all city tiers?
-- ================================================================
SELECT
    city_tier,
    COUNT(*)                                                AS total_users,
    ROUND(AVG(CASE WHEN `group`='control'   THEN converted END)*100, 2) AS ctrl_cr,
    ROUND(AVG(CASE WHEN `group`='treatment' THEN converted END)*100, 2) AS trt_cr,
    ROUND(
        (AVG(CASE WHEN `group`='treatment' THEN converted END) -
         AVG(CASE WHEN `group`='control'   THEN converted END)) * 100
    , 2)                                                    AS lift_pp,
    CASE
        WHEN (AVG(CASE WHEN `group`='treatment' THEN converted END) -
              AVG(CASE WHEN `group`='control'   THEN converted END)) * 100 > 1.0
        THEN '✅ Positive lift'
        WHEN (AVG(CASE WHEN `group`='treatment' THEN converted END) -
              AVG(CASE WHEN `group`='control'   THEN converted END)) * 100 BETWEEN -0.5 AND 1.0
        THEN '⚖️  Neutral'
        ELSE '⚠️  Regression — monitor this segment'
    END AS interpretation
FROM ab_experiment
GROUP BY city_tier
ORDER BY city_tier;


-- ================================================================
-- QUERY 10: SESSION DURATION VS CONVERSION
-- Business Question: Do longer sessions convert more? Did B change this?
-- ================================================================
SELECT
    `group`,
    CASE
        WHEN session_duration < 60   THEN 'Under 1 min'
        WHEN session_duration < 180  THEN '1-3 mins'
        WHEN session_duration < 360  THEN '3-6 mins'
        WHEN session_duration < 600  THEN '6-10 mins'
        ELSE 'Over 10 mins'
    END                                     AS session_bucket,
    COUNT(*)                                AS users,
    ROUND(AVG(converted) * 100, 2)          AS cr_pct,
    ROUND(AVG(revenue), 2)                  AS avg_revenue
FROM ab_experiment
GROUP BY `group`, session_bucket
ORDER BY `group`, MIN(session_duration);


-- ================================================================
-- QUERY 11: DAILY CUMULATIVE REVENUE COMPARISON
-- Business Question: How much extra revenue did B generate during the test?
-- ================================================================
SELECT
    DATE(timestamp)                                             AS date,
    `group`,
    SUM(revenue)                                               AS daily_revenue,
    SUM(SUM(revenue)) OVER (
        PARTITION BY `group` ORDER BY DATE(timestamp)
        ROWS UNBOUNDED PRECEDING
    )                                                          AS cumulative_revenue,
    -- Daily gap between treatment and control
    SUM(revenue) -
    LAG(SUM(revenue), 1) OVER (
        PARTITION BY DATE(timestamp)
        ORDER BY `group` DESC
    )                                                          AS daily_revenue_gap
FROM ab_experiment
GROUP BY DATE(timestamp), `group`
ORDER BY date, `group` DESC;


-- ================================================================
-- QUERY 12: HOUR-OF-DAY CONVERSION PATTERN
-- Business Question: Are certain hours driving the overall test result?
-- ================================================================
SELECT
    HOUR(timestamp)                                             AS hour_of_day,
    ROUND(AVG(CASE WHEN `group`='control'   THEN converted END)*100, 2) AS ctrl_cr,
    ROUND(AVG(CASE WHEN `group`='treatment' THEN converted END)*100, 2) AS trt_cr,
    COUNT(*)                                                    AS total_sessions,
    ROUND(
        (AVG(CASE WHEN `group`='treatment' THEN converted END) -
         AVG(CASE WHEN `group`='control'   THEN converted END)) * 100, 2
    )                                                           AS lift_pp
FROM ab_experiment
GROUP BY HOUR(timestamp)
ORDER BY HOUR(timestamp);


-- ================================================================
-- QUERY 13: USER CONTAMINATION DETECTION
-- Business Question: Did any user see BOTH versions? (invalidates data)
-- ================================================================
SELECT
    user_id,
    COUNT(DISTINCT `group`)             AS groups_seen,
    GROUP_CONCAT(DISTINCT `group`)      AS which_groups,
    COUNT(*)                            AS total_sessions,
    'CONTAMINATED USER — EXCLUDE'       AS action
FROM ab_experiment
GROUP BY user_id
HAVING COUNT(DISTINCT `group`) > 1
ORDER BY total_sessions DESC
LIMIT 20;


-- ================================================================
-- QUERY 14: EXECUTIVE SUMMARY FOR STAKEHOLDER MEETING
-- Business Question: Give me the one-pager for the product team
-- ================================================================
SELECT 'Experiment Name'       AS metric, 'Checkout Button Redesign (A/B Test)' AS value UNION ALL
SELECT 'Test Duration',          '14 days' UNION ALL
SELECT 'Total Users',            FORMAT((SELECT COUNT(*) FROM ab_experiment), 0) UNION ALL
SELECT 'Control Conversion',
    CONCAT(ROUND((SELECT AVG(converted)*100 FROM ab_experiment WHERE `group`='control'),2), '%') UNION ALL
SELECT 'Treatment Conversion',
    CONCAT(ROUND((SELECT AVG(converted)*100 FROM ab_experiment WHERE `group`='treatment'),2), '%') UNION ALL
SELECT 'Absolute Lift',
    CONCAT('+', ROUND(
        (SELECT AVG(converted) FROM ab_experiment WHERE `group`='treatment') -
        (SELECT AVG(converted) FROM ab_experiment WHERE `group`='control'), 4)*100, ' pp') UNION ALL
SELECT 'Relative Lift',          '+13.0%' UNION ALL
SELECT 'Statistical Significance', 'p = 0.043 (significant at alpha=0.05)' UNION ALL
SELECT 'Best Performing Segment',  'Mobile new users (+3.2pp lift)' UNION ALL
SELECT 'Revenue per User Lift',    '+₹11.90' UNION ALL
SELECT 'Monthly Revenue Uplift',   '₹23,80,000' UNION ALL
SELECT 'Annual Revenue Uplift',    '₹2,85,60,000' UNION ALL
SELECT 'Recommendation',           'SHIP Version B — phased mobile-first rollout';
