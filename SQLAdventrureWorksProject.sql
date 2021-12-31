-- Show sale data table & order by date

SELECT *
FROM AdventureWorks_Sales_2016, AdventureWorks_Sales_2017

-- Union Sales 2016 with Sales 2017

SELECT *
FROM AdventureWorks_Sales_2016
UNION
(
SELECT *
FROM AdventureWorks_Sales_2017
)
ORDER BY 1 DESC

-- Counting number of orders and sum of orders

SELECT sale.ProductKey, sale.TerritoryKey, SUM(OrderQuantity) AS Number_of_Orders
FROM
(
SELECT *
FROM AdventureWorks_Sales_2016
UNION
(
SELECT *
FROM AdventureWorks_Sales_2017
)
) AS sale
GROUP BY sale.ProductKey, sale.TerritoryKey

-- Counting number of orders and sum of orders return

SELECT sa.OrderDate, sa.StockDate, sa.OrderQuantity, sa.ProductKey, sa.TerritoryKey, re.ReturnQuantity, re.ReturnDate
FROM AdventureWorks_Sales_2016 sa
LEFT JOIN AdventureWorks_Returns re
	ON sa.ProductKey = re.ProductKey AND sa.TerritoryKey = re.TerritoryKey

-- Calculate return rate by productkey

WITH product_summary (ProductKey, TerritoryKey, Number_of_Orders, Number_of_Returns, Return_qty)
AS
(
	SELECT order_groupby.*,r.Number_of_Returns, CASE WHEN r.Number_of_Returns > 0 THEN r.Number_of_Returns ELSE 0 END AS return_qty -- Replace NULL values by 0
	FROM
		(
			SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS Number_of_Orders -- Get number of order by productkey
			FROM
				(
					SELECT *
					FROM AdventureWorks_Sales_2016
					UNION
					SELECT *
					FROM AdventureWorks_Sales_2017
				) AS sale
				GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
	LEFT JOIN
		(
			SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS Number_of_Returns -- Get number of return by productkey
			FROM AdventureWorks_Returns re
			GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
)
SELECT ps.ProductKey, ps.Number_of_Orders, ps.Return_qty, (Return_qty/Number_of_Orders)*100 AS Return_rate, -- Calculate return rate
		p.ProductSKU, p.ProductName, p.ModelName, p.ProductCost, p.ProductPrice
FROM product_summary ps
LEFT JOIN AdventureWorks_Products p
	ON ps.ProductKey = p.ProductKey
ORDER BY 4 DESC

--- Create temp table

CREATE TABLE #Summary_order_return_of_product
(
Product_key NUMERIC,
Terri_key NUMERIC,
Order_qty NUMERIC,
Return_number NUMERIC,
Return_qty NUMERIC
)

INSERT INTO #Summary_order_return_of_product
SELECT order_groupby.*,r.Number_of_Returns, CASE WHEN r.Number_of_Returns > 0 THEN r.Number_of_Returns ELSE 0 END AS return_qty -- Replace NULL values by 0
	FROM
		(
			SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS Number_of_Orders -- Get number of order by productkey
			FROM
				(
					SELECT *
					FROM AdventureWorks_Sales_2016
					UNION
					SELECT *
					FROM AdventureWorks_Sales_2017
				) AS sale
				GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
	LEFT JOIN
		(
			SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS Number_of_Returns -- Get number of return by productkey
			FROM AdventureWorks_Returns re
			GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
SELECT * FROM #Summary_order_return_of_product

-- Create view

CREATE VIEW product_summary
AS
WITH product_summary (ProductKey, TerritoryKey, Number_of_Orders, Number_of_Returns, Return_qty)
AS
(
	SELECT order_groupby.*,r.Number_of_Returns, CASE WHEN r.Number_of_Returns > 0 THEN r.Number_of_Returns ELSE 0 END AS return_qty -- Replace NULL values by 0
	FROM
		(
			SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS Number_of_Orders -- Get number of order by productkey
			FROM
				(
					SELECT *
					FROM AdventureWorks_Sales_2016
					UNION
					SELECT *
					FROM AdventureWorks_Sales_2017
				) AS sale
				GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
	LEFT JOIN
		(
			SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS Number_of_Returns -- Get number of return by productkey
			FROM AdventureWorks_Returns re
			GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
)
SELECT ps.ProductKey, ps.Number_of_Orders, ps.Return_qty, (Return_qty/Number_of_Orders)*100 AS Return_rate, -- Calculate return rate
		p.ProductSKU, p.ProductName, p.ModelName, p.ProductCost, p.ProductPrice
FROM product_summary ps
LEFT JOIN AdventureWorks_Products p
	ON ps.ProductKey = p.ProductKey
