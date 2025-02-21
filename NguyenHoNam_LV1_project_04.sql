USE beemovies;

/* Now that you have imported the data sets, let’s explore some of the tables.
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 'movie' AS table_name, COUNT(*) AS row_count FROM beemovies.movie
UNION ALL
SELECT 'genre', COUNT(*) FROM beemovies.genre
UNION ALL
SELECT 'ratings', COUNT(*) FROM beemovies.ratings
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM beemovies.role_mapping
UNION ALL
SELECT 'names', COUNT(*) FROM beemovies.names
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM beemovies.director_mapping;



-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT * 
FROM beemovies.movie
WHERE  id IS NULL
   OR title IS NULL 
   OR year IS NULL 
   OR date_published IS NULL 
   OR duration IS NULL 
   OR country IS NULL 
   OR worlwide_gross_income IS NULL 
   OR languages IS NULL 
   OR production_company IS NULL;



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year.
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
1)
SELECT movie.year, COUNT(DISTINCT id) AS number_of_movies
FROM beemovies.movie
GROUP BY movie.year;

2)
WITH movie_with_month as (
	SELECT *, month(date_published) as month
	FROM beemovies.movie
)

SELECT mwm.month, COUNT(DISTINCT mwm.id) as number_of_movies
FROM movie_with_month as mwm
GROUP BY mwm.month

	


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table.
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/

-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

WITH is_usa_or_india AS (
    SELECT *,
        CASE 
            WHEN (country = 'USA' OR country LIKE 'USA,%' OR country LIKE '%,USA,%' OR country LIKE '%,USA') 
            THEN 'USA' 
            ELSE NULL 
        END AS usa_flag,

        CASE 
            WHEN (country = 'India' OR country LIKE 'India,%' OR country LIKE '%,India,%' OR country LIKE '%,India') 
            THEN 'India' 
            ELSE NULL 
        END AS india_flag
    FROM beemovies.movie
)    
SELECT iui.usa_flag, COUNT(iui.year) AS movie_count
FROM is_usa_or_india AS iui
WHERE iui.year = 2019 AND iui.usa_flag IS NOT NULL
GROUP BY iui.usa_flag
UNION ALL
SELECT iui.india_flag, COUNT(iui.year) AS movie_count
FROM is_usa_or_india AS iui
WHERE iui.year = 2019 AND iui.india_flag IS NOT NULL
GROUP BY iui.india_flag;




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!!
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT genre
FROM beemovies.genre
GROUP BY genre





/* So, Bee Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT genre, count(*)
FROM beemovies.genre 
GROUP BY genre
order by count(*) DESC


/* So, based on the insight that you just drew, Bee Movies should focus on the ‘Drama’ genre.
But wait, it is too early to decide. A movie can belong to two or more genres.
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT COUNT(*) AS single_genre_movie_count
FROM (
    SELECT movie_id
    FROM beemovies.genre
    GROUP BY movie_id
    HAVING COUNT(genre) = 1
) AS single_genre_movies;



/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant.
Now, let's find out the possible duration of Bee Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre?
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT gr.genre, AVG(mv.duration)
FROM beemovies.genre as gr
LEFT JOIN beemovies.movie as mv
ON gr.movie_id = mv.id
GROUP BY gr.genre




/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced?
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT genre, count(*) "Number of movies",
	RANK() OVER (order by count(*) DESC) "Genre_rank"
FROM beemovies.genre 
GROUP BY genre
order by count(*) DESC


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables.
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT max(avg_rating) max_avg_rating, min(avg_rating) min_avg_rating, 
		max(total_votes) max_total_votes, min(total_votes) min_total_votes,
        max(median_rating)  min_median_rating ,min(median_rating)  min_median_rating
FROM beemovies.ratings




/* So, the minimum and maximum values in each column of the ratings table are in the expected range.
This implies there are no outliers in the table.
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT mv.title, rt.avg_rating "avg_rating",
	RANK() OVER (order by avg_rating DESC) "movie_rank"
FROM beemovies.ratings as rt
LEFT JOIN beemovies.movie as mv
ON rt.movie_id=mv.id



/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating, count(*)
FROM beemovies.ratings 
GROUP BY median_rating
order by median_rating asc



/* Movies with a median rating of 7 is highest in number.
Now, let's find out the production house with which Bee Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    mv.production_company, 
    COUNT(*) AS hit_movie_count,
    RANK() OVER (ORDER BY COUNT(*) DESC)
FROM beemovies.ratings AS rt
LEFT JOIN beemovies.movie AS mv
ON rt.movie_id = mv.id
WHERE rt.avg_rating > 8 
AND mv.production_company IS NOT NULL
GROUP BY mv.production_company




-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    g.genre, 
    COUNT(m.id) AS movie_count
FROM beemovies.movie AS m
JOIN beemovies.genre AS g ON m.id = g.movie_id
JOIN beemovies.ratings AS r ON m.id = r.movie_id
WHERE (m.country = 'USA' OR m.country LIKE 'USA,%' OR m.country LIKE '%,USA,%' OR m.country LIKE '%,USA')
AND m.date_published BETWEEN '2017-03-01' AND '2017-03-31' 
AND r.total_votes > 1000 
GROUP BY g.genre
ORDER BY movie_count DESC;









-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT 
    g.genre, 
    m.title, 
    r.avg_rating
FROM beemovies.movie AS m
JOIN beemovies.genre AS g ON m.id = g.movie_id
JOIN beemovies.ratings AS r ON m.id = r.movie_id
WHERE m.title LIKE 'The %'  
AND r.avg_rating > 8 
ORDER BY g.genre, r.avg_rating DESC;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT count(*) as number_of_movie
FROM beemovies.ratings as rt
LEFT JOIN beemovies.movie as mv
ON rt.movie_id=mv.id
WHERE mv.date_published BETWEEN '2018-4-1' AND '2019-4-1'
AND rt.median_rating  = 8




-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies?
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


--  Do German movies get more votes than Italian movies?

with german_vote as (
	SELECT sum(rt.total_votes) as votes
    FROM beemovies.ratings as rt
	LEFT JOIN beemovies.movie as mv
	ON rt.movie_id=mv.id
    WHERE (mv.country='Germany' OR mv.country LIKE 'Germany,%' OR mv.country LIKE '%,Germany,%' OR mv.country LIKE '%,Germany')
),
italy_vote as (
	SELECT sum(rt.total_votes) as votes
    FROM beemovies.ratings as rt
	LEFT JOIN beemovies.movie as mv
	ON rt.movie_id=mv.id
    WHERE (mv.country='Italy' OR mv.country LIKE 'Italy,%' OR mv.country LIKE '%,Italy,%' OR mv.country LIKE '%,Italy')

)

SELECT  gv.votes as German_Total_vote, iv.votes as Italy_Total_vote
FROM german_vote as gv, italy_vote as iv


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table.
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM beemovies.names;







/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew.
Let’s find out the top three directors in the top three genres who can be hired by Bee Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH rating_movies AS (
    SELECT m.id 
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    WHERE r.avg_rating > 8
)

SELECT 
    n.name AS director_name, 
    COUNT(rm.id) AS movie_count  
FROM beemovies.director_mapping AS dm
LEFT JOIN rating_movies AS rm  
ON dm.movie_id = rm.id
LEFT JOIN beemovies.names AS n
ON dm.name_id = n.id
GROUP BY dm.name_id, n.name 
ORDER BY movie_count DESC
LIMIT 3;








/* James Mangold can be hired as the director for Bee's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'.
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    n.name AS actor_name, 
    COUNT(rm.movie_id) AS movie_count
FROM beemovies.role_mapping AS rm
JOIN beemovies.ratings AS r 
ON rm.movie_id = r.movie_id
JOIN beemovies.names AS n 
ON rm.name_id = n.id
WHERE r.median_rating >= 8
AND rm.category = 'actor'  
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;







/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again.
Bee Movies plans to partner with other global production houses.
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH ranked_production_houses AS (
    SELECT 
        m.production_company, 
        SUM(r.total_votes) AS vote_count,
        RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    WHERE m.production_company IS NOT NULL 
    GROUP BY m.production_company
)
SELECT production_company, vote_count, prod_comp_rank
FROM ranked_production_houses
WHERE prod_comp_rank <= 3;









/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since Bee Movies is based out of Mumbai, India also wants to woo its local audience.
Bee Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel.
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:



WITH indian_movies AS (
    SELECT m.id, r.avg_rating, r.total_votes
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    WHERE m.country = 'India' OR m.country LIKE 'India,%' OR m.country LIKE '%,India,%' OR m.country LIKE '%,India'
),

actor_movies AS (
    SELECT rm.name_id, im.id AS movie_id, im.avg_rating, im.total_votes
    FROM beemovies.role_mapping AS rm
    JOIN indian_movies AS im
    ON rm.movie_id = im.id
    WHERE rm.category = 'actor'
),

actor_stats AS (
    SELECT 
        am.name_id,
        COUNT(am.movie_id) AS movie_count,
        SUM(am.total_votes) AS total_votes,
        SUM(am.avg_rating * am.total_votes) / NULLIF(SUM(am.total_votes), 0) AS actor_avg_rating
    FROM actor_movies AS am
    GROUP BY am.name_id
    HAVING COUNT(am.movie_id) >= 5  -- Only actors with at least 5 movies
),

ranked_actors AS (
    SELECT 
        asx.name_id,
        asx.total_votes,
        asx.movie_count,
        asx.actor_avg_rating,
        RANK() OVER (ORDER BY asx.actor_avg_rating DESC, asx.total_votes DESC) AS actor_rank
    FROM actor_stats AS asx
)

SELECT n.name AS actor_name, ra.total_votes, ra.movie_count, 
       ROUND(ra.actor_avg_rating, 2) AS actor_avg_rating, ra.actor_rank
FROM ranked_actors AS ra
JOIN beemovies.names AS n
ON ra.name_id = n.id
WHERE ra.actor_rank = 1;  






-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings?
-- Note: The actresses should have acted in at least three Indian movies.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH hindi_movies AS (
    SELECT m.id, r.avg_rating, r.total_votes
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    WHERE (m.country = 'India' OR m.country LIKE 'India,%' OR m.country LIKE '%,India,%' OR m.country LIKE '%,India')
      AND (m.languages = 'Hindi' OR m.languages LIKE 'Hindi,%' OR m.languages LIKE '%,Hindi,%' OR m.languages LIKE '%,Hindi')
),

actress_movies AS (
    SELECT rm.name_id, hm.id AS movie_id, hm.avg_rating, hm.total_votes
    FROM beemovies.role_mapping AS rm
    JOIN hindi_movies AS hm
    ON rm.movie_id = hm.id
    WHERE rm.category = 'actress'
),

actress_stats AS (
    SELECT 
        am.name_id,
        COUNT(am.movie_id) AS movie_count,
        SUM(am.total_votes) AS total_votes,
        SUM(am.avg_rating * am.total_votes) / NULLIF(SUM(am.total_votes), 0) AS actress_avg_rating
    FROM actress_movies AS am
    GROUP BY am.name_id
    HAVING COUNT(am.movie_id) >= 3  
),

ranked_actresses AS (
    SELECT 
        asx.name_id,
        asx.total_votes,
        asx.movie_count,
        asx.actress_avg_rating,
        RANK() OVER (ORDER BY asx.actress_avg_rating DESC, asx.total_votes DESC) AS actress_rank
    FROM actress_stats AS asx
)

SELECT n.name AS actress_name, ra.total_votes, ra.movie_count, 
       ROUND(ra.actress_avg_rating, 2) AS actress_avg_rating, ra.actress_rank
FROM ranked_actresses AS ra
JOIN beemovies.names AS n
ON ra.name_id = n.id
WHERE ra.actress_rank <= 5  -- Get top 5 actresses
ORDER BY ra.actress_rank;








/* Taapsee Pannu tops with average rating 7.74.
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category:

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
    m.title AS movie_title,
    r.avg_rating,
    CASE 
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS movie_category
FROM beemovies.movie AS m
JOIN beemovies.genre AS g 
    ON m.id = g.movie_id
JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
WHERE g.genre = 'Thriller'
ORDER BY r.avg_rating DESC;







 
/* Until now, you have analysed various tables of the data set.
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration?
-- (Note: You need to show the output table in the question.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


WITH genre_avg_duration AS (
    SELECT 
        g.genre, 
        AVG(m.duration) AS avg_duration
    FROM beemovies.genre AS g
    JOIN beemovies.movie AS m 
        ON g.movie_id = m.id
    WHERE m.duration IS NOT NULL 
    GROUP BY g.genre
)
SELECT 
    genre, 
    avg_duration,
    SUM(avg_duration) OVER (ORDER BY genre) AS running_total_duration,
    AVG(avg_duration) OVER (ORDER BY genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM genre_avg_duration;







-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres?
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

-- #Top 3 genre
WITH top_3_genre AS (
    SELECT genre
    FROM beemovies.genre
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),
movies_belong_to_top_3_genre AS (
    SELECT 
        g.genre AS genre, 
        m.year AS year, 
        m.title AS title, 
        m.worlwide_gross_income AS worlwide_gross_income
    FROM beemovies.movie AS m
    JOIN beemovies.genre AS g
        ON m.id = g.movie_id
    WHERE g.genre IN (SELECT genre FROM top_3_genre)
),
top_5 AS (
    SELECT  
        genre, 
        year, 
        title AS movie_name, 
        worlwide_gross_income,
        ROW_NUMBER() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
    FROM movies_belong_to_top_3_genre 
)

-- Select only the top 5 movies per year without duplicates
SELECT genre, year, movie_name, worlwide_gross_income, movie_rank
FROM top_5
WHERE movie_rank <= 5
ORDER BY year, movie_rank;









-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH hit_movies AS (
    SELECT m.production_company
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    WHERE r.median_rating >= 8  
    AND m.languages LIKE '%,%' 
    AND m.production_company IS NOT NULL  
)

SELECT 
    production_company, 
    COUNT(*) AS movie_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_comp_rank
FROM hit_movies
GROUP BY production_company
ORDER BY prod_comp_rank
LIMIT 2;







-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH drama_superhit_movies AS (
    SELECT m.id, r.avg_rating, r.total_votes, g.genre
    FROM beemovies.movie AS m
    JOIN beemovies.ratings AS r 
    ON m.id = r.movie_id
    JOIN beemovies.genre as g
    ON m.id=g.movie_id
    WHERE r.avg_rating > 8 
    AND g.genre LIKE '%Drama%' 
),
actress_superhits AS (
   SELECT rm.name_id, COUNT(rsm.id) AS movie_count, SUM(rsm.total_votes) AS total_votes, 
           AVG(rsm.avg_rating) AS actress_avg_rating
    FROM beemovies.role_mapping AS rm
    JOIN drama_superhit_movies AS rsm 
    ON rm.movie_id = rsm.id
    WHERE rm.category = 'Actress'  
    GROUP BY rm.name_id
)

SELECT n.name AS actress_name, a.movie_count, a.total_votes, a.actress_avg_rating,
       RANK() OVER (ORDER BY a.movie_count DESC, a.actress_avg_rating DESC, a.total_votes DESC) AS actress_rank
FROM actress_superhits AS a
JOIN beemovies.names AS n 
ON a.name_id = n.id
ORDER BY actress_rank
LIMIT 3;




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH director_movies AS (
    SELECT dm.name_id AS director_id, 
           m.id AS movie_id, 
           m.date_published, 
           m.duration, 
           r.avg_rating, 
           r.total_votes
    FROM beemovies.director_mapping AS dm
    JOIN beemovies.movie AS m ON dm.movie_id = m.id
    JOIN beemovies.ratings AS r ON m.id = r.movie_id
    WHERE m.date_published IS NOT NULL
),

director_movie_intervals AS (
    SELECT director_id, movie_id, date_published, duration, avg_rating, total_votes,
           LAG(date_published) OVER (PARTITION BY director_id ORDER BY date_published) AS prev_movie_date
    FROM director_movies
),

director_stats AS (
    SELECT director_id, 
           COUNT(movie_id) AS number_of_movies,
           AVG(avg_rating) AS avg_rating,
           SUM(total_votes) AS total_votes,
           MIN(avg_rating) AS min_rating,
           MAX(avg_rating) AS max_rating,
           SUM(duration) AS total_duration,
           AVG(NULLIF(DATEDIFF(date_published, prev_movie_date), 0)) AS avg_inter_movie_days
    FROM director_movie_intervals
    GROUP BY director_id
)

SELECT ds.director_id, n.name AS director_name, ds.number_of_movies, 
       ROUND(ds.avg_inter_movie_days, 2) AS avg_inter_movie_days, 
       ROUND(ds.avg_rating, 2) AS avg_rating, 
       ds.total_votes, ds.min_rating, ds.max_rating, ds.total_duration
FROM director_stats AS ds
JOIN beemovies.names AS n ON ds.director_id = n.id
ORDER BY ds.number_of_movies DESC
LIMIT 9;





