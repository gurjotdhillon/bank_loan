ALTER Table loans
ALTER column issue_date type VARCHAR(50)

ALTER Table loans
ALTER column last_credit_pull_date type VARCHAR(50)

ALTER Table loans
ALTER column last_payment_date type VARCHAR(50)

ALTER Table loans
ALTER column next_payment_date type VARCHAR(50)


ALTER Table loans
ALTER column annual_income type float

SELECT pg_typeof(issue_date)
FROM loans
limit 1

set datestyle ='ISO,DMY'

ALTER Table loans
ALTER column issue_date type date USING issue_date::date


ALTER Table loans
ALTER column last_payment_date type date USING last_payment_date::date

ALTER Table loans
ALTER column last_credit_pull_date type date USING last_credit_pull_date::date

ALTER Table loans
ALTER column next_payment_date type date USING next_payment_date::date

SELECT *
FROM loans LIMIT 15

-- Data Analysis
-- EXPLORATORY ANALYSIS.
-- Total number of applications
SELECT COUNT(*) AS total_apps
FROM loans

-- There are 38,576 applications in the data set.
-- Column wise data
SELECT address_state
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) per_appications
FROM loans
GROUP BY 1
ORDER BY 2 DESC

-- CA has the highest number of applicants, 6894 about 17.9% and ME has the lowest number of applicants, only 3.

SELECT grade
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) per_appications
FROM loans
GROUP BY 1
ORDER BY 2 DESC

-- Grade B has the higest number of applicants, 11674 which is about 30% of total applicants and Grade G has the lowest, 313 about 0.8%

SELECT home_ownership
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) per_appications
FROM loans
GROUP BY 1
ORDER BY 2 DESC
-- Amongst the applicants, those who rent are the highest in number, 18,439 about 48% and those who have mortgage are the second highest, 17,198, about 45%. Home owners are lowest about 0.3%. 

SELECT verification_status
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) per_appications
FROM loans
GROUP BY 1
ORDER BY 2 DESC

-- 42.7% (16,464) of the applicants are Not Verified, 32% (12335) are Verified and about 25.3% (9777) are SOurce Verified.

SELECT emp_length
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) per_appications
FROM loans
GROUP BY 1
ORDER BY 2 DESC

-- Employee with 10+ years of experience has most applications under him, about 23% while employee with less than 1 year of expereince has the second highest number of applications, 12 %

SELECT COUNT(*) 
FROM loans 
-- DESCRIPTIVE & STATISTICAL DATA ANALYSIS.
--		 Calculating the averages for important columns
SELECT AVG(annual_income) AS avg_income
	,AVG(dti) avg_dti
	,AVG(installment) avg_installment
	,AVG(int_rate) avg_int
	,AVG(loan_amount) avg_loan
	,AVG(total_acc) avg_acc
	,AVG(total_payment) avg_payment
FROM loans

-- avg income is 69K, 
-- avg dti is 13.3%, 
-- avg instalment is 326, 
-- avg int is 12%, 
-- avg loan is 11K, 
-- avg payment is 12K
---
---
--	Calculating average loan term
SELECT AVG(SPLIT_PART(term, ' ', 2)::INT)
FROM loans
-- Average loan is 42 months long.
--
--
--
-- 		Median Loan Terms
SELECT PERCENTILE_CONT(0.5) WITHIN
GROUP (
		ORDER BY (SPLIT_PART(term, ' ', 2)::INT)
		) AS median
FROM loans;
-- 		Median Loan term is 36 months  
--
--
--
-- 	CREDIT RISK ANALYSIS
-- default rate
SELECT loan_status
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) * 100 AS per
FROM loans
GROUP BY 1
ORDER BY 3 DESC
-- 13.8% loans were charged off 
--
--
--
SELECT grade
	,COUNT(*)
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			WHERE loan_status = 'Charged Off'
			)::DECIMAL, 3) * 100 per_default
FROM loans
WHERE loan_status = 'Charged Off'
GROUP BY 1
ORDER BY 1 
-- 25% of the total defaulted loans came from Grade B while 23% came from Grade C and Grade G had the lowest number of default loans
--
-- Percentage of defaults in each grade
WITH t1 AS (
		SELECT *
			,CASE 
				WHEN loan_status = 'Charged Off'
					THEN 'Bad'
				ELSE 'Good'
				END AS loan_quality
		FROM loans
		)
	,t2 AS (
		SELECT grade
			,loan_quality
			,COUNT(*) AS applications
			,ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY grade)::DECIMAL, 3)*100 percentage_total
		FROM t1
		GROUP BY 1
			,2
		)

SELECT grade
	,percentage_total
FROM t2
WHERE loan_quality = 'Bad'
ORDER BY 1

--  A,B,C,D,E,F,G had the lowest to highest percentage of defaults its total loan applications
-- In terms of absolute numbers, B had the highest number of defaults but in terms of percentage, it was grade G
--
--
-- Average Interest rate for each grade
SELECT grade
	,AVG(int_rate) * 100 AS avg_per_int
FROM loans
GROUP BY 1
ORDER BY 1
-- A had the least avg int while G had the highest int rate on average
--
--
-- purpose of loans
SELECT purpose
	,count(*)
	,ROUND(COUNT(*) / SUM(COUNT(*)) OVER ()::DECIMAL, 3) AS per_total
FROM loans
WHERE loan_status = 'Charged Off'
GROUP BY 1
ORDER BY 2 DESC
-- about 49% of total bad loans were taken for the putpose of 'debt consolidation'.
--
--
--
-- Lets see it as percentage of total apps in each category
WITH t1 AS (
		SELECT *
			,CASE 
				WHEN loan_status = 'Charged Off'
					THEN 'Bad'
				ELSE 'Good'
				END AS loan_quality
		FROM loans
		)
	,t2 AS (
		SELECT purpose
			,loan_quality
			,COUNT(*) AS applications
			,ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY purpose)::DECIMAL, 3) percentage_total
		FROM t1
		GROUP BY 1
			,2
		)

SELECT purpose
	,percentage_total
FROM t2
WHERE loan_quality = 'Bad'
ORDER BY 2 DESC
-- defaults are higher as categorical percentage for small business, about 25.6%
--
--
-- Default rates for each term
WITH t1
AS (
	SELECT *
		,CASE 
			WHEN loan_status = 'Charged Off'
				THEN 'Bad'
			ELSE 'Good'
			END AS loan_quality
	FROM loans
	)
SELECT SPLIT_PART(term, ' ', 2) AS term_
	,loan_quality
	,COUNT(*)
	,ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY SPLIT_PART(term, ' ', 2))::DECIMAL, 3)
FROM t1
GROUP BY 1
	,2
ORDER BY 1
	,3 DESC
	-- 22% of total loans in 60 month term were bad loans while 10% of total loans in 36 month term were bad loans.

--
-- Temporal Analysis
-- Calculating the Month-To-Date applications
-- We will firstly find out the latest month from the latest date
SELECT MAX(issue_date)
FROM loans

SELECT MIN(issue_date)
FROM loans

-- Data comes from the period 01-01-2021 to 12-12-2021.
-- AVG interest rate over the months
SELECT DATE_TRUNC('month', issue_date),to_char(issue_date,'Month')
	,ROUND((AVG(int_rate) * 100)::DECIMAL, 2) AS Per_Int
FROM loans
GROUP BY 1,2
ORDER BY 1

-- Monthly growth in applications
SELECT DATE_TRUNC('month', issue_date) AS date_month,to_char(issue_date,'Month') as month_
	,COUNT(*) AS new_apps
	,COUNT(*) - LAG(COUNT(*), 1) OVER (
		ORDER BY DATE_TRUNC('month', issue_date)
		) AS change_Over_prev_month
FROM loans
GROUP BY 1,2
ORDER BY 1

-- Default rate for months
WITH t1
AS (
	SELECT *
		,CASE 
			WHEN loan_status = 'Charged Off'
				THEN 'Bad'
			ELSE 'Good'
			END AS loan_quality
	FROM loans
	)
	,t2
AS (
	SELECT DATE_TRUNC('Month', issue_date) AS date_
		,to_char(issue_date, 'Month') AS month_
		,loan_quality
		,COUNT(*)
		,ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY to_char(issue_date, 'Month'))::DECIMAL, 3) * 100 AS default_rate
	FROM t1
	GROUP BY 1
		,2
		,3
	ORDER BY 1
	)
SELECT month_
	,default_rate
FROM t2
WHERE loan_quality = 'Bad'


-- State Level analysis
-- Distribution of the applicants by states
SELECT address_state
	,COUNT(*) AS total_state_applicants
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 3) * 100 AS per_total_applicants
FROM loans
GROUP BY 1
ORDER BY 
	2 DESC
-- CA has highest number of applicants, about 18 %.
-- States with the highest number/percentage of bad loans
WITH t1 AS (
		SELECT *
			,CASE 
				WHEN loan_status = 'Current'
					OR loan_status = 'Fully Paid'
					THEN 'Good_Loan'
				ELSE 'Bad_Loan'
				END AS loan_quality
		FROM loans
		)

SELECT address_state
	,loan_quality
	,COUNT(loan_quality) AS total_loan_quality
	,ROUND(COUNT(*) / (
			SELECT COUNT(*)
			FROM loans
			)::DECIMAL, 4) AS per_total_applicants
FROM t1
GROUP BY 1
	,2
ORDER BY 2
	,3 DESC
-- CA has the highest number of bad loans as well as good loans. But second spot for bad loans belongs to FL and second for good loans is NY.
-- For each state, what percentage of its total loans is Good/Bad
WITH t1 AS (
		SELECT *
			,CASE 
				WHEN loan_status = 'Current'
					OR loan_status = 'Fully Paid'
					THEN 'Good_Loan'
				ELSE 'Bad_Loan'
				END AS loan_quality
		FROM loans
		),
t2 as (
SELECT address_state
	,loan_quality
	,COUNT(*) total_loans
	,ROUND(count(*) / SUM(COUNT(*)) OVER (PARTITION BY address_state)::DECIMAL, 2) AS default_ratio
FROM t1
GROUP BY 1
	,2
ORDER BY 1)

SELECT address_state,
	   default_ratio
FROM t2
WHERE loan_quality = 'Bad_Loan'
ORDER BY 2 DESC

-- Purposes by states
SELECT address_state
	,purpose
	,COUNT(*)
FROM loans
GROUP BY 1
	,2
ORDER BY 1
	,3 DESC
-- DEBT consolidation remains the number 1 purpose statewise too for most of the states
-- 2nd most common purpose for states
WITH t1 AS (
		SELECT address_state
			,purpose
			,COUNT(*)
			,row_number() OVER (
				PARTITION BY address_state ORDER BY COUNT(*) DESC
				) AS rn
		FROM loans
		GROUP BY 1
			,2
		ORDER BY 1
		)
	,t2 AS (
		SELECT address_state
			,purpose
		FROM t1
		WHERE t1.rn = 2
		)

SELECT purpose
	,COUNT(*)
FROM t2
GROUP BY 1
ORDER BY 2 DESC
	-- 36 states have credit card as the second most common purpose.
