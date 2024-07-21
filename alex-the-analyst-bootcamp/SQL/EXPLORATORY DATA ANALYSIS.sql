SELECT * FROM word_layoffs.staging_layoff2;

-- What is the maximum/highest number of employees laid off in a single event?

SELECT 
    MAX(total_laid_off)
FROM
    staging_layoff2;
    
    
-- What is the highest percentage of employees laid off in a single instance?
    -- HERE 1 REPRESENTS 100%
    SELECT 
    MAX(percentage_laid_off)
FROM
    staging_layoff2;
    
    
   -- Which companies laid off 100% of their employees, and what are the details of those layoff events?
    
   SELECT 
    *
FROM
    staging_layoff2
WHERE
    percentage_laid_off = 1;
    
    
    
    
    
-- Which companies laid off their entire workforce, listed in descending order of the total number of employees laid off?
      SELECT 
    *
FROM
    staging_layoff2
WHERE
    percentage_laid_off = 1
ORDER BY total_laid_off DESC;
    
    
   -- Which companies laid off their entire workforce and had the highest amount of funds raised in millions?
    
     SELECT 
    *
FROM
    staging_layoff2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- Which companies have laid off the highest total number of employees?
SELECT 
    company, SUM(total_laid_off)
FROM
    staging_layoff2
GROUP BY company
ORDER BY 2 DESC;

-- What is the range of dates for the layoffs?
SELECT 
    MIN(`date`), MAX(`date`)
FROM
    staging_layoff2;
    
    
    
   -- Which industry has been most impacted by the layoffs
    SELECT 
    industry, SUM(total_laid_off)
FROM
    staging_layoff2
GROUP BY industry
ORDER BY 2 DESC;





-- Which countries have been most affected by the layoffs?

 SELECT 
    country, SUM(total_laid_off)
FROM
    staging_layoff2
GROUP BY country
ORDER BY 2 DESC;

-- How many employees were laid off each year?
SELECT 
    YEAR(`date`), SUM(total_laid_off)
FROM
    staging_layoff2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT * FROM staging_layoff2;

-- How did the number of employees laid off each month accumulate over time?

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS SUM_OF_LaidOff
FROM staging_layoff2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

WITH rolling_total AS (SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS SUM_OF_LaidOff
FROM staging_layoff2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1)
SELECT `month`, SUM_OF_LaidOff, sum(SUM_OF_LaidOff) OVER (order by `month`) AS rollingSUM
 FROM rolling_total;




-- How did the layoffs in the United Kingdom accumulate month by month over time?

WITH UK_ROLLING_TOTAL AS (SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS SUM_OF_LaidOff
FROM staging_layoff2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL AND country = "united kingdom"
GROUP BY `month`
ORDER BY 1)
SELECT `month`, SUM_OF_LaidOff, sum(SUM_OF_LaidOff) OVER (order by `month`) AS rollingSUM
 FROM UK_ROLLING_TOTAL;
