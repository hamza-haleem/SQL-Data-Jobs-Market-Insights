# SQL-Data-Jobs-Market-Insights
## Introduction
This project explores job postings data using SQL. The dataset contains job information, company details, and associated skills. The goal was to perform both general job market analysis and focused role-specific analysis (e.g., Data Analyst) to uncover insights about salaries, skills, and hiring trends.

[View the SQL Queries](Data_Jobs_Analysis.sql)
## Background
The job market is highly competitive, and understanding demand, salaries, and skills is crucial for job seekers and organizations.
This dataset provides structured information such as:
- Job titles and locations
- Salaries (annual/hourly)
- Work from home and health insurance flags
- Required skills for each job
- Company information

By analyzing this data, we can identify high-paying roles, in-demand skills, and hiring patterns across different companies and job titles.
## Tools I Used
- PostgreSQL → to query and analyze the dataset
- DBMS ERD → to understand table relationships
- SQL Window Functions → for ranking and advanced calculations
- GitHub → to document and share the project
## Entity Relationship Diagram (ERD)
The project database consists of four main tables connected through keys:
- company_dim – Stores company details (company name, links, logos).
- job_postings_fact – Fact table containing job postings with salary, location, work type, etc.
- skills_job_dim – Bridge table linking job postings to required skills.
- skills_dim – Dimension table with details about each skill and its type (e.g., programming, tools).

Relationships:
- Each company (company_dim) can have multiple job postings (job_postings_fact).
- Each job posting can require multiple skills (skills_job_dim).
- Each skill (skills_dim) can be associated with multiple job postings.

[Click here for ERD](ERD.png)
## The Analysis
The analysis focused on understanding job market trends. Using SQL, I examined the volume of job postings, average salaries by job title, most active hiring companies, and the prevalence of remote work opportunities. I also explored the demand for technical and analytical skills by aggregating skill frequencies across job postings. This provided a clear picture of which roles are in high demand, which skills are most valued, and how salaries vary by company, work type etc.
### 1. What is the job count & average yearly salary for each job_title_short?
```sql
select 
	job_title_short,
	count(job_id) as total_jobs,
	round(avg(salary_year_avg), 0) as avg_salary
from job_postings_fact
where salary_year_avg is not null
group by job_title_short
order by avg_salary desc;
```
- Senior-level roles such as Senior Data Scientist and Senior Data Engineer earn the highest salaries, both above $150K.
- Data Scientist and Data Engineer roles are highly demanded (3,600–5,000+ postings) with strong six-figure salaries (~$132K).
- Data Analyst positions dominate in volume (6,227 jobs) but have the lowest average salary (~$92K).
- Overall, advanced technical roles (ML, Data Science, Engineering) provide higher pay, while analyst roles offer more opportunities but lower compensation.
 

| Job Title              | Total Jobs | Avg. Salary (USD) |
|------------------------|------------|-------------------|
| Senior Data Scientist  | 1,259      | 155,914           |
| Senior Data Engineer   | 1,128      | 151,373           |
| Machine Learning Engr  | 429        | 151,355           |
| Software Engineer      | 643        | 140,287           |
| Data Engineer          | 3,643      | 132,521           |
| Data Scientist         | 5,065      | 132,483           |
| Cloud Engineer         | 61         | 124,932           |
| Senior Data Analyst    | 936        | 111,888           |
| Business Analyst       | 944        | 97,561            |
| Data Analyst           | 6,227      | 91,814            |

*Job Market Overview by Roles*
### 2. Show the top 10 skills most frequently required across all jobs.
```sql
select 
	sd.skills,
	count(jpf.job_id) as demand_count
from job_postings_fact jpf
	join skills_job_dim sjd on jpf.job_id = sjd.job_id
	join skills_dim sd on sjd.skill_id = sd.skill_id
group by sd.skills
order by demand_count desc
limit 10;
```
- Python and SQL dominate the market with demand counts over 240K, making them the most essential skills.
- Cloud skills like AWS and Azure show strong demand (~100K each), highlighting the rise of cloud technologies.
- Visualization tools such as Tableau and Power BI are also highly requested (~65K–73K).
- Traditional tools like Excel and statistical languages like R remain consistently valuable.
 

| Skill     | Demand Count |
|-----------|--------------|
| Python    | 244,416      |
| SQL       | 240,179      |
| AWS       | 100,386      |
| Azure     | 93,849       |
| Tableau   | 73,560       |
| Spark     | 71,979       |
| R         | 71,835       |
| Excel     | 71,807       |
| Power BI  | 66,183       |
| Java      | 51,294       |

*Most Requested Technical Skills*

## What I Learned
- How to structure SQL queries for both simple aggregations and complex joins
- Using window functions (ROW_NUMBER, RANK) to rank job titles by salary and demand
- Importance of role-specific analysis (e.g., Data Analyst) for deeper insights
- How to document a technical project for sharing on GitHub
## Conclusion

## Closing Thoughts
This project was a great exercise in SQL analysis, data exploration, and storytelling with queries.
Publishing it on GitHub not only serves as a portfolio piece but also as a knowledge-sharing resource for others learning SQL.
