-- South Carolina Sales (Online & in-store)
USE sample_sales;

-- Q1: What is total revenue overall for sales in the assigned territory,
-- plus the start date and period the data covers?
-- ONLINE
SELECT SUM(SalesTotal) AS TotalRevenue,
MIN(Date) AS FirstSale,
MAX(Date) AS LastSale
FROM online_sales
WHERE ShiptoState = 'South Carolina';
-- Total online revenue for south carolina is $719,988.75
-- Covering 2022-01-03 through 2025-12-31
-- IN-STORE
SELECT SUM(ss.Sale_Amount) AS TotalRevenue,
       MIN(ss.Transaction_Date) AS FirstSale,
       MAX(ss.Transaction_Date) AS LastSale
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina';
-- Total in-store revenue for south carolina is $648,812.56
-- Covering 2022-01-01 through 2025-12-30
-- Combined with online, total SC revenue is $1,368,801.31

-- Q2: What is the revenue breakdown by year and month for the sales territory?
-- ONLINE
SELECT YEAR(Date) AS Year,
Month(Date) AS Month,
SUM(SalesTotal) AS Revenue
FROM online_sales
WHERE ShiptoState = 'South Carolina'
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;
-- The data shows only 43 of the 48 months have any online sales at all and revenue is very
-- uneven. There is really only top 5 strong months (2022-04, 2025-01, 2025-04, 2024-01, 2023-12)
-- make up about 79% of all online revenue for SC. Plenty of other months are under $1,000. 
-- This shows things are not too steady.
-- IN-STORE
SELECT YEAR(ss.Transaction_Date) AS Year,
MONTH(ss.Transaction_Date) AS Month,
SUM(ss.Sale_Amount) AS Revenue
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY YEAR(ss.Transaction_Date), MONTH(ss.Transaction_Date)
ORDER BY Year, Month;
--  Unlike Online, In-store has sales in all 48 months, being between about $5K and $35K.
-- There is clear growth over time - 2022 months average around $9K and
-- 2025 months average closer to $22K, with August 2025 the highest at
-- $34,374.68. Unlike online, there are no gaps and no extreme spikes.

-- Q3: Provide a comparison of total revenue for the specific sales territory and the region it belongs to
-- ONLINE
SELECT os.ShiptoState AS State,
SUM(os.SalesTotal) AS Revenue
FROM online_sales os
JOIN management m ON os.ShiptoState = m.State
WHERE m.Region = 'South'
GROUP BY os.ShiptoState
ORDER BY Revenue DESC;
-- SC is the smallest online territory in the South region at $719,988.75
-- IN-STORE
SELECT sl.State,
SUM(ss.Sale_Amount) AS Revenue
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
JOIN management m ON sl.State = m.State
WHERE m.Region = 'South'
GROUP BY sl.State
ORDER BY Revenue DESC;
-- SC is the smallest in-store territory in the South region at $648,812.56
-- SC is a small territory overall compared to FL and TX

-- Q4: What is the number of transactions per month and average transaction amount by product
-- category for the sales territory?
-- ONLINE
SELECT YEAR(Date) AS Year,
MONTH(Date) AS Month,
COUNT(*) AS Transactions
FROM online_sales
WHERE ShiptoState = 'South Carolina'
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;
-- Online transaction counts are usually between 2 and 20 a month, with a few
-- huge months: 2022-04 (255), 2025-04 (269), 2025-01 (206), 2024-01 (77),
-- 2023-12 (74). An observation shows revenue months are driven by volume, not by a few large orders.
-- IN-STORE
SELECT YEAR(ss.Transaction_Date) AS Year,
MONTH(ss.Transaction_Date) AS Month,
COUNT(*) AS Transactions
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY YEAR(ss.Transaction_Date), MONTH(ss.Transaction_Date)
ORDER BY Year, Month;
-- In-store transaction counts are steady and growing. 2022 runs 48-68 a
-- month, 2023 and 2024 both run about 70-97, and 2025 jumps to 107-209 with
-- October 2025 the busiest at 209. No empty months and no spikes unlike online sales
-- ONLINE
SELECT ic.Category,
COUNT(*) AS Transactions,
ROUND(AVG(os.SalesTotal), 2) AS AvgTransaction
FROM online_sales os
JOIN products p ON os.ProdNum = p.ProdNum
JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
WHERE os.ShiptoState = 'South Carolina'
GROUP BY ic.Category
ORDER BY AvgTransaction DESC;
--							 Trans    AvgTrans
-- Technology & Accessories    252    2036.15
-- Textbooks                   126     751.97
-- Books (General)             294     172.10
-- Apparel and Merchandise     170     159.15
-- Art Supplies                153     132.84
-- Stationery and Supplies     236      59.97
-- IN-STORE
SELECT ic.Category,
COUNT(*) AS Transactions,
ROUND(AVG(ss.Sale_Amount), 2) AS AvgTransaction
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
JOIN products p ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'South Carolina'
GROUP BY ic.Category
ORDER BY AvgTransaction DESC;
--							  Trans  AvgTrans
-- Technology & Accessories    977    483.23
-- Textbooks                   588    175.58
-- Apparel and Merchandise     907     33.53
-- Art Supplies                749     32.17
-- Books (General)             345     28.43
-- Stationery and Supplies     906     10.08

-- Q5: Can you provide a ranking of in-store sales performance by each store
-- in the sales territory, or a ranking of online sales performance by state within an online sales territory?
SELECT sl.StoreLocation,
COUNT(*) AS Transactions,
SUM(ss.Sale_Amount) AS Revenue
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY sl.StoreLocation
ORDER BY Revenue DESC;
-- Greenville ranks first with $337,002 while charleston is second $311,810

-- Q6: What is your recommendation for where to focus sales attention in the next quarter?
-- Focus Q1 on online sales, specifically Technology & Accessories.
-- January is already one of the two biggest online months( and the next quarter lands directly on it. April is the other
-- on one. April is the other one. Together those two months make more than 70% of all online revenue for SC, and the 
-- rest of the year is close to dead. July through November average under 30 transactions a month.
--
-- Technology & Accessories is where the money is. Online it averages
-- $2,036 per transaction, about four times the in-store average of $483,
-- and it makes up roughly 71% of online revenue on its own.
--
-- The tradeoff is that in-store is the safer channel. It has sales in all
-- 48 months,