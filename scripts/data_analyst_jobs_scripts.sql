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
--b. How many companies are there with more that 5000 reviews across all locations?

SELECT DISTINCT company AS unique_company,
	ROUND(AVG(star_rating), 2) AS avg_star_rating
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY avg_star_rating DESC;

-- ANSWER: 40 companies

--Attempting to add the review_count to the output:
--OBSERVATIONS: without including the reviews themselves, the count is 41.  Including the reviews in the display, the count is 46, due to several duplicate review count values, such as 6790, and 6791. 
--ATTEMPTED SOLUTIONS: DISTINCT ON did not resolve the issue

SELECT DISTINCT company,
	ROUND(AVG(star_rating), 2) AS avg_star_rating,
	SUM(review_count) AS review_count_over_5000_all_locations
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company IS NOT NULL
GROUP BY company, review_count 
ORDER BY avg_star_rating DESC;

--TROUBLESHOOTING: The issue seems to be with the data in review counts having errors or not being the same across locations.  Since the data seems to vary only +1 to +3, it is not likely due to different review numbers by location that would need to be summed.
-- ANSWER: 45 companies (incorrect)

SELECT company, 
	ROUND(AVG(star_rating), 2) AS avg_star_rating,
	review_count,
	location
FROM data_analyst_jobs
WHERE review_count>5000 
	AND company LIKE 'Wells%'
GROUP BY company, review_count, location;

-- TROUBLESHOOTING: Attempting to pull data from Wells Fargo shows 5 locations, 3 of which have a review count of 29963, and 2 of which have a review count of 29966. We might be able to fix this with an IF statement, but we haven't learned these yet.






