CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4


**EXPLORATORY DATA ANALYSIS**

--check total unique apps in both data sets

SELECT COUNT(DISTINCT id) AS AppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS AppIDs
FROM appleStore_description_combined

--check for missing values in critical fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS NULL

--find number of apps per genreAppleStore

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--overview of apps' ratings

SELECT min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

--get the price distribution of apps

SELECT
	(price / 2) *2 AS PriceRangeStart,
	((price / 2) *2) +2 AS PriceRangeEnd,
    COUNT(*) AS NumApps
 FROM AppleStore
GROUP BY PriceRangeStart
ORDER BY PriceRangeStart


**DATA ANALYSIS**

--do paid apps have higher ratings than free apps 

SELECT CASE
			when price > 0 THEN 'Paid'
            ELSE 'Free'
          END AS App_Type,
          avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- check if apps supporting multiople languages have higher languages

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            else '>10 languages'
      END AS language_bucket,
      avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

--check genres that have low ratings 

SELECT prime_genre,
		avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP by prime_genre
ORDER BY Avg_Rating ASC

--check if correlation is present between app description length and user rating

SELECT CASE
			WHEN length(b.app_desc) <500 then 'Short'
            when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            else 'Long'
         End as description_length_range,
         avg(a.user_rating) as average_rating

FROM 
	AppleStore AS a
JOIN
	appleStore_description_combined AS b
ON
	a.id = b.id
    
group by description_length_range
order by average_rating DESC

--check top rated apps in each genre

SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
  		SELECT
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  		FROM
  		AppleStore
  ) AS a 
  WHERE
  a.rank = 1
