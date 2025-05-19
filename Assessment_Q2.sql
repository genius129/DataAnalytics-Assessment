/* This query checks and retrieves the transaction frequency analysis
It categorizes customers based on their transaction frequency and retrieves the average monthly transanction for each category. */

SELECT
    frequency_category,                                -- Frequency category
    COUNT(*) AS customer_count,                        -- Counts the number of customers in this frequency group
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month  -- Calculates the average monthly transaction in each group
FROM (
    SELECT 
        u.id AS customer_id,                           -- Customer ID

        -- Calculate monthly average inflow transactions
        COUNT(s.id) / GREATEST(
            PERIOD_DIFF(
                DATE_FORMAT(MAX(s.transaction_date), '%Y%m'),  -- Latest transaction month
                DATE_FORMAT(MIN(s.transaction_date), '%Y%m')   -- Earliest transaction month
            ) + 1,
            1                                            -- Prevent divide-by-zero
        ) AS avg_txn_per_month,

        -- Categorize based on average transaction frequency
        CASE
            WHEN COUNT(s.id) / GREATEST(PERIOD_DIFF(DATE_FORMAT(MAX(s.transaction_date), '%Y%m'), DATE_FORMAT(MIN(s.transaction_date), '%Y%m')) + 1, 1) >= 10 
                THEN 'High Frequency'
            WHEN COUNT(s.id) / GREATEST(PERIOD_DIFF(DATE_FORMAT(MAX(s.transaction_date), '%Y%m'), DATE_FORMAT(MIN(s.transaction_date), '%Y%m')) + 1, 1) BETWEEN 3 AND 9 
                THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category

    FROM users_customuser u
    JOIN savings_savingsaccount s 
        ON u.id = s.owner_id                            -- Link user to savings account
    JOIN plans_plan p 
        ON s.plan_id = p.id                             -- Link savings to its plan
    WHERE 
        p.is_regular_savings = 1                        -- Only regular savings plans
        AND s.confirmed_amount > 0                      -- Only actual inflow transactions
    GROUP BY u.id                                       -- One row per user
) AS txn_summary
GROUP BY frequency_category
ORDER BY 
  CASE frequency_category                               -- Preserve order of frequency
    WHEN 'High Frequency' THEN 1
    WHEN 'Medium Frequency' THEN 2
    WHEN 'Low Frequency' THEN 3
  END;


