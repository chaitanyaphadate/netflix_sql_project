-- Q1 Count of Movies vs TV shows
SELECT show_type, COUNT(show_id) AS count  FROM netflix
GROUP BY show_type;



--Q2. Find the Most Common Rating for Movies and TV Shows
SELECT
	show_type,
	rating,
	ranking,
	county
FROM
	(SELECT
	 	show_type,
		rating,
		COUNT(*) AS county,
		RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2) AS t1
WHERE ranking = 1;	

--Q3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
WHERE show_type = 'Movie' AND release_year = 2020;


--Q4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(show_id)
FROM netflix
GROUP BY 1	
ORDER BY 2 DESC
LIMIT 5;	


--Q5. Identify the Longest Movie
SELECT
	title,
	duration,
	CAST(
		LEFT(
			duration, 
			POSITION(' ' IN duration) -1
			) 
		AS INT
		)
FROM netflix
WHERE show_type = 'Movie' AND duration IS NOT NULL
ORDER BY 3 DESC
LIMIT 1;

SELECT
	duration,
	LEFT(duration, POSITION(' ' IN duration) -1)
FROM netflix;


--6. Find Content Added in the Last 5 Years
SELECT 
	* 
FROM
	netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


--Q7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--2nd solution
SELECT
	*
FROM
	(SELECT
		*,
		UNNEST(STRING_TO_ARRAY(director, ', ')) AS director_new
	FROM netflix)
WHERE director_new = 'Rajiv Chilaka';

--Q8. List All TV Shows with More Than 5 Seasons
SELECT
	*
FROM
	(SELECT 
		title,
		duration,
		CAST(LEFT(duration,
			POSITION(' ' IN duration) -1
			) AS INT) AS seasons
	FROM netflix
	WHERE show_type = 'TV Show')
WHERE seasons > 5
ORDER BY seasons DESC

--2nd solution
SELECT 
	*
FROM netflix
WHERE
	show_type = 'TV Show' AND
	SPLIT_PART(duration, ' ', 1)::INT > 5;


--Q9. Count the Number of Content Items in Each Genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre,
	COUNT(title) AS entries
FROM netflix
GROUP BY genre
ORDER BY entries DESC;


--Q10.Find each year and the average numbers of content release in India on netflix.
SELECT
	release_year,
	COUNT(*) AS content_released
FROM
	(SELECT
		UNNEST(STRING_TO_ARRAY(country, ', ')) AS country_name,
		*
	FROM netflix) AS t1
WHERE country_name = 'India'
GROUP BY release_year
ORDER BY content_released DESC;

-- 2nd solution
SELECT
	DATE_PART('year', date_release) AS year_release,
	COUNT(*) AS content_released	
FROM
	(SELECT
		UNNEST(STRING_TO_ARRAY(country, ', ')) AS country_name,
		(date_added)::DATE AS date_release,
		*
	FROM netflix) AS t1
WHERE country_name = 'India'
GROUP BY year_release
ORDER BY content_released DESC;

--Q11. List All Movies that are Documentaries
SELECT
	*
FROM netflix
WHERE show_type = 'Movie' AND listed_in LIKE '%Documentaries%';

--Q12. Find All Content Without a Director
SELECT
	*
FROM netflix
WHERE director IS NULL;

--Q13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT 
	*
FROM netflix
WHERE casts LIKE '%Salman Khan%' AND (DATE_PART('year',CURRENT_DATE) - release_year) < 10

--Q14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT
	UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
	COUNT(*) AS movie_count
FROM netflix
WHERE country LIKE '%India%'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;


--Q15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT
	*,
	COUNT(*) OVER(PARTITION BY content_label)
FROM
	(SELECT 
		title,
		description,
		CASE
			WHEN description ILIKE '%kill%' THEN 'Bad'
			WHEN description ILIKE '%violence%' THEN 'Bad'
			ELSE 'Good'
		END as content_label
	FROM netflix)