USE Sakila;

#1a. Display the first and last names of all actors from the table `actor`.
SELECT 		a.first_name, a.last_name
FROM 		sakila.actor a;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 		CONCAT(a.first_name, ' ', a.last_name) AS 'Actor Name'
FROM 		sakila.actor a;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT 		a.actor_id, a.first_name, a.last_name
FROM 		sakila.actor a 
WHERE 		a.first_name = 'Joe';

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT 		*
FROM		sakila.actor a
WHERE 		a.last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 		*
FROM		sakila.actor a
WHERE 		a.last_name LIKE '%LI%'
ORDER BY 	a.last_name, a.first_name;

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 		c.country_id, c.country
FROM 		sakila.country c
WHERE		c.country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
#so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type 
#`BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE	sakila.actor
ADD 		(description BLOB NULL);

#Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE sakila.actor
DROP 		description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT 	 	a.last_name, COUNT(a.last_name) AS TotalSameLastNames
FROM 		sakila.actor a 
GROUP BY 	a.last_name
ORDER BY 	TotalSameLastNames DESC;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT 	 	a.last_name, COUNT(a.last_name) AS TotalSameLastNames
FROM 		sakila.actor a 
GROUP BY 	a.last_name
HAVING 		COUNT(a.last_name) > 1
ORDER BY 	TotalSameLastNames DESC;

#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE 		sakila.actor
SET 		first_name = 'HARPO'
WHERE 		first_name = 'GROUCHO'
AND 		last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE 		sakila.actor
SET 		first_name = 'GROUCHO'
WHERE 		first_name = 'HARPO'
AND 		last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESC address;

CREATE TABLE IF NOT EXISTS	address	
							(address_id		smallint(5) unsigned	PRIMARY KEY		AUTO_INCREMENT,
							address			varchar(50)				NOT NULL,
							address2		varchar(50)				NULL,
							district		varchar(20)				NOT NULL,
							city_id			smallint(5) unsigned	NOT NULL,
							postal_code		varchar(10)				NULL,
							phone			varchar(20)				NOT NULL,
							location		geometry				NOT NULL,
							last_update		timestamp				NOT NULL);

#Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT 		s.first_name, s.last_name, a.address
FROM 		sakila.staff s INNER JOIN sakila.address a
ON 			s.address_id = a.address_id
ORDER BY 	s.last_name, s.first_name;


#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT 		s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS TotalPayment
FROM 		sakila.staff s INNER JOIN sakila.payment p
ON 			s.staff_id = p.staff_id
GROUP BY 	s.staff_id
ORDER BY 	s.last_name, s.first_name;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. 
#Use inner join.
SELECT 		f.title, COUNT(fa.actor_id) AS FilmActors
FROM 		sakila.film f INNER JOIN sakila.film_actor fa
ON 			f.film_id = fa.film_id
GROUP BY 	f.film_id
ORDER BY 	f.title;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 		f.title, COUNT(i.inventory_id) AS TotalCopies
FROM 		sakila.film f INNER JOIN sakila.inventory i
ON 			f.film_id = i.film_id
WHERE 		f.title = 'Hunchback Impossible';

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT 		c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS TotalPayment
FROM 		sakila.customer c INNER JOIN sakila.payment p
ON 			c.customer_id = p.customer_id
GROUP BY 	c.customer_id
ORDER BY 	c.last_name, c.first_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
#of movies starting with the letters `K` and `Q` whose language is English.
SELECT 		f.title
FROM 		sakila.film f 
WHERE 		f.title LIKE 'K%' OR f.title LIKE 'Q%'
AND 		f.language_id =
			(SELECT 	l.language_id
			FROM 		sakila.language l
            WHERE 		l.name = 'English')
ORDER BY 	f.title;

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT 		a.first_name, a.last_name
FROM 		sakila.actor a
WHERE 		a.actor_id IN
			(SELECT 	fa.actor_id
            FROM 		sakila.film_actor fa
            WHERE 		fa.film_id IN
						(SELECT 	f.film_id
                        FROM 		sakila.film f
                        WHERE 		f.title = 'Alone Trip'));
            
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
#Canadian customers. Use joins to retrieve this information.
SELECT 		c.first_name, c.last_name, c.email, y.country
FROM 		sakila.customer c INNER JOIN sakila.address a
ON 			c.address_id = a.address_id INNER JOIN city t
ON 			a.city_id = t.city_id INNER JOIN country y
ON 			t.country_id = y.country_id
WHERE 		y.country = 'Canada'
ORDER BY 	c.last_name, c.first_name;

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as _family_ films.
SELECT 		f.title, c.name
FROM 		film_category fc INNER JOIN category c
ON 			fc.category_id = c.category_id INNER JOIN sakila.film f
ON 			f.film_id = fc.film_id
WHERE 		c.name = 'Family';

#7e. Display the most frequently rented movies in descending order.
SELECT 		f.title, COUNT(r.rental_id) AS TotalRentals
FROM 		sakila.inventory i INNER JOIN sakila.rental r
ON 			i.inventory_id = r.inventory_id INNER JOIN sakila.film f
ON 			i.film_id = f.film_id
GROUP BY 	f.film_id
ORDER BY 	TotalRentals DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 		s.store_id, SUM(amount) AS TotalSales
FROM 		sakila.store s INNER JOIN sakila.staff f
ON 			f.store_id = s.store_id INNER JOIN sakila.payment p
ON 			p.staff_id = f.staff_id
GROUP BY 	s.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT 		s.store_id, c.city, y.country
FROM 		sakila.store s INNER JOIN sakila.address a
ON 			s.address_id = a.address_id INNER JOIN sakila.city c
ON 			c.city_id = a.city_id INNER JOIN sakila.country y
ON 			y.country_id = c.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 		c.name, SUM(p.amount) AS GrossRevenue
FROM 		sakila.category c INNER JOIN sakila.film_category fc
ON 			c.category_id = fc.category_id INNER JOIN sakila.inventory i
ON 			fc.film_id = i.film_id INNER JOIN sakila.rental r
ON 			r.inventory_id = i.inventory_id INNER JOIN sakila.payment p
ON 			p.rental_id = r.rental_id
GROUP BY 	c.category_id
ORDER BY 	GrossRevenue DESC
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT 		c.name, SUM(p.amount) AS GrossRevenue
FROM 		sakila.category c INNER JOIN sakila.film_category fc
ON 			c.category_id = fc.category_id INNER JOIN sakila.inventory i
ON 			fc.film_id = i.film_id INNER JOIN sakila.rental r
ON 			r.inventory_id = i.inventory_id INNER JOIN sakila.payment p
ON 			p.rental_id = r.rental_id
GROUP BY 	c.category_id
ORDER BY 	GrossRevenue DESC
LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT 		* 
FROM top_five_genres;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres


