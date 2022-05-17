
---- Project: DATA CLEANING IN SQL ---------------------------------------------------
---- Description: In this project we clean the TMDB movies dataset in SQL Server. ----
---- Task 1 is performed with this script: Cleaning the "movies" table. --------------
---- Note: "id" column in the "movies" source data has been moved to first place. ----
---- Note: The functions and commands are consistent with Microsoft SQL Server. ------
--------------------------------------------------------------------------------------

-- 1) Let's look at the "movies" table.
	SELECT *
	FROM movies

-- 2) Let's look at the table sorted by the "id" column to find any discrepancies.
	SELECT *
	FROM movies
	ORDER BY id
	-- Observations: There are some missing "id" entries.

-- 3) Let's focus on the "movies" table and try to clean it for further use.
	SELECT id, original_title, title FROM movies
	WHERE original_title <> title
	-- Let's drop the original_title column, as it has special characters and we already have title column.
	ALTER TABLE movies
	DROP COLUMN original_title

-- 4) Let's look at the "status" column. There are no NULL values but almost all the entries are "Released".
	SELECT status, COUNT(status)
	FROM movies
	GROUP BY status

-- 5) Let's drop the keywords column as we do not intend to use it further.
	ALTER TABLE movies
	DROP COLUMN keywords

-- 6) Let's change the homepage column to a Yes/No column according to if the movie has a homepage or not.
	ALTER TABLE movies
	ADD homepage_ VARCHAR(3);

	UPDATE movies
	SET homepage_ = 'Yes'
	WHERE homepage IS NOT NULL

	UPDATE movies
	SET homepage_ = 'No'
	WHERE homepage IS NULL

	ALTER TABLE movies
	DROP COLUMN homepage

-- 7) Let's extract the most prominent values in JSON populated columns
--    "genres", "production_companies", and "production_countries",
--    and store those values in the new columns
--    "genre", "company", and "country".
--    We'll also convert the values in "original_language" column
--    to upper-case and store them in new "language" column.
	ALTER TABLE movies
	ADD genre TEXT, company TEXT, country TEXT, language TEXT;

	UPDATE movies
	SET genre = NULL
	WHERE genres = '[]'

	UPDATE movies
	SET genre = SUBSTRING(genres, CHARINDEX('e":',genres)+5, CHARINDEX('}',genres)-CHARINDEX('e":',genres)-6)
	WHERE genres <> '[]'

	UPDATE movies
	SET company = NULL
	WHERE production_companies = '[]'

	UPDATE movies
	SET company = SUBSTRING(production_companies, CHARINDEX('e":',production_companies)+5, CHARINDEX(',',production_companies)-CHARINDEX('e":',production_companies)-6)
	WHERE production_companies <> '[]'

	UPDATE movies
	SET country = NULL
	WHERE production_countries = '[]'

	UPDATE movies
	SET country = SUBSTRING(production_countries, CHARINDEX('e":',production_countries)+5, CHARINDEX('}',production_countries)-CHARINDEX('e":',production_countries)-6)
	WHERE production_countries <> '[]'

	UPDATE movies
	SET language = UPPER(original_language)

-- 8) Let's drop the old columns 
--    "genres", "production_companies", "production_countries", "spoken_languages", and "original_language".
	ALTER TABLE movies
	DROP COLUMN genres, original_language, production_companies, production_countries, spoken_languages

-- 9) Let's change the "release_date" type from DATETIME to DATE and store the values in new column "release_dt".
	ALTER TABLE movies
	ADD release_dt DATE

	UPDATE movies
	SET release_dt = CONVERT(DATE, release_date)

-- 10) Let's extract year, month, and date information from "release_dt" column,
--     and store the values in newly created "year_", "month_", and "date_" columns.
	ALTER TABLE movies
	ADD year_ int, month_ int, date_ int

	UPDATE movies
	SET year_ = YEAR(release_dt)

	UPDATE movies
	SET month_ = MONTH(release_dt)

	UPDATE movies
	SET date_ = DAY(release_dt)

	ALTER TABLE movies
	DROP COLUMN release_date

-- 11) Let's delete entries with no "id" (zero such entries are present.) 
	DELETE FROM movies
	WHERE id IS NULL
	
-- 12) Let's take a final look at the "movies" table.
	SELECT *
	FROM movies