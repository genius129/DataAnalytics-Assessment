/* This query determines the High-Value Customers with Multiple Products.
It basically retrieves customer with at least one funded savings plan and one funded investment plan. */

SELECT
    u.id AS Owner_id,  -- Customer's ID
    CONCAT(u.first_name, ' ', u.last_name) AS Name,  -- Joins the first and last name to give Customer's full name

    savings_info.savings_count,
    investment_info.investment_count,

    ROUND((savings_info.total_savings + investment_info.total_investments) / 100, 2) AS Total_deposits  -- Total in Naira

FROM users_customuser u

-- Subquery: Use to retrieve funded savings plans
JOIN (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS savings_count,  -- Count unique savings plans
        SUM(s.confirmed_amount) AS total_savings     -- Sum of confirmed inflows
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1          -- Only regular savings
        AND s.confirmed_amount > 0        -- Funded savings only
    GROUP BY s.owner_id
) AS savings_info ON u.id = savings_info.owner_id

-- Subquery: Use to retrieve funded investment plans (based on inflow via savings_savingsaccount)
JOIN (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS investment_count,   -- Number of investment plans
        SUM(s.confirmed_amount) AS total_investments     -- Inflows into investment-type plans
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE 
        p.is_a_fund = 1               -- Only investment plans
        AND s.confirmed_amount > 0    -- Funded only
    GROUP BY s.owner_id
) AS investment_info ON u.id = investment_info.owner_id

-- Final sorting
ORDER BY total_deposits DESC;
