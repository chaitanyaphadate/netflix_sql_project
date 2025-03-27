# Netflix Movies and TV Shows Data Analysis using SQL
![Netflix logo](https://github.com/chaitanyaphadate/netflix_sql_project/blob/main/Logonetflix.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    show_type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	show_type,
	COUNT(show_id) AS count  
FROM netflix
GROUP BY show_type;
```
**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```
**Objective:** Identify the most frequently occurring rating for each type of content.


### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT 
	* 
FROM netflix
WHERE 
	show_type = 'Movie' 
	AND 
	release_year = 2020;
```
**Objective:** Retrieve all movies released in a specific year.


### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(show_id)
FROM netflix
GROUP BY 1	
ORDER BY 2 DESC
LIMIT 5;
```
**Objective:** Identify the top 5 countries with the highest number of content items.


### 5. Identify the Longest Movie

```sql
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
```
**Objective:** Find the movie with the longest duration.


### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	* 
FROM
	netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
**Objective:** Retrieve content added to Netflix in the last 5 years.


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```
**Objective:** List all content directed by 'Rajiv Chilaka'.


### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
	*
FROM netflix
WHERE
	show_type = 'TV Show' AND
	SPLIT_PART(duration, ' ', 1)::INT > 5;
```
**Objective:** Identify TV shows with more than 5 seasons.


### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre,
	COUNT(title) AS entries
FROM netflix
GROUP BY genre
ORDER BY entries DESC;
```
**Objective:** Count the number of content items in each genre.


### 10.Find number of content released in India each year on netflix, sort it in descending order.

```sql
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
```
**Objective:** Calculate and rank years by the number of content releases in India.


### 11. List All Movies that are Documentaries

```sql
SELECT
	*
FROM netflix
WHERE show_type = 'Movie' AND listed_in LIKE '%Documentaries%';
```
**Objective:** Retrieve all movies classified as documentaries.


### 12. Find All Content Without a Director

```sql
SELECT
	*
FROM netflix
WHERE director IS NULL;
```
**Objective:** List content that does not have a director.


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
	*
FROM netflix
WHERE casts LIKE '%Salman Khan%' AND (DATE_PART('year',CURRENT_DATE) - release_year) < 10;
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
	COUNT(*) AS movie_count
FROM netflix
WHERE country LIKE '%India%'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
	FROM netflix);
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

