-- 1. Find the total number of job postings per job_title_short.
select 
	job_title_short,
	count(job_id) as Total_Jobs
from job_postings_fact
group by job_title_short
order by total_jobs desc;


-- 2. Which 10 countries have the highest number of job postings?
select 
	job_country,
	count(job_id) as total_jobs 
from job_postings_fact
group by job_country
order by total_jobs desc
limit 10;


-- 3. Which top 10 companies have posted the most job openings?
select 
	company.name as company_name,
	count(jobs.job_id) as total_jobs 
from job_postings_fact as jobs
	join company_dim as company
	on jobs.company_id = company.company_id
group by company_name
order by total_jobs desc
limit 10;


-- 4. Count how many jobs are work_from_home = true for each job_title_short.
select 
	job_title_short,
	job_work_from_home,
	count(job_id) as Total_Jobs 
from job_postings_fact
where job_work_from_home = 'true'
group by job_title_short, job_work_from_home
order by total_jobs desc;


-- 5. What is the job count & average yearly salary for each job_title_short?
select 
	job_title_short,
	count(job_id) as total_jobs,
	round(avg(salary_year_avg), 0) as avg_salary
from job_postings_fact
where salary_year_avg is not null
group by job_title_short
order by avg_salary desc;


-- 6. Which work from home job postings offer $100 and more than $100 per hour?
select 
	job_id, 
	job_title_short,
	job_work_from_home,
	round(salary_hour_avg, 0)
from job_postings_fact
where job_work_from_home = 'true'
	and salary_hour_avg >= 100 and salary_hour_avg is not null
order by salary_hour_avg desc;


-- 7. Show the top 10 skills most frequently required across all jobs.
select 
	sd.skills,
	count(jpf.job_id) as demand_count
from job_postings_fact jpf
	join skills_job_dim sjd on jpf.job_id = sjd.job_id
	join skills_dim sd on sjd.skill_id = sd.skill_id
group by sd.skills
order by demand_count desc
limit 10;


-- 8. Find the average salary per country for each job_title_short.
select 
	job_title_short,
	job_country,
	round(avg(salary_year_avg), 0) as avg_salary,
	count(job_id) as total_jobs
from job_postings_fact
where salary_year_avg is not null and job_country is not null
group by job_title_short, job_country
order by job_title_short, job_country, avg_salary desc;


-- 9. Compare the average salary of remote vs non-remote jobs for each job_title_short.
select 
	job_title_short,
	round(avg(case when job_work_from_home = true then salary_year_avg end), 0)
	as avg_remote_salary,
	round(avg(case when job_work_from_home = false then salary_year_avg end), 0)
	as avg_nonremote_salary,
	count(case when job_work_from_home = true then job_id end) as remote_job_count,
	count(case when job_work_from_home = false then job_id end) as nonremote_job_count
from job_postings_fact
where salary_year_avg is not null
group by job_title_short
order by job_title_short;


-- 10. What is the top 3 in-demand skill for each job title?
with top_three_skills as
(
	select
	job_postings_fact.job_title_short,
	skills_dim.skills,
	count(job_postings_fact.job_id) as total_jobs,
	row_number() over(partition by job_postings_fact.job_title_short
	order by count(job_postings_fact.job_id) desc) as row_num
from job_postings_fact
	join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
	join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
group by job_postings_fact.job_title_short, skills_dim.skills
order by job_postings_fact.job_title_short, total_jobs desc
)
select * from top_three_skills
where row_num in(1, 2, 3);


-- 11. What is the 10 most in-demand skill for Data Analyst job postings?
select 
	job_postings_fact.job_title_short,
	skills_dim.skills,
	count(job_postings_fact.job_id) as total_jobs
from job_postings_fact
	join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
	join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where job_postings_fact.job_title_short = 'Data Analyst'
group by job_postings_fact.job_title_short, skills_dim.skills
order by job_postings_fact.job_title_short, total_jobs desc
limit 10;


-- 12. Among the top countries by job postings, what is the average yearly salary in each?
with top_countries as
(
	select job_country,
	count(job_id) as total_jobs
from job_postings_fact
where salary_year_avg is not null
group by job_country
order by total_jobs desc
limit 10
)
select 
	tc.job_country, 
	tc.total_jobs, 
	round(avg(jpf.salary_year_avg), 0) as avg_salary
from top_countries as tc
	join job_postings_fact as jpf
	on tc.job_country = jpf.job_country
where jpf.salary_year_avg is not null
group by tc.job_country, tc.total_jobs
order by avg_salary desc;


-- 13. For Data Analyst jobs only, calculate the average salary per skill.
select 
	skills_dim.skills,
	round(avg(salary_year_avg), 0) as avg_salary,
	count(job_postings_fact.job_id) as total_jobs
from job_postings_fact
	join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
	join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where job_postings_fact.job_title_short = 'Data Analyst' and salary_year_avg is not null
group by skills_dim.skills
order by avg_salary desc;


/* 14. Rank all job titles by average salary, and compare that ranking
to their job posting volume (salary vs demand). */
with ranked as 
(
	select job_title_short,
	count(job_id) as total_jobs, 
	round(avg(salary_year_avg), 0) as avg_salary,
	row_number() over(order by round(avg(salary_year_avg), 0) desc) as salary_rank,
	row_number() over(order by count(job_id) desc) as demand_rank
from job_postings_fact
where salary_year_avg is not null
group by job_title_short
)
select * from ranked
order by salary_rank;


-- 15. Find the top 10 companies hiring Data Analysts, along with the average salary.
select
	company.name as company_name,
	round(avg(jobs.salary_year_avg), 0) as avg_salary,
	count(jobs.job_id) as total_jobs
from job_postings_fact as jobs
	join company_dim as company on jobs.company_id = company.company_id
where jobs.salary_year_avg is not null and jobs.job_title_short = 'Data Analyst'
group by company_name
order by total_jobs desc
limit 10;