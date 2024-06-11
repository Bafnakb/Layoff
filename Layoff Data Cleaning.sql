-- Create database
Create database world_layoff;

-- use the intented database for query execution
use world_layoff;

-- Understand the Data
select * 
from layoffs;

-- Data Cleaning Plan/Steps
-- 1. Remove duplicate
-- 2. Standardize data
-- 3. Null values and Blank values
-- 4. Remove any columns

insert into  layoff_staging_1
select *
from layoffs;

CREATE TABLE `layoff_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Identify the duplicate rows
insert into  layoff_staging_2
select *, row_number() 
	over(partition by company, location, industry, total_laid_off, 
		percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging_1;

select * from layoff_staging_2;
-- delete the duplicate rows
delete
from layoff_staging_2
where row_num > 1;

-- Standardize the data
-- 1. Trim leading and trailing whitespace
select company , trim(company)
from layoff_staging_2;

update layoff_staging_2
set company = trim(company);

-- 2. Standardize the industry
select *
from layoff_staging_2
where industry like 'Crypto%';

update layoff_staging_2
set industry = 'Crypto'
where industry like 'Crypto%';

-- 3. Trim trailing .
update layoff_staging_2
set country = trim(trailing '.' from country);

-- Convert date column from string data type to date data type
update layoff_staging_2
set `date`= str_to_date(`date`, '%m/%d/%Y');

Alter table layoff_staging_2
modify column `date` date;


-- Update null values in industry column
select * 
from layoff_staging_2
where industry is NULL or industry = '';

select * 
from layoff_staging_2 t1
inner join layoff_staging_2 t2
on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

update layoff_staging_2
set industry = null
where industry = '';

update layoff_staging_2 t1
join layoff_staging_2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- delete null values from total_laid_off and percentage_laid_off
delete from layoff_staging_2
where total_laid_off =''
and percentage_laid_off = '';

select * from layoff_staging_2;

alter table layoff_staging_2
drop column row_num;
