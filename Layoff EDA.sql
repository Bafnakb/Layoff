-- Exploratory Data Analysis

select *
from layoff_staging_2;

--  max laid off count
select max(total_laid_off)
from layoff_staging_2;

--  min laid off count
select min(total_laid_off)
from layoff_staging_2;

-- company wise layoff count
select company, total_laid_off
from layoff_staging_2
where total_laid_off is not null
order by total_laid_off desc;

-- Companies that were completely shut down
select * 
from layoff_staging_2
where percentage_laid_off = 1
order by total_laid_off desc;

-- Funds raised by companies that were completely shut down
select * 
from layoff_staging_2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- sum of total laid off for each company
select company, sum(total_laid_off) as total
from layoff_staging_2
group by company
order by total desc;

-- sum of total laid off for each industry
select industry, sum(total_laid_off) as total
from layoff_staging_2
group by industry
order by total desc;

-- sum of total laid off for each country
select country, sum(total_laid_off) as total
from layoff_staging_2
group by country
order by total desc;

-- sum of total laid off for each company stage
select stage, sum(total_laid_off) as total
from layoff_staging_2
group by stage
order by total desc;

-- identify the date range
select min(`date`), max(`date`)
from layoff_staging_2;

-- sum of total laid off for each year
select year(`date`), sum(total_laid_off) as total
from layoff_staging_2
group by year(`date`);

-- sum of total laid off year and month wise
select year(`date`) years, month(`date`) months, sum(total_laid_off) as total
from layoff_staging_2
where year(`date`) is not null
group by year(`date`),month(`date`)
order by year(`date`),month(`date`)
;

-- rolling total of total laid off year and month wise
with rolling_total as
(
select year(`date`) years, month(`date`) months,sum(total_laid_off) total
from layoff_staging_2
where year(`date`) is not null
group by year(`date`),month(`date`)
order by year(`date`),month(`date`)
)

select years,months, total, sum(total) over(order by years,months) as rolling_total
from rolling_total;

-- ranking the company wise layoff
with ranking as
(
select company, year(`date`) years, sum(total_laid_off) total,
dense_rank() over(partition by company order by sum(total_laid_off) desc) as ranking
from layoff_staging_2
group by company, year(`date`)
order by 1,2 desc
)

select company , years, total,
dense_rank() over(partition by company order by years desc) as ranking 
from ranking;

-- ranking year and company wise based on layoff count and filtering the top 5 companies for each year
with ranking as
(
select  year(`date`) years, company, sum(total_laid_off) total,
dense_rank() over(partition by year(`date`) order by sum(total_laid_off) desc) as ranking
from layoff_staging_2
group by  year(`date`), company
order by 1,2 desc
)

select * 
from ranking
where ranking<=5 and years is not null
order by years, ranking