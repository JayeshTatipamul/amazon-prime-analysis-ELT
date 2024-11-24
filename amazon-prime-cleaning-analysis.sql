#----amazon_prime_data-extract_analysis

create database JayeshT_projects;

use JayeshT_projects;

#------Checking tables in DB
show tables;

#----Checking total rows
select count(*) from amazon_prime_raw;

#-----Checking table DDL
desc amazon_prime_raw;

#----Checking Data
select * from amazon_prime_raw 
where show_id='s5023';
#order by title;

#----Dropping table for adjusting datatype
drop table amazon_prime_raw;

create TABLE JayeshT_projects.amazon_prime_raw(
	show_id varchar(10) primary key,
	type varchar(10) NULL,
	title varchar(200) NULL,
	director text NULL,
	cast text NULL,
	country varchar(150) NULL,
	date_added varchar(20) NULL,
	release_year int NULL,
	rating varchar(10) NULL,
	duration varchar(10) NULL,
	listed_in varchar(100) NULL,
	description varchar(500) NULL
); 

select count(*) from amazon_prime_raw;

#------Checking datatype
SHOW COLUMNS FROM amazon_prime_raw LIKE 'description';

#----Changing Datatype from varchar to text
ALTER TABLE amazon_prime_raw MODIFY description TEXT;

#--handling foreign characters
#-------Done

#--remove duplicates : No duplicates for show id column
select show_id,COUNT(*) 
from amazon_prime_raw
group by show_id 
having COUNT(*)>1;


#--remove duplicates : for title column
select * from amazon_prime_raw
where concat(upper(title),type)  in (
select concat(upper(title),type) 
from amazon_prime_raw
group by upper(title) ,type
having COUNT(*)>1
)
order by title;

drop table amazon_prime;

#-----Query for distinct values
create table amazon_prime (
	show_id varchar(10) primary key,
	type varchar(10) NULL,
	title varchar(200) NULL,
	date_added varchar(20) NULL,
	release_year int NULL,
	rating varchar(10) NULL,
	duration varchar(10) NULL,
	description varchar(500) NULL
); 

Insert into amazon_prime
with cte as (
select * ,
ROW_NUMBER() over (partition by title , type order by show_id) as rn
from amazon_prime_raw)
select show_id, type, title, STR_TO_DATE(CONCAT(release_year, '-12-31'), '%Y-%m-%d') date_added, release_year,
rating, case when duration is null then rating else duration end as duration, description
from cte;

SHOW COLUMNS FROM amazon_prime LIKE 'description';

ALTER TABLE amazon_prime MODIFY description TEXT;



drop table amazon_prime_director;

#-- Create the new table to store the results for director
CREATE TABLE amazon_prime_director (
    show_id varchar(10),
    director VARCHAR(255)
);

#-- Insert the split values into the new table
INSERT INTO amazon_prime_director (show_id, director)
SELECT 
    show_id, TRIM(director)
from (
WITH RECURSIVE SplitDirector AS (
    SELECT 
        show_id,
        director AS director,
        NULL AS remaining_director
    FROM amazon_prime_raw
    WHERE director NOT LIKE '%,%' AND director IS NOT NULL
    UNION ALL
    SELECT 
        show_id,
        SUBSTRING_INDEX(director, ',', 1) AS director,
        SUBSTRING(director, INSTR(director, ',') + 1) AS remaining_director
    FROM amazon_prime_raw
    WHERE director LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining_director, ',', 1),
        SUBSTRING(remaining_director, INSTR(remaining_director, ',') + 1)
    FROM SplitDirector
    WHERE remaining_director LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        remaining_director AS director,
        NULL AS remaining_director
    FROM SplitDirector
    WHERE remaining_director NOT LIKE '%,%' AND remaining_director IS NOT NULL)
SELECT 
show_id, TRIM(director) AS director
FROM SplitDirector) as DerivedTable;

ALTER TABLE amazon_prime_director MODIFY COLUMN director text;


UPDATE amazon_prime_raw
SET director = TRIM(director)
WHERE director IS NOT NULL;

#-----Check Total Rows with NULL or Empty Directors
SELECT COUNT(*)
FROM amazon_prime_raw
WHERE director IS NULL OR director = '';

#---Verify Rows Without Commas
SELECT COUNT(*)
FROM amazon_prime_raw
WHERE director NOT LIKE '%,%' AND director IS NOT NULL;

select count(director) from amazon_prime_raw;

ALTER TABLE amazon_prime_director MODIFY COLUMN show_id VARCHAR(255);

select * from amazon_prime_director order by show_id asc;

select show_id, director from amazon_prime_director
where show_id in ('s6931','s7128');

select show_id, director from amazon_prime_raw
where show_id in ('s1019','s1045'); 


drop table amazon_prime_genre;
#-- Create the new table to store the results for listed in
CREATE TABLE amazon_prime_genre (
    show_id VARCHAR(10),
    listed_in VARCHAR(255)
);

#-- Insert the split values into the new table 
INSERT INTO amazon_prime_genre (show_id, listed_in)
SELECT 
    show_id, TRIM(listed_in)
from (
WITH RECURSIVE Splitlisted_in AS (
    SELECT 
        show_id,
        listed_in AS listed_in,
        NULL AS remaining_listed_in
    FROM amazon_prime_raw
    WHERE listed_in NOT LIKE '%,%' AND listed_in IS NOT NULL
    UNION ALL
    SELECT 
        show_id,
        SUBSTRING_INDEX(listed_in, ',', 1) AS listed_in,
        SUBSTRING(listed_in, INSTR(listed_in, ',') + 1) AS remaining_listed_in
    FROM amazon_prime_raw
    WHERE listed_in LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining_listed_in, ',', 1),
        SUBSTRING(remaining_listed_in, INSTR(remaining_listed_in, ',') + 1)
    FROM Splitlisted_in
    WHERE remaining_listed_in LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        remaining_listed_in AS listed_in,
        NULL AS remaining_listed_in
    FROM Splitlisted_in
    WHERE remaining_listed_in NOT LIKE '%,%' AND remaining_listed_in IS NOT NULL)
SELECT 
show_id, TRIM(listed_in) AS listed_in
FROM Splitlisted_in) as DerivedTable;

select count(distinct show_id) from amazon_prime_genre;

drop table amazon_prime_listed_in;

drop table amazon_prime_country;
#-- Create the new table to store the results for country
CREATE TABLE amazon_prime_country (
    show_id VARCHAR(10),
    country VARCHAR(255));

#-- Insert the split values into the new table 
INSERT INTO amazon_prime_country (show_id, country)
SELECT 
    show_id, TRIM(country)
from (
WITH RECURSIVE Splitcountry AS (
    SELECT 
        show_id,
        country AS country,
        NULL AS remaining_country
    FROM amazon_prime_raw
    WHERE country NOT LIKE '%,%' AND country IS NOT NULL
    UNION ALL
    SELECT 
        show_id,
        SUBSTRING_INDEX(country, ',', 1) AS country,
        SUBSTRING(country, INSTR(country, ',') + 1) AS remaining_country
    FROM amazon_prime_raw
    WHERE country LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining_country, ',', 1),
        SUBSTRING(remaining_country, INSTR(remaining_country, ',') + 1)
    FROM Splitcountry
    WHERE remaining_country LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        remaining_country AS country,
        NULL AS remaining_country
    FROM Splitcountry
    WHERE remaining_country NOT LIKE '%,%' AND remaining_country IS NOT NULL)
SELECT 
show_id, TRIM(country) AS country
FROM Splitcountry) as DerivedTable;

#----Checking data for country
select count(*) from amazon_prime_country;

#----Checking count of country in raw table
select count(country) from amazon_prime_raw
where country is not null;

drop table amazon_prime_cast;

#-- Create the new table to store the results for cast
CREATE TABLE amazon_prime_cast (
    show_id VARCHAR(10),
    cast VARCHAR(255));

#-- Insert the split values into the new table 
INSERT INTO amazon_prime_cast (show_id, cast)
SELECT 
    show_id, TRIM(cast)
from (
WITH RECURSIVE Splitcast AS (
    SELECT 
        show_id,
        cast AS cast,
        NULL AS remaining_cast
    FROM amazon_prime_raw
    WHERE cast NOT LIKE '%,%' AND cast IS NOT NULL
    UNION ALL
    SELECT 
        show_id,
        SUBSTRING_INDEX(cast, ',', 1) AS cast,
        SUBSTRING(cast, INSTR(cast, ',') + 1) AS remaining_cast
    FROM amazon_prime_raw
    WHERE cast LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        SUBSTRING_INDEX(remaining_cast, ',', 1),
        SUBSTRING(remaining_cast, INSTR(remaining_cast, ',') + 1)
    FROM Splitcast
    WHERE remaining_cast LIKE '%,%'
    UNION ALL
    SELECT
        show_id,
        remaining_cast AS cast,
        NULL AS remaining_cast
    FROM Splitcast
    WHERE remaining_cast NOT LIKE '%,%' AND remaining_cast IS NOT NULL)
SELECT 
show_id, TRIM(cast) AS cast
FROM Splitcast) as DerivedTable;

#-----Checking count 
select count(*) from amazon_prime_cast
order by show_id;

select cast from amazon_prime_raw;

#-----Checking tables created
show tables;

#--data type conversions for date added 

#--populate missing values in country,duration columns
insert into amazon_prime_country
select  show_id, m.country 
from amazon_prime_raw apr
inner join (
select director,country
from  amazon_prime_country apc
inner join amazon_prime_director apd on apc.show_id=apd.show_id
group by director,country
) m on apr.director=m.director
where apr.country is null;

select director,country
from  amazon_prime_country apc
inner join amazon_prime_director apd on apc.show_id=apd.show_id
group by director,country;

select count(*) from amazon_prime_country;

select * from amazon_prime_raw where duration is null;

select * from amazon_prime;

#-----Updataing director to Smith Jack where values is 1
update amazon_prime_raw
SET director='Smith Jack'
where director=1;

select * from amazon_prime_raw;

#-----Amazon-Prime---Data--Analysis
/*1  Top 10 directors excluding unknown who have contributed to movies */
    SELECT 
    apd.director,
    COUNT(CASE WHEN ap.type = 'Movie' THEN ap.show_id END) AS no_of_movies
FROM amazon_prime ap
INNER JOIN amazon_prime_director apd 
    ON ap.show_id = apd.show_id
GROUP BY apd.director
HAVING director!='Unknown'
ORDER BY no_of_movies 
DESC limit 10;


#---Changing data type
ALTER TABLE amazon_prime_genre
CHANGE COLUMN listed_in genre VARCHAR(255);


#--2 which country has highest number of comedy movies 
select apc.country , COUNT(distinct apg.show_id ) as no_of_movies
from amazon_prime_genre apg
inner join amazon_prime_country apc on apg.show_id=apc.show_id
inner join amazon_prime ap on apg.show_id=apc.show_id
where apg.genre='Comedy' and ap.type='Movie'
group by  apc.country
order by no_of_movies desc
limit 1;

select * from amazon_prime;

#-----date_added derived from release year column
#----3 for each year (as per date added to amazon_prime), which director has maximum number of movies released
with cte as (
select apd.director,YEAR(date_added) as date_year,count(ap.show_id) as no_of_movies
from amazon_prime ap
inner join amazon_prime_director apd on ap.show_id=apd.show_id
where type='Movie'
group by apd.director,YEAR(date_added)
)
, cte2 as (
select *
, ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director) as rn
from cte)
select * from cte2 where rn=1;


#----Checking data in duration column
select distinct duration from amazon_prime
where duration like '%seasons';

/*Decide on a Standard Conversion Rate
For example:
Assume 1 season = 10 episodes, and each episode lasts 30 minutes.
Therefore, 1 season ≈ 300 minutes.
*/

ALTER TABLE amazon_prime ADD COLUMN total_duration_minutes INT;

#----Update the new column;
UPDATE amazon_prime
SET total_duration_minutes = 
    CASE
        WHEN duration LIKE '%min%' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)  -- Movies
        WHEN duration LIKE '%Season%' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) * 300  -- TV Shows (1 season = 300 minutes)
        ELSE NULL  -- For unknown or null durations
    END;


select * from amazon_prime;
select distinct genre from amazon_prime_genre;

#--4 what is average duration of movies in each genre
select apg.genre, round(avg(total_duration_minutes),0) as avg_duration
from amazon_prime ap
inner join amazon_prime_genre apg on ap.show_id=apg.show_id
where type='Movie'
group by apg.genre
order by genre;

#-----Checking Genre list
select distinct genre from amazon_prime_genre
order by genre;

/*--5  find the list of directors who have created horror and comedy movies both.
display director names along with number of comedy and horror movies directed by them */
select apd.director
, count(distinct case when apg.genre='Comedy' then ap.show_id end) as no_of_comedy 
, count(distinct case when apg.genre='Horror' then ap.show_id end) as no_of_horror
from amazon_prime ap
inner join amazon_prime_genre apg on ap.show_id=apg.show_id
inner join amazon_prime_director apd on ap.show_id=apd.show_id
where type='Movie' and apg.genre in ('Comedy','Horror')
group by apd.director
having COUNT(distinct apg.genre)=2;

#-----Cross Checking above query
select * from amazon_prime_genre where show_id in 
(select show_id from amazon_prime_director where director='D.J. Viola')
order by genre;
#---D.J. Viola	19	19















