SELECT job_schedule_type, AVG(salary_year_avg), AVG(salary_hour_avg)
FROM job_postings_fact
WHERE job_posted_date::DATE > '2023-06-01'
GROUP BY job_schedule_type


SELECT count(job_id),
extract(month FROM (Job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) as month
FROM job_postings_fact
where extract(YEAR FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) = '2023'
group by month
ORDER BY month





-- Create table for January
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- Create table for February
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- Create table for March
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

select * from january_jobs;


SELECT
job_id, salary_year_avg,
CASE
    WHEN salary_hour_avg >= 100000 THEN 'High Salary'
    WHEN salary_year_avg BETWEEN 60000 AND 99999   THEN 'Moderate Salary'
    WHEN salary_year_avg < 60000 THEN 'Low Salary'
ELSE 'Unknown'
END AS Salary_Category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
ORDER BY 
    salary_year_avg ASC;
;


SELECT 
    job_id,
    job_title,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg >= 100000 THEN 'High Salary'
        WHEN salary_year_avg BETWEEN 60000 AND 99999 THEN 'Standard Salary'
        WHEN salary_year_avg < 60000 THEN 'Low Salary'
        ELSE 'Unknown'
    END AS salary_category
FROM 
    job_postings_fact
WHERE 
    job_title = 'Data Analyst'
ORDER BY 
    salary_year_avg ASC;


    WITH company_job_count AS (
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
)
SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM 
    company_dim
LEFT JOIN 
    company_job_count 
ON 
    company_job_count.company_id = company_dim.company_id;


WITH skills_count AS (SELECT skill_id,
COUNT(skill_id) AS total_count
FROM skills_job_dim
GROUP BY skill_id
ORDER BY total_count DESC
LIMIT 5)

SELECT total_count, skills
FROM skills_count LEFT JOIN skills_dim
ON skills_count.skill_id = skills_dim.skill_id
ORDER BY total_count DESC


WITH remote_jobs AS (
    SELECT job_postings_fact.job_id, job_work_from_home,
    skill_id
    FROM job_postings_fact
    JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    WHERE job_work_from_home = True
)

SELECT skills,
COUNT(job_work_from_home)as total_remote_jobs
FROM remote_jobs
JOIN skills_dim
ON skills_dim.skill_id = remote_jobs.skill_id
GROUP By skills
ORDER BY total_remote_jobs DESC







WITH first_quarter_job AS(
WITH first_quarter AS(SELECT job_id,salary_year_avg
FROM january_jobs
UNION
SELECT job_id,salary_year_avg
FROM february_jobs
UNION
SELECT job_id,salary_year_avg
FROM march_jobs)
SELECT first_quarter.job_id, skill_id, salary_year_avg
FROM first_quarter JOIN skills_job_dim
ON first_quarter.job_id = skills_job_dim.job_id
WHERE first_quarter.salary_year_avg > 70000
)

--Select * from first_quarter_job

SELECT job_id, skills, skills_dim.type, salary_year_avg
FROM skills_dim JOIN first_quarter_job
ON skills_dim.skill_id = first_quarter_job.skill_id
ORDER BY 
    salary_year_avg DESC;




WITH first_quarter AS (
    SELECT job_id, salary_year_avg
    FROM january_jobs
    UNION ALL
    SELECT job_id, salary_year_avg
    FROM february_jobs
    UNION ALL
    SELECT job_id, salary_year_avg
    FROM march_jobs
),
first_quarter_job AS (
    SELECT 
        first_quarter.job_id, 
        skills_job_dim.skill_id, 
        first_quarter.salary_year_avg
    FROM 
        first_quarter
    JOIN 
        skills_job_dim
    ON 
        first_quarter.job_id = skills_job_dim.job_id
    WHERE 
        first_quarter.salary_year_avg > 70000
)
SELECT 
    first_quarter_job.job_id, 
    skills_dim.skills, 
    skills_dim.type, 
    first_quarter_job.salary_year_avg
FROM 
    skills_dim
JOIN 
    first_quarter_job
ON 
    skills_dim.skill_id = first_quarter_job.skill_id
ORDER BY 
    salary_year_avg DESC;