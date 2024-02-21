# Bank  Loan
##Summary
### About Data
The Bank Loan Analysis Report aims to provide actionable insights into loan applications, approvals, and related metrics.
The data consists of 38,576 rows and following columns:
1.	Loan ID: Unique identifier for loans.
2.	Address State: Borrower location for regional analysis.
3.	Employment Length: Indicates employment stability.
4.	Employee Title: Job title for income source verification.
5.	Grade/Sub Grade: Creditworthiness and risk classification.
6.	Home Ownership: Housing status for financial stability assessment.
7.	Issue Date: Loan origination date.
8.	Loan Status: Current state of the loan for performance tracking.
9.	Purpose: Loan reason for segmentation and customization.
10.	Term: Loan duration.
11.	Verification Status: Status of financial information verification.
12.	Annual Income: Yearly earnings for creditworthiness.
13.	DTI: Debt burden relative to income.
14.	Instalment: Monthly repayment amount.
15.	Interest Rate: Cost of borrowing.
16.	Loan Amount: Principal amount borrowed.

### Methodology
   I used Postgres SQL to analyze the data. The data cleaning posed a little challenge as data was found to be mostly normal and clean. The following changes were made before the analysis.<br>
I changed the data style of key date columns to 'ISO,DMY'.<br>
I changed the datatype of these date columns to varchar to import the data and after cleaning, they were changed into date type.<br>
The annual income column was changed to float data type. 

### Approach
There were a lot of possibilities for the data, but I decided to focus on the following aspects of analysis: 
1.	Descriptive Statistics and Data Summary:
o	 Calculate the average of KPIs such as annual income, debt-to-income ratio, installment, interest rate, total amount, and payments etc.
2.	Loan Status Analysis:
o	Investigate the distribution of loan statuses (loan_status).
o	Compare default rates for different loan statuses.
o	Explore reasons for loan delinquency or default.
3.	Credit Score Analysis:
o	Group loans by credit grades (grade and sub_grade) and analyze their performance.
o	Calculate average interest rates (int_rate) for each credit grade.
4.	Temporal Analysis:
o	Analyze the growth, defaults on monthly basis.
5.	Geographical Analysis:
o	Group loans by address_state and analyze loan characteristics by state.

