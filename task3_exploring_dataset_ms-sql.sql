
---- Project: DATA CLEANING IN SQL ---------------------------------------------------
---- Description: In this project we clean the TMDB movies dataset in SQL Server. ----
---- Task 3 is performed with this script: Exploring the cleaned dataset. ------------
---- Note: The functions and commands are consistent with Microsoft SQL Server. ------
--------------------------------------------------------------------------------------

-- 1) Let's look at the "movies" table sorted by "id" column.
	SELECT * FROM movies
	ORDER BY id

-- 2) Top-5 Highest Grossing Movies:
	SELECT TOP 5 title, year_, revenue FROM movies
	ORDER BY revenue DESC

-- 3) Top-5 Highest Rated Movies (with atleast 50 votes):
	SELECT TOP 5 title, year_, vote_average, vote_count FROM movies
	WHERE vote_count >= 50
	ORDER BY vote_average DESC

-- 4) Top-5 Movies with Highest Profit Percentages (with a minimum budget of 1000 USD):
	SELECT TOP 5 title, year_, budget, revenue, ROUND((revenue/budget*100-100),0) AS ProfitPercentage FROM movies
	WHERE budget >= 1000
	ORDER BY ProfitPercentage DESC

-- 5) Top-5 Most Popular Genres (out of 20 genres):
	ALTER TABLE movies
	ALTER COLUMN genre NVARCHAR(100)

	SELECT TOP 5 genre, COUNT(genre) AS num_movies
	FROM movies
	GROUP BY genre
	ORDER BY num_movies DESC

-- 6) Top-5 Countries with most movies (out of 70 countries):
	ALTER TABLE movies
	ALTER COLUMN country NVARCHAR(100)

	SELECT TOP 5 country, COUNT(country) AS num_movies
	FROM movies
	GROUP BY country
	ORDER BY num_movies DESC

-- 7) Top-5 Companies with most movies (out of 1310 companies):
	ALTER TABLE movies
	ALTER COLUMN company NVARCHAR(100)

	SELECT TOP 5 company, COUNT(company) AS num_movies
	FROM movies
	GROUP BY company
	ORDER BY num_movies DESC

--------------------------------------------------------------------------------------

-- 8) Let's look at the "credits" table sorted by "movie_id" column.
	SELECT * FROM credits
	ORDER BY movie_id

-- 9) Top-5 Actors with Most Movies:
	ALTER TABLE credits
	ALTER COLUMN actor NVARCHAR(100)

	SELECT TOP 5 actor, COUNT(actor) AS num_movies
	FROM credits
	GROUP BY actor
	ORDER BY num_movies DESC
	
-- 10) Actor Gender distribution:
	SELECT gender_, COUNT(gender_) AS num_movies
	FROM credits
	GROUP BY gender_
	ORDER BY num_movies DESC

--------------------------------------------------------------------------------------

-- 11) Let's join both the tables to bring the "actor" column in from "credits" table.
	SELECT movies.id, movies.title, year_, actor, movies.revenue FROM movies
	INNER JOIN credits
	ON movies.id = credits.movie_id
	ORDER BY movies.id

-- 12) Top-5 Actors with Highest Total Revenue:
--     (we use the output in subtask 11 as Common Table Expression (CTE)).
	WITH ActRevenue (id, title, year_, actor, revenue) AS
	(
	SELECT movies.id, movies.title, year_, actor, movies.revenue FROM movies
	INNER JOIN credits
	ON movies.id = credits.movie_id
	)
	SELECT TOP 5 actor, SUM(revenue) AS total_revenue FROM ActRevenue
	GROUP BY actor
	ORDER BY total_revenue DESC
	
-- 13) Top-5 Actors with Highest Vote Average (with a minimum of 10 movies):
	WITH ActRating (id, title, actor, vote_average, vote_count, vote_aggregate) AS
	(
	SELECT movies.id, movies.title, actor, movies.vote_average, movies.vote_count,
	(movies.vote_average*movies.vote_count) AS vote_aggregate
	FROM movies
	INNER JOIN credits
	ON movies.id = credits.movie_id
	)
	SELECT TOP 5 actor, SUM(vote_aggregate)/SUM(vote_count) AS actor_vote_avg FROM ActRating
	GROUP BY actor
	HAVING SUM(vote_count) > 0 AND COUNT(vote_count) >= 10
	ORDER BY actor_vote_avg DESC

-- 14) Top-5 Studios with Highest Vote Average (with a minimum of 10 movies):
	SELECT TOP 5 company, SUM(vote_average*vote_count)/SUM(vote_count) AS studio_vote_avg FROM movies
	GROUP BY company
	HAVING SUM(vote_count) > 0 AND COUNT(vote_count) >= 10
	ORDER BY studio_vote_avg DESC