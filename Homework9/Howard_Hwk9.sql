-- UofMN Data Visualization and Analytics Bootcamp--
-- Homework #7(9) / SQL --
-- Created by Chris Howard --
-- 04/26/2019 --

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
SELECT * FROM actor WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name ASC;

-- 2d. Display country_id, country for Afghanistan, Bangladesh, China --
SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add description column to actor table --
ALTER TABLE actor ADD COLUMN description BLOB NULL;
SHOW COLUMNS FROM actor;

-- 3b. Remove description column from actor table --
ALTER TABLE actor DROP COLUMN description;
SHOW COLUMNS FROM actor;

-- 4a. Last names and count --
SELECT last_name AS 'Last Name', COUNT(*) AS 'Total Actors'
FROM actor GROUP BY last_name ORDER BY last_name ASC;

-- 4b. Last names, count >= 2 -- 
SELECT last_name AS 'Last Name', COUNT(1) AS 'Total Actors'
FROM actor 
GROUP BY last_name HAVING COUNT(1) >= 2
ORDER BY last_name ASC;

-- 4c. Harpo to Groucho --
SELECT * FROM actor WHERE last_name = 'WILLIAMS'; 
UPDATE actor SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM actor WHERE last_name = 'WILLIAMS';

-- 4d. Groucho back to Harpo --
SELECT * FROM actor WHERE first_name = 'HARPO';
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';
SELECT * FROM actor WHERE first_name = 'HARPO';

-- 5a. Recreate schema --
SHOW CREATE TABLE address;

-- 6a. first, last, address of staff members --
SELECT staff.first_name AS 'First Name', staff.last_name AS 'Last Name', 
address.address AS 'Address'
 FROM staff INNER JOIN address 
 ON staff.address_id = address.address_id;

-- 6b. total amount rung up by each staff, aug 2005 --
SELECT staff.staff_id AS 'ID', CONCAT(staff.first_name, ' ', staff.last_name) AS Name,
SUM(payment.amount) AS 'Total Aug 2005'
FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY Name
ORDER BY ID;

-- 6c. film and count of actors --
SELECT film.title AS Title, COUNT(film_actor.actor_id) AS 'Total Actors'
FROM film INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY Title
ORDER BY Title ASC;

-- 6d. Total copies of Hunchback Impossible --
SELECT film.title AS 'Title', COUNT(inventory.film_id) AS 'Copies in Inventory'
FROM film INNER JOIN inventory 
ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Total paid by customer, order by last name --
SELECT customer.first_name AS 'First Name', customer.last_name AS 'Last Name',
SUM(payment.amount) AS 'Total Amount Paid'
FROM customer INNER JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;

-- 7a. Movies starting with K or Q in English --
SELECT title AS Title
FROM film WHERE 
(title LIKE 'K%' OR title LIKE 'Q%') AND
language_id IN (
	SELECT language_id FROM language
    WHERE name = 'English'
    );

-- 7b. Actors in 'Alone Trip' --
SELECT CONCAT(first_name, ' ', last_name) AS 'Actors in "Alone Trip"'
FROM actor
WHERE actor_id IN (
	SELECT actor_id 
    FROM film_actor
    WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip')
	);

-- 7c. Name and Email for Canadian customers --
SELECT first_name AS 'First Name', last_name AS 'Last Name',
email AS 'Email'
FROM customer INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city 
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- 7d. Identify 'family films' -- 
SELECT title AS 'Family Films' 
FROM film INNER JOIN film_category
ON film.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- 7e. Most frequent rentals --
SELECT title AS Title, COUNT(rental.rental_id) AS 'Total Rentals'
FROM film INNER JOIN inventory 
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY Title
ORDER BY COUNT(rental.rental_id) DESC;

-- 7f. Business by store --
SELECT store.store_id AS 'Store ID', SUM(payment.amount) AS 'Total Revenue'
FROM store INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment
ON staff.staff_id = payment.staff_id
GROUP BY store.store_id
ORDER BY SUM(payment.amount) DESC;

-- 7g. Store ID, city, country --
SELECT store.store_id AS 'Store ID', city.city AS 'City', country.country AS 'Country'
FROM store INNER JOIN address
ON store.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country 
ON city.country_id = country.country_id;

-- 7h. Top five genres gross revenue --
SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM category INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY Genre
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- 8a. Create view of top five genres --
CREATE VIEW top_five_genres AS
	SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
	FROM category INNER JOIN film_category
	ON category.category_id = film_category.category_id
	INNER JOIN inventory
	ON film_category.film_id = inventory.film_id
	INNER JOIN rental
	ON inventory.inventory_id = rental.inventory_id
	INNER JOIN payment 
	ON rental.rental_id = payment.rental_id
	GROUP BY Genre
	ORDER BY SUM(payment.amount) DESC
	LIMIT 5;

-- 8b. Display top_five_genres view --
SELECT * FROM top_five_genres;

-- 8c. Remove top_five_genres view --
DROP VIEW top_five_genres;


