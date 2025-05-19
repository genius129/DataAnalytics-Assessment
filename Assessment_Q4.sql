/* This query estimates the Customer Lifetime Value (CLV)
It calculates and retieves the Account tenure, total transcations and estimated CLV 
CLV = (total_tansanctions/tenure)* 12 * Avg_profit_per_transaction) */

SELECT 
    u.id AS customer_id,  -- Customer's unique ID from the users table

    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Joins the first and last to retrieve full name of the customer

    -- Calculate how long the customer has had an account (in months)
    PERIOD_DIFF(
        DATE_FORMAT(CURDATE(), '%Y%m'),         -- Current year and month
        DATE_FORMAT(u.date_joined, '%Y%m')      -- Join year and month
    ) AS account_tenure_months,

    -- Calculate total confirmed inflow transactions, converting from kobo to naira
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_transaction_value_naira,

    -- Estimate CLV based on formula: (total_txns / tenure) * 12 * profit_rate
    ROUND(
        (
            (SUM(s.confirmed_amount) / 100) /   -- Total inflow in naira
            NULLIF(
                PERIOD_DIFF(
                    DATE_FORMAT(CURDATE(), '%Y%m'),
                    DATE_FORMAT(u.date_joined, '%Y%m')
                ),
                0                               -- Prevent divide-by-zero for current-month signups
            )
        ) * 12 * 0.001,                         -- Calculate the annual value and multiplies by profit margin (0.1%)
        2
    ) AS estimated_clv

FROM users_customuser u

-- Join savings account table using foreign key relationship
JOIN savings_savingsaccount s 
  ON u.id = s.owner_id

-- Filter to only include transactions with confirmed inflows
WHERE s.confirmed_amount > 0

-- Group by user fields to aggregate data correctly
GROUP BY u.id, u.first_name, u.last_name, u.date_joined

-- Sort results by CLV in descending order (highest value customers first)
ORDER BY estimated_clv DESC;
