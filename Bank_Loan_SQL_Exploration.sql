SELECT *
FROM BankLoanProject.dbo.bank_loan;

SELECT COUNT(*) 
FROM bank_loan; -- 38576 Records

SELECT issue_date
FROM bank_loan
GROUP BY issue_date
ORDER BY issue_date; -- Bank loans in yr 2021

--Calculate total applications received in the year

SELECT COUNT(id) AS Total_Loan_Applications
FROM bank_loan;

--Calculate MTD Total Loan Applications assuming we are in DEC
SELECT COUNT(id) AS Total_Loan_Applications
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

--Calculate PMTD Total Loan Applications
SELECT COUNT(id) AS Total_Loan_Applications
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--Calculate Mom Total Loan Applications % difference
WITH MTD AS (
SELECT COUNT(id) AS Total_Loan_Applications
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021),
PMTD AS (
SELECT COUNT(id) AS Total_Loan_Applications
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021)

SELECT 100*(MTD.Total_Loan_Applications - PMTD.Total_Loan_Applications)/CAST(PMTD.Total_Loan_Applications AS FLOAT) AS MOM_Total_Loan_Applications
FROM MTD, PMTD

--Calculate Mom Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM bank_loan

--Calculate Mom Total Funded Amount % difference
WITH MTD AS (
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021),
PMTD AS (
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021)

SELECT 100*(MTD.Total_Funded_Amount - PMTD.Total_Funded_Amount)/CAST(PMTD.Total_Funded_Amount AS FLOAT) AS MOM_Total_Funded_Amount
FROM MTD, PMTD


--Calculate Mom Total Amount Received
SELECT SUM(loan_amount) AS Total_Amount_Received
FROM bank_loan

--Calculate Mom Total Amount Received % difference
WITH MTD AS (
SELECT SUM(total_payment) AS Total_Amount_Received
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021),
PMTD AS (
SELECT SUM(total_payment) AS Total_Amount_Received
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021)

SELECT 100*(MTD.Total_Amount_Received - PMTD.Total_Amount_Received)/CAST(PMTD.Total_Amount_Received AS FLOAT) AS MOM_Total_Amount_Received
FROM MTD, PMTD


--Calculate the average interest rates
SELECT AVG(int_rate)*100 AS Avg_Int_Rate
FROM bank_loan


--Calculate Mom Avg Interest Rate % difference
WITH MTD AS (
SELECT AVG(int_rate)*100 AS Avg_Int_Rate
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021),
PMTD AS (
SELECT AVG(int_rate)*100 AS Avg_Int_Rate
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021)

SELECT 100*(MTD.Avg_Int_Rate - PMTD.Avg_Int_Rate)/CAST(PMTD.Avg_Int_Rate AS FLOAT) AS MOM_Avg_Int_Rate
FROM MTD, PMTD


--Calculate the average debt to income ratio (DTI)
SELECT AVG(dti)*100 AS Average_DTI
FROM bank_loan

--Calculate Mom Avg Interest Rate % difference
WITH MTD AS (
SELECT AVG(dti)*100 AS Average_DTI
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021),
PMTD AS (
SELECT AVG(dti)*100 AS Average_DTI
FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021)

SELECT 100*(MTD.Average_DTI - PMTD.Average_DTI)/CAST(PMTD.Average_DTI AS FLOAT) AS MOM_Average_DTI
FROM MTD, PMTD


-- Good Loan Application % : 'Fully Paid' and 'Current.'
WITH StatCat AS (
SELECT  CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current'THEN 'Good Loan' 
			WHEN loan_status = 'Charged Off' THEN 'Bad Loan' ELSE NULL END AS Status_Category
FROM bank_loan)

SELECT 100 * COUNT(Status_Category) / CAST((SELECT COUNT(*) AS Total_Applications
FROM bank_loan) AS FLOAT) AS Good_Loans_Perc
FROM StatCat 
WHERE Status_Category = 'Good Loan' 


-- Total Good Loan Applications
SELECT COUNT(id) AS Total_Good_Loan_Applications
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

--Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_Amount
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

--Good Loan Total Received Amount
SELECT SUM(total_payment) AS Good_Loan_Total_Received_Amount
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Bad Loan Application % : 'Charged Off'
WITH StatCat AS (
SELECT  CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current'THEN 'Good Loan' 
			WHEN loan_status = 'Charged Off' THEN 'Bad Loan' ELSE NULL END AS Status_Category
FROM bank_loan)

SELECT 100 * COUNT(Status_Category) / CAST((SELECT COUNT(*) AS Total_Applications
FROM bank_loan) AS FLOAT) AS Bad_Loans_Perc
FROM StatCat 
WHERE Status_Category = 'Bad Loan' 


-- Total Bad Loan Applications
SELECT COUNT(id) AS Total_Bad_Loan_Applications
FROM bank_loan
WHERE loan_status = 'Charged Off'

--Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_Amount
FROM bank_loan
WHERE loan_status = 'Charged Off';

--Bad Loan Total Received Amount
SELECT SUM(total_payment) AS Bad_Loan_Total_Received_Amount
FROM bank_loan
WHERE loan_status = 'Charged Off';


--Calculate all KPIs based on loan status
SELECT  loan_status
		,CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current'THEN 'Good Loan' 
			WHEN loan_status = 'Charged Off' THEN 'Bad Loan' ELSE NULL END AS Status_Category
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate) Avg_Int_Rate
		,AVG(dti) AS Avg_DTI
FROM bank_loan
GROUP BY loan_status

--Calculate all KPIs based on Month
SELECT  Month(issue_date) AS Month_Num
		,DateName(month, issue_date) Month_Name
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY Month(issue_date)
		,DateName(month,issue_date)
Order BY Month(issue_date)

--Calculate all KPIs based on State
SELECT  address_state
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY address_state
ORDER BY address_state

--Calculate all KPIs based on Term
SELECT  term
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY term
ORDER BY term

--Calculate all KPIs based on Employment Length
SELECT  emp_length
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY emp_length
ORDER BY emp_length

--Calculate all KPIs based on Loan Purpose 
SELECT  purpose
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY purpose
ORDER BY purpose

--Calculate all KPIs based on Home Ownership
SELECT  home_ownership
		,COUNT(id) AS Total_Loan_Applications
		,SUM(loan_amount) AS Funded_Amount
		,SUM(total_payment) AS Total_Received_Amount
		,AVG(int_rate)*100 Avg_Int_Rate
		,AVG(dti)*100 AS Avg_DTI
FROM bank_loan
GROUP BY home_ownership
ORDER BY home_ownership