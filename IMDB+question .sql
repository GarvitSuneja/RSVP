USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/
 
-- Segment 1:
/* Lets explore the tables firt SELECT * FROM genre; */

SELECT * FROM movie;
SELECT * FROM names;
SELECT * FROM ratings;
SELECT * FROM role_mapping;

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below: Answer_1

SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';

/* We can run the table one by one to get the total number of rows in the table, shared summary below:
director_mapping - 3867
genre - 14662
movie - 7997
names - 25735
ratings - 7997
role_mapping - 15615 */

-- Q2. Which columns in the movie table have null values?
-- Type your code below: Answer2

SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS ID,
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS TITLE,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS YEAR,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS DATE_PUBLISHED,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS DURATION,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS COUNTRY,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS WORLDWIDE_GROSS_INCOME,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS LANGUAGES,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS PRODUCTION_COMPANY
FROM   MOVIE; 

/*  After running the above query we found the four columns of Movie tables have null values which is mentioned below
column Country have 20 null rows, Worldwide_gross_income have 3724 null rows, Languages have 194 null rows and Production_company have 528 null rows */
 
-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected) Answer_3
/* Output format for the first part:
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	3052			|
|	2018		|	2944			|
|	2019		|	2011			|
+---------------+-------------------+
-- Output format for the second part of the question: --
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 804			|
|	2			|	 640			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT year as Year,
       Count(title) AS number_of_movies
FROM   MOVIE
GROUP  BY Year;
-- Most movie released in 2017 year - 3052 ----
-- ## Lets run the query for Month wise and observe the trends ---
SELECT Month(date_published) AS month_num,
       Count(id)             AS number_of_movies
FROM   MOVIE
GROUP  BY Month(date_published)
ORDER  BY Month(date_published);
## for Dec the Lowest numbers of moveis released while in March highest number of movie released

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT Count(DISTINCT id) AS number_of_movies,
       year
FROM   MOVIE
WHERE  ( country LIKE '%INDIA%'
          OR country LIKE '%USA%' )
       AND year = 2019; 
-- Like search was employed to accommodate movies that involve co-production across multiple countries, thereby ensuring their inclusion in the analysis.
/*-- We found that 1059 movies were produced in the INDIA or USA in year 2019 -- */

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below: Answer_5

SELECT DISTINCT genre AS Type_of_movies
FROM   GENRE;
/* We have identified 13 distinct categories of movies that were produced */

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below: Answer_6

SELECT     genre,
           Count(m.id) AS number_of_movies
FROM       movie       AS m
INNER JOIN genre       AS g
where      g.movie_id = m.id
GROUP BY   genre
ORDER BY   number_of_movies DESC limit 1; 

/* -- Our findings reveal that the Drama genre accounted for the majority of movies produced across the entire country.-- */

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below: Answer_7
WITH movies_under_one_genre
     AS (SELECT movie_id
         FROM   GENRE
         GROUP  BY movie_id
         HAVING Count(DISTINCT genre) = 1)
SELECT Count(*) AS movies_under_one_genre
FROM   movies_under_one_genre; 

/*-- We found Total 3289 movie created under one type of Genre -- */

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.) Answer_8
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   GENRE AS g
       INNER JOIN MOVIE AS m
               ON g.movie_id = m.id
GROUP  BY genre
ORDER  BY Avg(duration) DESC;

/* -- The Action genre boasts the longest duration, with an average of 112.88 seconds,
 closely followed by the Romance and Crime genres.-- */

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function) Answer_9

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_rank
     AS (SELECT genre,
                Count(movie_id)                    AS movie_count,
                Rank()
                  OVER (
                    ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   GENRE
         GROUP  BY genre)
SELECT *
FROM   genre_rank
WHERE  genre = 'THRILLER';

/* -- Data indicates that the Thriller genre holds the third position worldwide in terms of ranking. ---*/

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
-- Type your code below: Answer_10

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   RATINGS;

/*-- In our analysis of the rating table, we have successfully determined the minimum and maximum values for each column
The ratings are based on a scale of 1 to 10 for the respective movies, 
and we can confirm that there are no outliers present in the data.--*/
 
 
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
-- Type your code below: Answer_11
-- It's ok if RANK() or DENSE_RANK() is used too

WITH movie_rank
     AS (SELECT title,
                avg_rating,
                Row_number()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank
         FROM   RATINGS AS r
                INNER JOIN MOVIE AS m
                        ON m.id = r.movie_id)
SELECT *
FROM   movie_rank
WHERE  movie_rank <= 10; 

/*-- Among the Top 10 movies, we observed that two of them have received a perfect rating of 10. --*/

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
-- Type your code below: Answer_12
-- Order by is good to have
SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   RATINGS
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

/* --Data indicates that the majority of movies received a rating of 7 as the maximum score.-- */

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below: Answer_13

SELECT production_company,
       Count(id)                    AS movie_count,
       Dense_rank()
         OVER(
           ORDER BY Count(id) DESC) AS prod_company_rank
FROM   MOVIE AS m
       INNER JOIN RATINGS AS r
               ON m.id = r.movie_id
WHERE  avg_rating > 8
       AND production_company IS NOT NULL
GROUP  BY production_company
ORDER  BY movie_count DESC;

/* --Dream Warrior Pictures and National Theatre Live production houses have produced the highest number of hit movies, 
where the average rating of these movies is greater than 8.--*/

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
-- Type your code below: Answer_14

SELECT g.genre,
       Count(g.movie_id) AS movie_count
FROM   GENRE AS g
       INNER JOIN RATINGS AS r
               ON g.movie_id = r.movie_id
       INNER JOIN MOVIE AS m
               ON m.id = g.movie_id
WHERE  m.country LIKE '%USA%'
       AND r.total_votes > 1000
       AND Month(date_published) = 3
       AND year = 2017
GROUP  BY g.genre
ORDER  BY movie_count DESC; 

/*-- It appears that during March 2017 in the USA, a total of 24 drama movies were released, reaffirming the fact that the drama genre remained the preferred choice for filmmakers.--*/

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
-- Type your code below: Answer_15
SELECT title,
       avg_rating,
       genre
FROM   GENRE AS g
       INNER JOIN RATINGS AS r
               ON g.movie_id = r.movie_id
       INNER JOIN MOVIE AS m
               ON m.id = g.movie_id
WHERE  title LIKE 'The%'
       AND avg_rating > 8
ORDER  BY avg_rating DESC; 



/*-- We search in each genre and found all the movies which start with the word 'THE'.
 We discovered 8 unique movie titles that were associated with multiple genres.-- */ 

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below: Answer_16
SELECT Count(movie_id) AS movies_count
FROM   MOVIE AS m
       INNER JOIN RATINGS AS r
               ON m.id = r.movie_id
WHERE  median_rating = 8
       AND date_published BETWEEN "2018-04-01" AND "2019-04-01";

/* We found 361 movies which get median rating 8 in the given duration of period (1st April 2018 to 1st April 2019)-- */

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below: Answer_17

SELECT country as Country,
       Sum(total_votes) AS Total_No_of_votes
FROM   MOVIE AS m
       INNER JOIN RATINGS AS r
               ON m.id = r.movie_id
WHERE  country IN ( 'Germany', 'Italy' )
GROUP  BY country; 

/*-- We found that the Yes, The Germany gets more votes in compare to the Italy
Even average votes of Germany are higher than Italy -- */

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
-- Type your code below: Answer_18
SELECT Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   NAMES; 

/* Our findings in the Names table indicate that out of the 4 columns, three columns have null values. 
Specifically, the number of null values for each column is as follows:

height_nulls: 17,335
date_of_birth_nulls: 13,431
known_for_movies_nulls: 15,226 -- */

/* There are no Null value in the column 'name' - YES.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

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
-- Type your code below: Answer_19
WITH top_genre AS
(
           SELECT     g.genre,
                      Count(g.movie_id) AS movie_count
           FROM       genre             AS g
           INNER JOIN ratings           AS r
           ON         g.movie_id = r.movie_id
           WHERE      avg_rating > 8
           GROUP BY   genre
           ORDER BY   movie_count DESC limit 3 ), top_director AS
(
           SELECT     n.NAME                                             AS director_name,
                      Count(g.movie_id)                                  AS movie_count,
                      Row_number() OVER(ORDER BY Count(g.movie_id) DESC) AS director_row_rank
           FROM       names                                              AS n
           INNER JOIN director_mapping                                   AS dm
           ON         n.id = dm.name_id
           INNER JOIN genre AS g
           ON         dm.movie_id = g.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = g.movie_id,
                      top_genre
           WHERE      g.genre IN (top_genre.genre)
           AND        avg_rating>8
           GROUP BY   director_name
           ORDER BY   movie_count DESC )
SELECT director_name , movie_count
FROM   top_director
WHERE  director_row_rank <= 3 limit 3;


/* James Mangold, Joe Russo, and 'Soubin Shahir' 
emerge as the foremost three directors across the top three genres,
 with their movies attaining an average rating exceeding 8.-- */

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below: Answer_20
WITH top_actors AS
(
           SELECT     NAME              AS actor_name,
                      Count(r.movie_id) AS movie_count
           FROM       ratings           AS r
           INNER JOIN role_mapping      AS rm
           ON         rm.movie_id = r.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           WHERE      median_rating >= 8
           AND        category = 'actor'
           GROUP BY   NAME
           ORDER BY   movie_count DESC limit 2 )
SELECT actor_name,
       movie_count
FROM   top_actors;

/* We identified two top actors whose movies garnered ratings of 8 or higher.
 Mammooty leads the pack with 8 movies meeting this criterion,
 closely followed by Mohanlal with 5 such movies.-- */


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
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
-- Type your code below: Answer_21
SELECT     production_company,
           Sum(total_votes)                                  AS vote_count,
           Dense_rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM       movie                                             AS m
INNER JOIN ratings                                           AS r
ON         m.id = r.movie_id
GROUP BY   production_company limit 3;

/*-- According to the data, the top three production houses, ranked based on the number of votes received by their movies,
 are Marvel Studios, Twentieth Century Fox, and Warner Bros.-- */


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
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
-- Type your code below: Answer_22
WITH actor_data AS
(
           SELECT     NAME                                             AS actor_name,
                      Sum(total_votes)                                 AS total_votes,
                      Count(m.id)                                      AS movie_count,
                      Sum(avg_rating * total_votes) / Sum(total_votes) AS actor_avg_rating
           FROM       movie                                            AS m
           INNER JOIN ratings                                          AS r
           ON         m.id = r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS nm
           ON         rm.name_id = nm.id
           WHERE      category = 'actor'
           AND        country = 'india'
           GROUP BY   NAME
           HAVING     Count(m.id) >= 5 )
SELECT   actor_name,
         total_votes,
         movie_count,
         Round(actor_avg_rating, 2)                  AS actor_avg_rating,
         Rank() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
FROM     actor_data
ORDER BY actor_rank limit 5;

/* As per the required expectation we found superstar Vijay Sethupathi best fit for RSVP movies next project-- */

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
-- Type your code below: Answer_23
WITH actress_data AS
(
           SELECT     NAME                                             AS actress_name,
                      Sum(total_votes)                                 AS total_votes,
                      Count(m.id)                                      AS movie_count,
                      Sum(avg_rating * total_votes) / Sum(total_votes) AS actress_avg_rating
           FROM       movie                                            AS m
           INNER JOIN ratings                                          AS r
           ON         m.id = r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS nm
           ON         rm.name_id = nm.id
           WHERE      category = 'actress'
           AND        country = 'india'
           AND        languages = 'hindi'
           GROUP BY   NAME
           HAVING     Count(m.id) >= 3 )
SELECT   actress_name,
         total_votes,
         movie_count,
         Round(actress_avg_rating, 2)                   AS actress_avg_rating,
         Rank() OVER (ORDER BY actress_avg_rating DESC) AS actress_rank
FROM     actress_data
ORDER BY actress_rank limit 5;

/* We found out of 4 actress Taapsee Pannu with 18061 votes can be choosen against vijay Sethupathi for next RSVP movies production movie-- */


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below: Answer_24
WITH thriller_movies
     AS (SELECT title,
                avg_rating
         FROM   GENRE AS g
                INNER JOIN MOVIE AS m
                        ON g.movie_id = m.id
                INNER JOIN RATINGS AS r
                        ON m.id = r.movie_id
         WHERE  genre = 'thriller')
SELECT title,
       ( CASE
           WHEN avg_rating >= 8 THEN 'Superhit movie'
           WHEN avg_rating >= 7
                AND avg_rating < 8 THEN 'Hit movie'
           WHEN avg_rating >= 5.0
                AND avg_rating < 7 THEN 'One-time-watch movie'
           WHEN avg_rating < 5.0 THEN 'Flop movie'
         END ) AS Class
FROM   thriller_movies
ORDER  BY title; 

/* We have found the raiting wise triller movies segregated them in the suggested category-- */


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
-- Type your code below: Answer_25
SELECT genre,
       Round(Avg(duration), 2)                      AS avg_duration,
       SUM(Round(Avg(duration), 2))
         over(
           ORDER BY genre ROWS unbounded preceding) AS running_total_duration,
       Avg(Round(Avg(duration), 2))
         over(
           ORDER BY genre ROWS 10 preceding)        AS moving_avg_duration
FROM   MOVIE AS m
       inner join GENRE AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY genre; 

/*-- We have listed the genre on the basis of ther average duration and total duration-- */

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
-- Type your code below: Answer_26
WITH top_genres AS
(
           SELECT     genre,
                      Count(m.id)                            AS movie_count,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                  AS m
           INNER JOIN genre                                  AS g
           ON         g.movie_id = m.id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre
           ORDER BY   movie_count DESC limit 3 ), movie_summary AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      worlwide_gross_income,
                      Dense_rank() OVER (partition BY year ORDER BY Cast(Replace(Replace(Ifnull(worlwide_gross_income, '0'), 'INR', ''), '$', '') AS Decimal(10)) DESC) AS movie_rank
           FROM       movie                                                                                                                                             AS m
           INNER JOIN genre                                                                                                                                             AS g
           ON         m.id = g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_genres) )
SELECT   *
FROM     movie_summary
WHERE    movie_rank <= 5
ORDER BY year, genre;

-- Top 3 Genres based on most number of movies
## Top 3 Genre with most number of movies are 1.Action  2. Darma 3. Comedy 

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
-- Type your code below: Answer_27

SELECT     production_company,
           Count(m.id)                                  AS movie_count,
           Row_number() OVER(ORDER BY Count(m.id) DESC) AS prod_comp_rank
FROM       movie                                        AS m
INNER JOIN ratings                                      AS r
ON         m.id = r.movie_id
WHERE      median_rating >= 8
AND        production_company IS NOT NULL
AND        position(',' IN languages) > 0
GROUP BY   production_company
ORDER BY   prod_comp_rank limit 2;

/* --We found top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies are 
First, Star Cinema with 7 movies and second, is Twentieth Century Fox with 4 movies-- */

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic - taken care
-- If there is a comma, that means the movie is of more than one language - taken care

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below: Answer_28
WITH ranking AS
(
           SELECT     NAME                                                  AS actress_name,
                      Sum(total_votes)                                      AS total_votes,
                      Count(m.id)                                           AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating,
                      Rank() OVER(ORDER BY Count(m.id) DESC)                AS actress_rank
           FROM       genre                                                 AS g
           INNER JOIN movie                                                 AS m
           ON         g.movie_id= m.id
           INNER JOIN ratings AS r
           ON         m.id= r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id=rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id=n.id
           WHERE      genre= 'drama'
           AND        category= 'actress'
           AND        avg_rating>8
           GROUP BY   NAME)
SELECT *
FROM   ranking limit 3;

/* --We found the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre are 
1. Parvathy Thiruvothu
2. Susan Brown
3. Amanda Lawrence--*/

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
-- Type you code below: Answer_29
WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published, 1) OVER(partition BY d.name_id ORDER BY date_published, movie_id) AS next_date_published
           FROM       director_mapping                                                                       AS d
           INNER JOIN names                                                                                  AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                        AS director_id,
         NAME                           AS director_name,
         Count(movie_id)                AS number_of_movies,
         Round(Avg(date_difference), 2) AS avg_inter_movie_days,
         Round(Avg(avg_rating), 2)      AS avg_rating,
         Sum(total_votes)               AS total_votes,
         Min(avg_rating)                AS min_rating,
         Max(avg_rating)                AS max_rating,
         Sum(duration)                  AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY number_of_movies DESC limit 9;

/* -- We have listed the Director's information as per requested detials format-- */






