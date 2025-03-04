
-- Spotify SQL Project --
-- There are a number of arbitrary values in this dataset, such as 'danceability' and 'energy' that are not actually quantifiable qualities. --
-- I am simply working with the data provided to me, so for the sake of this excercise, let's pretend that those qualities have actual quantitative values --

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis --
select count(*) from spotify;


SELECT MAX(duration_min) from spotify;
SELECT MIN(duration_min) from spotify;

Select * from spotify 
where duration_min = 0;

delete from spotify 
where duration_min =0;

-- Simple Queries ---------------------------------------------------------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams. --


Select * from Spotify
where stream > 1000000000;

-- List all albums along with their respective artists. --


Select 
	distinct album, artist
from Spotify;

-- Get the total number of comments for tracks where licensed = true --

Select 
	sum(comments) from Spotify
where licensed = 'true';

-- Find all tracks that belong to the album type single. --

select * from spotify
where album_type = 'single';

-- Count the total number of tracks by each artist. --

select
	artist, 
	count(*) as total_no_songs
from spotify
group by artist
order by 2 desc;

-- Medium Level Queries ------------------------------------------------------------ 

-- Calculate the average danceability of tracks in each album. --

Select 
	album, 
	avg(danceability) as avg_danceability 
from spotify
group by 1
order by 2 desc;

-- Find the top 5 tracks with the highest energy values. --

select 
	distinct track,
	avg(energy)
from spotify
group by 1
order by 2 desc
limit 5;


-- List all tracks along with their views and likes where official_video = TRUE. --

select 
	track, 
	views as total_views, 
	likes as total_likes
from spotify
where official_video = 'true'
group by 1, 2, 3
order by 2 desc;

-- For each album, calculate the total views of all associated tracks. --

select album, 
	track,
	sum(views) as views
from spotify
group by 1, 2
order by 3 desc
;

-- Retrieve the track names that have been streamed on Spotify more than YouTube. --

select * from 
(select 
	track,
	coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
	coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
from spotify
group by 1
) as t1
where streamed_on_spotify > streamed_on_youtube
and 
streamed_on_youtube <>0;


-- Advanced Queries --------------------------------------------------------

-- Find the top 3 most-viewed tracks for each artist --

with ranking_artist
as
(select 
	artist,
	track,
	sum(views) as total_views,
	dense_rank() over(partition by artist order by sum(views)desc) as rank
from spotify
group by 1, 2
order by 1, 3 desc
)
select * from ranking_artist 
where rank <= 3;


-- Write a query to find tracks where the liveness score is above the average. --

select avg(liveness) from spotify; -- 0.19

select track,
	artist,
	liveness
from spotify
where  liveness > 0.19;

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album -- 

with cte
as
(select album,
	max(energy) as highest_energy,
	min(energy) as lowest_energy
from spotify
group by 1
)
select 
	album,
	highest_energy - lowest_energy as energy_difference
from cte
order by 2 desc;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2. --

select
	track,
	energy / liveness as energy_to_liveness_ratio
from spotify
where energy / liveness >= 1.2;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions. --

select 
	track,
	views,
	sum(likes) over (order by views) as cumulative_sum_likes
from spotify
order by sum(likes) over (order by views) desc;


--------------------------------------------------------------------------------------------









