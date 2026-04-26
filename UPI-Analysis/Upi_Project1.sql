CREATE DATABASE upi_analysis;
USE upi_analysis;

--Master Table
SELECT 
	m.month,
	ROUND(m.Volume_mn,2) AS total_volume,
	ROUND(m.Value_cr,2) AS total_value,
	ROUND(m.Banks_On_UPI,2) AS banks,
	ROUND(d.Avg_Daily_Value,2) AS avg_daily_value,
	ROUND(d.Avg_Daily_Volume,2) AS avg_daily_Volume
FROM upi_main m
JOIN upi_daily d ON m.Month = d.Month
ORDER BY m.ID

SELECT * FROM upi_main

--Total Transaction and per year
SELECT CASE
	WHEN RIGHT(month,2)= '20' THEN '2020'
	WHEN RIGHT(month,2)= '21' THEN '2021'
	WHEN RIGHT(month,2)= '22' THEN '2022'
	WHEN RIGHT(month,2)= '23' THEN '2023'
	WHEN RIGHT(month,2)= '24' THEN '2024'
	WHEN RIGHT(month,2)= '25' THEN '2025'
	WHEN RIGHT(month,2)= '26' THEN '2026'
END AS year,
ROUND(SUM(volume_mn),2) AS Total_transaction,
ROUND(SUM(Value_Cr),2) AS Total_monthly_value,
ROUND(AVG(Volume_mn),2) AS avg_monthly_transaction,
ROUND(AVG(Value_Cr),2) AS avg_monthly_value
FROM upi_main
GROUP BY RIGHT(month,2)
ORDER BY year

--Year on year percentage growth
WITH yearly AS (
SELECT CASE
	WHEN RIGHT(month,2)= '20' THEN '2020'
	WHEN RIGHT(month,2)= '21' THEN '2021'
	WHEN RIGHT(month,2)= '22' THEN '2022'
	WHEN RIGHT(month,2)= '23' THEN '2023'
	WHEN RIGHT(month,2)= '24' THEN '2024'
	WHEN RIGHT(month,2)= '25' THEN '2025'
	WHEN RIGHT(month,2)= '26' THEN '2026'
END AS year,
ROUND(SUM(volume_mn),2) AS Total_transaction
FROM upi_main
GROUP BY RIGHT(month,2)
)
SELECT 
year,
Total_transaction,
LAG(Total_transaction) OVER (ORDER BY year) AS prev_year,
ROUND((Total_transaction - LAG(Total_transaction) OVER (ORDER BY year)) / LAG(Total_transaction) OVER (ORDER BY year) *100 ,2) AS growth_pct
FROM yearly
ORDER BY year

--Best performing month each year
WITH monthly_rank AS(
SELECT
month,
ROUND(volume_mn, 2) AS volume_mn,
ROUND(value_cr, 2) AS value_cr,
 CASE
	WHEN RIGHT(month,2)= '20' THEN '2020'
	WHEN RIGHT(month,2)= '21' THEN '2021'
	WHEN RIGHT(month,2)= '22' THEN '2022'
	WHEN RIGHT(month,2)= '23' THEN '2023'
	WHEN RIGHT(month,2)= '24' THEN '2024'
	WHEN RIGHT(month,2)= '25' THEN '2025'
	WHEN RIGHT(month,2)= '26' THEN '2026'
END AS year,
RANK () OVER ( PARTITION BY RIGHT(month,2)
		       ORDER BY volume_mn DESC ) AS rnk
FROM upi_main
)
				
SELECT year, month, volume_mn ,value_cr
FROM monthly_rank 
WHERE rnk = 1
ORDER BY year;

--How many new banks joined UPI each year
SELECT 
 CASE
	WHEN RIGHT(month,2)= '20' THEN '2020'
	WHEN RIGHT(month,2)= '21' THEN '2021'
	WHEN RIGHT(month,2)= '22' THEN '2022'
	WHEN RIGHT(month,2)= '23' THEN '2023'
	WHEN RIGHT(month,2)= '24' THEN '2024'
	WHEN RIGHT(month,2)= '25' THEN '2025'
	WHEN RIGHT(month,2)= '26' THEN '2026'
END AS year,
MAX(banks_on_upi) - MIN(banks_on_upi) AS new_banks_joined
FROM upi_main
GROUP BY RIGHT(month,2)
ORDER BY year;

--Highest value month ever
SELECT TOP 1
month,
ROUND(Volume_Mn,2) AS Volume_Mn,
ROUND(Value_Cr,2) AS Value_Cr
FROM upi_main
ORDER BY Value_Cr DESC

--Pre covid vs post covid
SELECT 
 CASE
	WHEN RIGHT(month,2)= '20' THEN 'Covid period'
	ELSE 'Post Covid'
END AS period,
ROUND(AVG(Volume_mn),2) AS avg_monthly_volume,
ROUND(AVG(Value_Cr),2) AS avg_monthly_value
FROM upi_main
GROUP BY 
	CASE
		WHEN RIGHT(month,2)= '20' THEN 'Covid period'
		ELSE 'Post Covid'
	END;
--festive season analysis (is there any peak in oct/nov/dec)
SELECT 
	month,
	ROUND(Volume_mn,2) AS monthly_volume,
	ROUND(Value_Cr,2) AS monthly_value_cr,
	RANK() OVER (ORDER BY volume_mn DESC) AS rank_by_Volume
FROM upi_main
	WHERE Month LIKE 'Oct%'
	OR    Month LIKE 'Nov%'
	OR    Month LIKE 'Dec%' 
	ORDER BY rank_by_Volume

--Highest aveage Transaction size
SELECT TOP 5
	Month,
	ROUND (value_cr/Volume_Mn , 2) AS avg_transaction_size_cr
	FROM upi_main
ORDER BY avg_transaction_size_cr DESC

SELECT * FROM upi_daily

--Average daily transaction size 
SELECT
	month,
	ROUND((Avg_Daily_Value/Avg_Daily_Volume),2) AS avg_daily_transaction_cr
	FROM upi_daily
ORDER BY id
