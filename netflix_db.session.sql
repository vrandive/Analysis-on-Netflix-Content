select * from netflix;

select count(*) as total_rows from netflix;

Select distinct type from netflix;



-- 1. Count the number of Movies vs TV Shows --
Select type, count(*) from netflix
group by type


-- 2. Find the most common rating for movies and TV shows --

select type, rating from (
select type, rating, count(*) as rating_count,
rank() over (partition by type order by count(*) desc) as ranking
from netflix
group by type, rating) as t1
where ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020) --
select * from netflix
where release_year = 2020 and type = 'Movie'


-- 4. Find the top 5 countries with the most content on Netflix --
Select TRIM(Unnest (String_to_array(country,','))) as new_country, 
count(show_id) from netflix
group by country
order by count(show_id) desc
limit 5;


-- 5. Identify the longest movie --
select title, replace(duration, ' min',''):: INT as minutes from netflix
where type = 'Movie' and 
replace(duration, ' min',''):: INT = 
(select max(replace(duration, ' min',''):: INT) as minutes 
from netflix where type = 'Movie')



-- 6. Find content added in the last 5 years --
select *
 from netflix
where to_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'! --
select * from netflix
where director LIKE '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons --
select * from netflix
where type = 'TV Show'
And 
Split_part(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre --
Select TRIM(Unnest (String_to_array(listed_in,','))) as genre, count(show_id) as total content from netflix
group by 1

-- 10.Find each year and the average numbers of content release in India on netflix. --
-- return top 5 year with highest avg content release! --

select Extract(Year from to_date(date_added, 'Month DD, YYYY')) as year, count(*), round(count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100, 2) as avg_content from netflix
where country = 'India'
group by year


-- 11. List all movies that are documentaries --
Select * FROm netflix
where listed_in ILIKE '%documentaries%'

-- 12. Find all content without a director --
select * from netflix
where director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years! --
select * from netflix
where casts ILIKE '%Salman Khan%' 
and 
release_year > Extract(Year from current_date) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India. --
Select TRIM(UNNEST(string_to_array(casts,','))) as actors, count(*) from netflix
where country ILIKE '%India%'
group by actors
order by count(*) desc
limit 10


-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in --
-- the description field. Label content containing these keywords as 'Bad' and all other --
-- content as 'Good'. Count how many items fall into each category. --
with category_table as ( select
Case
when description ILIKE '%kill%' or description ILIKE '%violence%' then 'Bad'
else 'Good'
End as content_quality
from Netflix)

select content_quality, count(*) as total_content from category_table
group by content_quality
