/* This query determines Account Inactivity Alert.
It retrieves all active accounts (savings or investments) with no transactions in the last 1 year */

SELECT 
    inactive.plan_id,  -- Unique ID of the inactive plan (savings or investment)
    inactive.owner_id, -- Customer ID who owns the plan
    inactive.account_type AS type, -- Type of plan: 'Savings' or 'Investment'
    inactive.last_transaction_date, -- Date of last inflow or charge
    DATEDIFF(CURDATE(), inactive.last_transaction_date) AS inactivity_days -- Days since last activity
FROM (
    
    --  Subquery 1: Inactive Savings Accounts (no inflow in 365 days)
    SELECT 
        s.id AS plan_id,           -- Savings plan ID
        s.owner_id,                -- Owner of the savings plan
        'Savings' AS account_type, -- Label the plan as 'Savings'
        MAX(s.transaction_date) AS last_transaction_date -- Most recent inflow date
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1   -- Filter for savings-type plans only
        AND s.confirmed_amount > 0 -- Only consider funded transactions (inflows)
    GROUP BY s.id, s.owner_id
    HAVING 
        MAX(s.transaction_date) < DATE_SUB(CURDATE(), INTERVAL 365 DAY) -- Inactive over 1 year

    UNION

    --  Subquery 2: Inactive Investment Plans (no charges in 365 days)
    SELECT 
        p.id AS plan_id,           -- Investment plan ID
        p.owner_id,                -- Owner of the investment plan
        'Investment' AS account_type, -- Label the plan as 'Investment'
        MAX(p.last_charge_date) AS last_transaction_date -- Most recent charge date
    FROM plans_plan p
    WHERE 
        p.is_a_fund = 1               -- Filter for investment-type plans only
        AND p.last_charge_date IS NOT NULL -- Only consider plans with charge history
    GROUP BY p.id, p.owner_id
    HAVING 
        MAX(p.last_charge_date) < DATE_SUB(CURDATE(), INTERVAL 365 DAY) -- Inactive over 1 year

) AS inactive

--  Final Output: Sort by how long each account has been inactive
ORDER BY inactivity_days DESC;
