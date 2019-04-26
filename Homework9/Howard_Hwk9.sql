
USE sakila;

-- 1a. First and Last names of all actors --
SELECT first_name, last_name FROM actor;

-- 1b. First and Last names, single column, uppercase --
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. ID, first name, last name for 'Joe' --
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

-- 2b. Actors where last name contains 'GEN' --
SELECT * FROM actor WHERE last_name LIKE '%gen%';

-- 2c. Actors where last name contains 'li', ordered --
select * from actor where last_name like '%li%'
order by last_name, first_name asc;

-- 2d. Display country_id, country for Afghanistan, Bangladesh, China --
select country_id, country from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add description column to actor table --
alter table actor add column description BLOB NULL;
show columns from actor;

-- 3b. Remove description column from actor table --
alter table actor drop column description;
show columns from actor;

-- 4a. Last names and count --
select last_name as 'Last Name', count(*) as 'Total Actors'
from actor group by last_name order by last_name asc;

-- 4b. Last names, count >= 2 -- 
select last_name as 'Last Name', count(1) as 'Total Actors'
from actor 
group by last_name having count(1) >= 2
order by last_name asc;

-- 4c. Harpo to Groucho --
select * from actor where last_name = 'WILLIAMS'; 
update actor set first_name = 'HARPO' 
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
select * from actor where last_name = 'WILLIAMS';

-- 4d. Groucho back to Harpo --
select * from actor where first_name = 'HARPO';
update actor set first_name = 'GROUCHO' where first_name = 'HARPO';
select * from actor where first_name = 'HARPO';
