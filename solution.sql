create database netflix;
use netflix;

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;




-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

select type, count(*) as count from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select * from netflix;

select rating from (select rating,count(rating) as count from netflix
group by  rating order by count desc limit 1) t;


-- 3. List all movies released in a specific year (e.g., 2020)
select *  from netflix where release_year='2020';



-- 4. Find the top 5 countries with the most content on Netflix

 select * from (select country ,count(country) as count,dense_rank() 
 over(order by count(country) desc)  as ranking from netflix
group by country) t

where t.ranking <6 ;



-- 5. Identify the longest movie


SELECT title, duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(REPLACE(duration, ' min', '') AS unsigned) DESC
limit 1;

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


SELECT *
FROM netflix
WHERE LOWER(director) LIKE '%rajiv chilaka%';


/* ------------------------------------------------------
   8. List all TV shows with more than 5 seasons
------------------------------------------------------ */
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


/* ------------------------------------------------------
   9. Count the number of content items in each genre
   (splitting listed_in column by comma)
------------------------------------------------------ */
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
       COUNT(*) AS total_content
FROM netflix
JOIN (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
                UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
) n
ON n.n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
GROUP BY genre;


/* ------------------------------------------------------
   10. Find each year and the average % of content 
       released by India on Netflix
       (Top 5 years with highest avg release)
------------------------------------------------------ */
SELECT country,
       release_year,
       COUNT(show_id) AS total_release,
       ROUND(
           COUNT(show_id) / (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100,
           2
       ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


/* ------------------------------------------------------
   11. List all movies that are documentaries
------------------------------------------------------ */
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';


/* ------------------------------------------------------
   12. Find all content without a director
------------------------------------------------------ */
SELECT *
FROM netflix
WHERE director IS NULL OR director = '';


/* ------------------------------------------------------
   13. Find how many movies actor 'Salman Khan'
       appeared in last 10 years
------------------------------------------------------ */
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;


/* ------------------------------------------------------
   14. Find the top 10 actors who have appeared in
       the highest number of movies produced in India
------------------------------------------------------ */
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor,
       COUNT(*) AS appearances
FROM netflix
JOIN (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
                UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
) n
ON n.n <= 1 + LENGTH(casts) - LENGTH(REPLACE(casts, ',', ''))
WHERE country = 'India'
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;


/* ------------------------------------------------------
   15. Categorize the content based on keywords in description
       - If 'kill' or 'violence' found → 'Bad'
       - Else → 'Good'
       Then count how many items fall into each category
------------------------------------------------------ */
SELECT category,
       type,
       COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) AS categorized_content
GROUP BY category, type
ORDER BY type;






