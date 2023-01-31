-- The dataset for this exercise has been derived from the `Indeed Data Scientist/Analyst/Engineer` 
-- [dataset](https://www.kaggle.com/elroyggj/indeed-dataset-data-scientistanalystengineer) on kaggle.com. 

-- PREP
-- Before beginning to answer questions, take some time to review the data dictionary and familiarize yourself with the data that is contained in each column.

-- OBSERVATIONS
-- The data_analyst_jobs table has 9 fields or columns.  
-- For days_since_posting, if less than a day, result is rounded up to a full day
-- Titles are not unique ids, but each job posting is listed by its title

-- PROJECT REQUIREMENTS 
-- Provide the SQL queries and answers for the following questions/tasks using the data_analyst_jobs table you have created in PostgreSQL.
-----------------------------------
-- 1.	How many rows are in the data_analyst_jobs table?

SELECT *
FROM data_analyst_jobs;

-- RESULT: Total rows 1000 of 1793

--Q: is the result limited to 1000 rows?
--https://stackoverflow.com/questions/62595257/pgadmin-is-only-returning-1000-rows-for-a-query-on-a-table-with-over-225000-rows

--To change parameter go to config.py pgAdmin4/web folder
--##########################################################################
--# Number of records to fetch in one batch in query tool when query result
--# set is large.
--##########################################################################
--ON_DEMAND_RECORD_COUNT = 100000000

--*NOTE* did not change setting at this time

SELECT COUNT(title)
FROM data_analyst_jobs;

-- RESULT: 1793
-------------------------------------

--2.	Write a query to look at just the first 10 rows. What company is associated with the job posting on the 10th row?

SELECT *
FROM data_analyst_jobs
LIMIT 10;

-- ANSWER: XTO Land Data Analyst

---------------------------------------

--3.a. How many postings are in Tennessee? 
SELECT COUNT(location)
FROM data_analyst_jobs
WHERE location IS NULL;

-- OBSERVATION: There are no null values for location.

SELECT COUNT(location)
FROM data_analyst_jobs
WHERE location ILIKE 'Te%';

-- OBSERVATION: There are no values where Tennessee or Tenn is input instead of TN.

SELECT COUNT(title)
FROM data_analyst_jobs
WHERE location='%TN%';

-- ANSWER: None.  There are no values where there are spaces before or after TN.  Location data seems fairly clean.

SELECT COUNT(title)
FROM data_analyst_jobs
WHERE location='TN';

-- ANSWER: 21

SELECT title AS postings, location
FROM data_analyst_jobs
WHERE location LIKE 'TN';

-- ANSWER: 21 postings for TN

--b.How many are there in either Tennessee or Kentucky?

SELECT COUNT(title)
FROM data_analyst_jobs
WHERE location='TN' 
	OR location='KY';

-- ANSWER 27 postings for TN & KY

SELECT title AS job_posting, location
FROM data_analyst_jobs
WHERE location LIKE 'TN'
	OR location LIKE 'KY'
ORDER BY location;

-- ANSWER: 27 job_posting for KY & TN

------------------------------------------------

-- 5.	How many postings in the dataset have a review count between 500 and 1000?
-- KEY FACTORS: title, review_count, BETWEEN (inclusive) 

SELECT COUNT(title) as job_posting
FROM data_analyst_jobs
WHERE review_count BETWEEN 500 AND 1000;

-- ANSWER: 151

SELECT title as job_posting, review_count
FROM data_analyst_jobs
WHERE review_count BETWEEN 500 AND 1000
ORDER BY review_count DESC;

-- ANSWER: 151 postings with review_count between 500 and 1000 in descending order

-------------------------------------------------

-- 6. Show the average star rating for companies in each state. 
-- The output should show the state as `state` and the average rating for the state as `avg_rating`. 
-- Which state shows the highest average rating?
-- KEY FACTORS: location, star_rating, AVG

SELECT DISTINCT location AS state,
	ROUND(AVG(star_rating), 2) AS avg_rating
FROM data_analyst_jobs
WHERE star_rating IS NOT NULL
GROUP BY location
ORDER BY avg_rating DESC;

-- ANSWER: NE (New England) has the highest average rating

---------------------------------------------------

--7.	Select unique job titles from the data_analyst_jobs table. How many are there?

SELECT DISTINCT title AS unique_title
FROM data_analyst_jobs;

-- ANSWER: 881 unique titles

SELECT COUNT(DISTINCT title) AS unique_title
FROM data_analyst_jobs;

-- ANSWER: a count of 881 unique titles

-----------------------------------------------------

--8.	How many unique job titles are there for California companies?
-- KEY FACTORS: COUNT(DISTINCT title), location='CA'

SELECT DISTINCT title AS unique_job_title, location
FROM data_analyst_jobs
WHERE location='CA';

-- ANSWER: 230 rows of unique_job_title with a location of CA

SELECT COUNT(DISTINCT title) AS unique_job_title_in_CA
FROM data_analyst_jobs
WHERE location='CA';

-- ANSWER: a count of 230

------------------------------------------------------

--9.  a. Find the name of each company and its average star rating for all companies that have more than 5000 reviews across all locations. 
--KEY FACTORS: a. DISTINCT company, AVG(star_rating), review_count>5000, across all locations 

SELECT DISTINCT company,
	ROUND(AVG(star_rating), 2) AS avg_star_rating
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY avg_star_rating DESC;

--b. How many companies are there with more that 5000 reviews across all locations?
-- ANSWER: 40 companies

--****************************************************

--*see attempts below to add review_count as a column in the results*
SELECT company, review_count AS review_count_more_than_5000 
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY review_count;

--ANSWER: 45 companies, there are duplicates due to issues with the data

--OBSERVATIONS: there are duplicate entries for some companies even with count DISTINCT(companies) due to discrepancies in some of the revew counts for certain company locations.  The data varies by +1 to +3.  Could that mean it is due to some kind of INTEGER v. DECIMAL issue?
--ATTEMPTED SOLUTIONS: DISTINCT ON did not resolve the issue

--TEST1: Do the review counts need to be SUMmed?
SELECT company,
	ROUND(AVG(star_rating), 2) AS avg_star_rating,
	SUM(review_count) AS review_count_over_5000_all_locations
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY avg_star_rating DESC;

-- ANSWER: 45 companies (incorrect)

-- TEST2: Review data from one of the duplicated countries, by location.  Wells Fargo shows 5 locations, 3 of which have a review count of 29963, and 2 of which have a review count of 29966.
--TROUBLESHOOTING: We might be able to fix this with an IF statement, but we haven't learned these yet.

SELECT company, 
	ROUND(AVG(star_rating), 2) AS avg_star_rating,
	review_count,
	location
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company LIKE 'Wells%'
GROUP BY company, review_count, location;

--****************
--verified this issue does not need to be resolved
-------------------------------------------

--10.	Add the code to order the query in #9 from highest to lowest average star rating. 
--Which company with more than 5000 reviews across all locations in the dataset has the highest star rating? What is that rating?

SELECT company,
	ROUND(AVG(star_rating), 2) AS avg_star_rating
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY avg_star_rating DESC;

--ANSWER: American Express, 4.20

-------------------------------------------------

--11.	Find all the job titles that contain the word ‘Analyst’. 
--How many different job titles are there?

SELECT DISTINCT title
FROM data_analyst_jobs
WHERE title ILIKE '%Analyst%';

--ANSWER: 774
--------------------------------------------

--12.	How many different job titles do not contain either the word ‘Analyst’ or the word ‘Analytics’? 
-- What word do these positions have in common?

SELECT DISTINCT title
FROM data_analyst_jobs
WHERE title NOT ILIKE '%Analytics%'
	OR title NOT ILIKE '%Analyst%';

-- ANSWER: 4 titles.  "Tableau" is common to all of them.

--------------------------------------------

--**BONUS:**
--You want to understand which jobs requiring SQL are hard to fill. 
--Find the number of jobs by industry (domain) that require SQL and have been posted longer than 3 weeks. 
--Disregard any postings where the domain is NULL. 
--Order your results so that the domain with the greatest number of `hard to fill` jobs is at the top. 
--KEY FACTORS, title, industry, days_since_posting>21, IS NULL, GROUP BY industry, ORDER BY DESC, requiring SQL

SELECT domain,
	COUNT(title) AS count_hard_to_fill
FROM data_analyst_jobs
WHERE skill LIKE '%SQL%'
	AND days_since_posting > 21
	AND domain IS NOT NULL
GROUP BY domain
ORDER BY count_hard_to_fill DESC
LIMIT 4;

--Which three industries are in the top 4 on this list? 
-- ANSWER: Technology, Finance, and Healthcare

--How many jobs have been listed for more than 3 weeks for each of the top 4?
--1) Internet and Software - 62, 
--2) Banks and Financial Services - 61
--3) Consulting and Business Services - 57
--4) Health Care - 52