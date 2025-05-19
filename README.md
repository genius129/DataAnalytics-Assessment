# Data Analytics SQL Assessment
## Per-Question Explanation
# 1. High-Value Customers with Multiple Products 

##  Overview
This project involves identifying **high-value customers** who are engaged with **multiple financial products**, specifically those who have **at least one funded savings plan** and **one funded investment plan**. The SQL query achieves this by joining relevant tables and aggregating financial data to rank customers based on total confirmed deposits.

**Business Question:**  
> *Which customers have both a funded savings plan and a funded investment plan, and how much have they deposited in total?*

##  Challenges & Resolutions

### 1. **Identifying Funded Plans Only**
- **Challenge:** Ensuring only active, funded plans were considered — not empty or inactive accounts.
- **Resolution:** Used `s.confirmed_amount > 0` to filter out unfunded plans in both subqueries.

### 2. **Accurate Aggregation**
- **Challenge:** Avoiding double-counting where a user might have multiple transactions or plan entries.
- **Resolution:** Applied `COUNT(DISTINCT s.plan_id)` to count unique plans per customer.

### 3. **Product Differentiation**
- **Challenge:** Distinguishing between savings and investment plans, especially when both reside in the same savings table.
- **Resolution:** Used the `plans_plan` table’s boolean flags:  
  - `p.is_regular_savings = 1` for savings  
  - `p.is_a_fund = 1` for investments

### 4. **Currency Normalization**
- **Challenge:** Amounts stored in Kobo (smallest unit), but analysis required values in Naira.
- **Resolution:** Applied `ROUND((amount) / 100, 2)` to convert and round for readability.

## Conclusion

This query is a practical step towards advanced customer segmentation, enabling the business to:
- Target high-value clients for loyalty programs or premium services.
- Monitor cross-product engagement trends.
- Identify upselling opportunities for mono-product customers.



# 2. Transaction Frequency Analysis
##  Overview

This query performs a **transaction frequency analysis** on customers by calculating their **average monthly transactions** and categorizing them into **High**, **Medium**, or **Low Frequency** groups. It summarizes the number of customers in each group and their average monthly transaction count.

**Business Question:**  
> *How frequently do customers transact on their regular savings accounts, and how can they be categorized based on this behavior?*

## Challenges & Resolutions

### 1. **Avoiding Divide-by-Zero**
- **Challenge:** When a customer transacts within a single month, `PERIOD_DIFF` is zero.
- **Resolution:** Wrapped in `GREATEST(..., 1)` to ensure divisor is never less than 1.

### 2. **Ordering Categories**
- **Challenge:** SQL orders string categories alphabetically by default.
- **Resolution:** Used a `CASE` expression in `ORDER BY` to customize category ordering.

## Conclusion
This analysis allows the organization to:
- Track engagement levels.
- Tailor communication strategies per customer group.
- Design loyalty or incentive programs for less active users.



# 3. Account Inactivity Alert

## 📌 Overview

This query identifies **inactive savings and investment accounts** that have had **no financial activity in over one year**. It helps in triggering alerts, prompting re-engagement, or flagging dormant accounts for internal audits.

**Business Question:**  
> *Which accounts (either savings or investments) have not had any transactions or charges in the past 12 months?*

## Challenges & Resolutions

### 1. **Different Date Sources**
- **Challenge:** Savings and investment plans record their last activity in different columns.
- **Resolution:** Used `transaction_date` for savings and `last_charge_date` for investments.

### 2. **Ensuring Meaningful Inactivity**
- **Challenge:** Only include accounts with actual funding or charge history.
- **Resolution:** Added conditions:
- `confirmed_amount > 0` for savings.
- `last_charge_date IS NOT NULL` for investments.

## Conclusion

This query facilitates:
- Early detection of dormant accounts.
- Timely customer nudges to maintain activity.
- Better understanding of product usage lifecycle.



# 4. Customer Lifetime Value (CLV) - SQL Query Documentation

##  Overview

This query estimates the **Customer Lifetime Value (CLV)** for users based on their **account tenure**, **total transaction value**, and a defined **profit margin per transaction**. CLV is a crucial metric for understanding long-term customer profitability.

**Business Question:**  
> *Which customers provide the most long-term value, and how much are they potentially worth over time?*

## Challenges & Resolutions

### 1. **Preventing Division by Zero**
- **Challenge:** New users with 0 tenure months.
- **Resolution:** Used `NULLIF(tenure, 0)` to safely avoid errors.

### 2. **Profit Margin Assumption**
- **Challenge:** Need a proxy for average transaction profitability.
- **Resolution:** Used `0.1%` (0.001) as a placeholder. This can be adjusted as needed for real financials.

### 3. **Data Consistency**
- **Challenge:** Ensuring only valid inflow transactions are included.
- **Resolution:** Filtered by `s.confirmed_amount > 0`.

## Conclusion

By calculating CLV:
- Teams can identify and prioritize high-value customers.
- Marketing strategies can be tailored to different lifecycle stages.
- It empowers the business with actionable customer profitability metrics.