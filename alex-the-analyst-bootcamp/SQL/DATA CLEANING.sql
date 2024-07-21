SELECT 
    *
FROM
    layoffs;

-- created Stagging Table to work with So Raw data is protect in case of mistake in Data Cleaning process

CREATE TABLE Staging_layoff LIKE layoffs;

SELECT 
    *
FROM
    Staging_layoff;

-- poplulate table staging_layoff;

insert into staging_layoff
select * from layoffs;

-- checking staging table 
 
SELECT 
    *
FROM
    staging_layoff;

-- REMOVING DUPLICATES
 -- first identifing duplicates using Window Function
 
 select *,
 ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
From staging_layoff;


-- USING CTE to see duplicates 
WITH remove_dups AS (select *,
 ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
From staging_layoff)
SELECT * FROM remove_dups
where row_num > 1;



-- USING SUBQUERY TO SEE DUPLICATES
select * FROM ( select *,
 ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
From staging_layoff) duplicates
where row_num > 1;




-- double checking to confirm duplicates

SELECT 
    *
FROM
    staging_layoff
WHERE
    company = 'Yahoo';

-- Duplicates confirmed

-- NOW DELETING THE DUPLICATES  
-- Making another table which includes row_num COLUMN beacuse in MYSQL cannot delete trough CTE

 CREATE TABLE `staging_layoff2` (
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


Select * from staging_layoff2;

-- populating Staging _layoff2 

insert into staging_layoff2
 select *,
 ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
From staging_layoff;

SELECT 
    *
FROM
    staging_layoff2
WHERE
    row_num > 1;


DELETE 
FROM staging_layoff2
Where row_num > 1;


-- DLETE statement did'nt work beacsue SAFE MODE was ON. TO turn off SAFE MODE
SET SQL_SAFE_UPDATES = 0 ;


-- TO confirm all duplicates removed 

 SELECT 
    *
FROM
    staging_layoff2
WHERE
    row_num > 1;

-- CONFIRMED , ALL DUPLICATES REMOVED



-- NOW STANDARDIZATION


SELECT 
    company
FROM
    staging_layoff2;
    
    

UPDATE staging_layoff2 
SET 
    company = TRIM(company);
    
    
    

SELECT DISTINCT
    (industry)
FROM
    staging_layoff2
ORDER BY 1;





SELECT 
    *
FROM
    staging_layoff2
WHERE
    industry LIKE 'crypto%';





UPDATE staging_layoff2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'crypto%';




SELECT DISTINCT
    (country)
FROM
    staging_layoff2
ORDER BY 1;




UPDATE staging_layoff2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';


SELECT 
    `date`
FROM
    staging_layoff2;




SELECT 
    `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM
    staging_layoff2;




UPDATE staging_layoff2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');




alter table staging_layoff2
modify column `date` date;




-- HANDLING NULLS



SELECT 
    *
FROM
    staging_layoff2
WHERE
    industry IS NULL OR industry = ''; 


-- checking if nulls can be poplulated


SELECT 
    *
FROM
    staging_layoff2
WHERE
    company = 'Airbnb';

-- POPULATE NULLS BY JOIN


UPDATE staging_layoff2 
SET 
    industry = NULL
WHERE
    industry = '';



SELECT 
    t1.industry, t2.industry
FROM
    staging_layoff2 t1
        JOIN
    staging_layoff2 t2 ON t1.company = t2.company
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;


UPDATE staging_layoff2 t1
        JOIN
    staging_layoff2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;
        
        
        
        
        
        -- REMOVING UNCESSARY COLUMNS/ROWS
        
        select * from staging_layoff2
        where percentage_laid_off is null
        and total_laid_off is null;
        
        
        delete
        from staging_layoff2
	 where percentage_laid_off is null
        and total_laid_off is null;
        
        
        select * from staging_layoff2;
        
        
        alter table staging_layoff2
        drop column row_num
        
        --  DATA IS READY FOR EXPLORATORY ANALYSIS NOW 

