use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.

SELECT upper(first_name) as ActorName
FROM actor
UNION
SELECT upper(last_name)
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name 
from actor
where first_name like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name 
from actor
where last_name like '%GEN%';


-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country
from country
where country IN('Afghanistan', 'Bangladesh','China');

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(15) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

Alter Table actor
modify middle_name blob;

-- 3c. Now delete the middle_name column

Alter Table actor
drop middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as count
from actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

select last_name, count(last_name) as Count 
from actor
group by last_name
having count(last_name) > 2;


-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
--  the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

Update actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, 
-- change the first name to MUCHO GROUCHO, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
-- (Hint: update the record using a unique identifier.)

update actor
set first_name = CASE when first_name = "HARPO" then "GROUCHO" END,
first_name = CASE when first_name = "GROUCHO" then "MUCHO GROUCHO" END
where first_name IN("HARPO","GROUCHO") and last_name IN("WILLIAMS","WILLIAMS");

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

show create table address;

describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

select staff.first_name, staff.last_name, address.address
from staff
join address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

select * from payment;

select staff.first_name, staff.last_name, staff.staff_id, sum(payment.amount)
from staff
join payment on staff.staff_id = payment.staff_id and payment.payment_date >= '2005-08-01' and payment.payment_date < '2005-09-01'
group by staff.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

describe film;

select film.title, count(film_actor.actor_id) as TotalActors
from film
inner join film_actor on film.film_id = film_actor.film_id
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

describe inventory;

select film.title, count(inventory.film_id) as Copies
from film
join inventory on film.film_id = inventory.film_id
where film.title = "Hunchback Impossible"
group by film.title;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:

select customer.first_name, customer.last_name, sum(payment.amount) as TotalPayment
from customer
inner join payment on customer.customer_id = payment.customer_id
group by customer.last_name, customer.first_name
order by customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select * from language;

select title
from film
where title like "K%" or title like "Q%" and language_id IN
(
	select language_id 
    from language
    where name = "English" ) ;
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select customer.first_name, customer.last_name, customer.email, 
-- customer.address_id,
-- address.address_id, address.city_id, city.city_id, city.country_id, country.country_id, 
country.country
from customer
join address on customer.address_id = address.address_id
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

select category.name, film.title
from category
join film_category on film_category.category_id = category.category_id
join film on film.film_id = film_category.film_id
where category.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
select title, rental_rate
from film
order by rental_rate desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) as Business
from store
join customer on store.address_id = customer.address_id
join payment on payment.customer_id = customer.customer_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
join address on store.address_id = address.address_id
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id
group by store.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select sum(payment.amount) as Revenue, category.name
from category
join film_category on category.category_id = film_category.category_id
join inventory on inventory.film_id = film_category.film_id
join rental on rental.inventory_id = inventory.inventory_id
join payment on payment.rental_id = rental.rental_id
group by category.name
order by Revenue desc
limit 5;

-- 8a. In your new role as an executive, 
-- you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.



