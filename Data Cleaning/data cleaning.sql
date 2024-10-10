-- Data Cleaning

SELECT *
FROM layoffs;

-- Step 1 Remove Duplicates
-- Step 2 Standardize The Data
-- Step 3 Null values or Blank values
-- Step 4 Remove Any Columns

CREATE TABLE layoffs_staging
LIKE layoffs;
#Böyle tablo oluşturduğumuzda veriler gelmiyor ama diğer tablonun sütunlarını aynısını oluşturmuş oluyoruz

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;
#içindeki bütün verileri bu kod ile aktarmış olduk

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;
#row number ile bir dosyanın benzeri olup olmadığını anlıyoruz bu numaraya göre de birazdan silme işlemi uygulayacağız

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
#şu an diğer kopyalarını bulduk diğer verilerin

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;
-- Şu an içinde veri olmayan ama aynı olan bir tablo oluşturuldu CTE ile DELETE ve UPDATE işlemleri yapılamadığı için CTE de oluşturduğumuz sutunu normal bir tablo içinde gösterdik
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- layoffs_staging tablosunu içinde row_num bulunan layoffs_staging2 tablosuna aktardık
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing Data

SELECT DISTINCT(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
-- TRAILING spesifik olarak boşluk yerine başka bir şey silmek istediğimiz zaman kullanmamız gerekn bir metod
WHERE country LIKE 'United States%';

-- date şu an text şeklinde veri alıyor ama onun date şeklinde veri almasını sağlamalıyız şu an onu yazacağız
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;
 
 -- Remove Null or Blank Values
 
 SELECT *
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
 SELECT *
 FROM layoffs_staging2
 WHERE industry is NULL
 OR industry = '';
 
 SELECT *
 FROM layoffs_staging2
 WHERE company = 'Airbnb';
 
 SELECT *
 FROM layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

UPDATE layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

 SELECT *
 FROM layoffs_staging2
 WHERE company LIKE 'Bally%';
 
 SELECT *
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
 -- NULL yazan veriler işimize yaramadığı için o verileri görüp onarı silme işlemi yapacağız
 
 DELETE
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;





