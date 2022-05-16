
---- Project: DATA CLEANING IN SQL ---------------------------------------------------
---- Description: In this project we clean the TMDB movies dataset in SQL Server. ----
---- Task 2 is performed with this script: Cleaning the "credits" table. -------------
---- Note: The functions and commands are consistent with PostGreSQL environment. ----
--------------------------------------------------------------------------------------

-- 1) Let's look at the "credits" table.
	SELECT *
	FROM credits	

-- 2) Let's extract the main actor & their gender, and store them in columns "actor" and "gender".
	ALTER TABLE credits
	ADD COLUMN actor TEXT, ADD COLUMN gender VARCHAR(1);

	UPDATE credits
	SET actor = SUBSTRING("cast", STRPOS("cast",'"name"')+9, STRPOS("cast",'"order"')-STRPOS("cast",'"name"')-12)
	WHERE "cast" LIKE '%"character"%'

	UPDATE credits
	SET actor = NULL
	WHERE "cast" NOT LIKE '%"character"%'

	UPDATE credits
	SET gender = SUBSTRING("cast", STRPOS("cast",'"gender"')+10, 1)
	WHERE "cast" LIKE '%"character"%'

	UPDATE credits
	SET gender = NULL
	WHERE actor IS NULL

-- 3) Let's drop the old columns "cast" and "crew".
	ALTER TABLE credits
	DROP COLUMN "cast", DROP COLUMN crew;

-- 4) Let's delete the rows with "actor" value as NULL.
	DELETE FROM credits
	WHERE actor IS NULL

-- 5) Let's change the data type of "movie_id" column from TEXT to INT.
	ALTER TABLE credits
	ALTER COLUMN movie_id TYPE INT USING movie_id::integer

-- 6) Let's create new column "gender_" and store the values as
--    Female, Male, or NULL according to the 1, 2, or NULL values in "gender" column.
--    Let's also drop the "gender" column afterwards.
	ALTER TABLE credits
	ADD COLUMN gender_ VARCHAR(6)

	UPDATE credits
	SET gender_ = 'Female' WHERE gender = '1'

	UPDATE credits
	SET gender_ = 'Male' WHERE gender = '2'

	UPDATE credits
	SET gender_ = NULL WHERE gender NOT IN ('1','2')

	ALTER TABLE credits
	DROP COLUMN gender
	
-- 7) Let's take a final look at the "credits" table.
	SELECT *
	FROM credits