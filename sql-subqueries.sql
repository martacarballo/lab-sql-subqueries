-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    f.title,
    COUNT(i.inventory_id) AS number_of_copies
FROM film f
JOIN inventory i 
    ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT 
    first_name, 
    last_name
FROM actor
WHERE actor_id IN (
        SELECT actor_id
        FROM film_actor
        WHERE film_id = (
                SELECT film_id
                FROM film
                WHERE title = 'Alone Trip'
        )
);


/*4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.*/

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id = (
		SELECT category_id
		FROM category
		WHERE name = 'Family')
	);


/*5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.*/

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);


SELECT 
    c.first_name,
    c.last_name,
    c.email
FROM customer c
JOIN address a 
    ON c.address_id = a.address_id
JOIN city ci 
    ON a.city_id = ci.city_id
JOIN country co 
    ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

/*6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.*/

SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    f.film_id,
    f.title
FROM actor a
JOIN film_actor fa 
    ON a.actor_id = fa.actor_id
JOIN film f 
    ON fa.film_id = f.film_id
WHERE a.actor_id = (
    SELECT fa2.actor_id
    FROM film_actor fa2
    GROUP BY fa2.actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

/* 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer 
and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.*/


SELECT title
FROM film
WHERE film_id IN(
	SELECT film_id
	FROM inventory
	WHERE film_id IN (
		SELECT  inventory_id
		FROM rental
		WHERE customer_id = (
			SELECT customer_id
			FROM payment
            group by customer_id
			ORDER BY SUM(amount) DESC
			LIMIT 1
)));



SELECT DISTINCT f.title
FROM payment p
INNER JOIN rental r ON r.customer_id = p.customer_id
INNER JOIN inventory i ON i.inventory_id = r.inventory_id
INNER JOIN film f ON f.film_id = i.film_id
WHERE p.customer_id = (
		SELECT customer_id
		FROM payment
		GROUP BY customer_id
		ORDER BY SUM(amount) DESC
		LIMIT 1
		);


SELECT DISTINCT f.title
FROM film f
INNER JOIN inventory i ON i.film_id = f.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
INNER JOIN payment p ON p.customer_id = r.customer_id
WHERE p.customer_id = (
	SELECT customer_id
	FROM payment
	GROUP BY customer_id
	ORDER BY SUM(amount) DESC
	LIMIT 1
);


SELECT title
FROM film
WHERE film_id IN (
SELECT i.film_id
FROM inventory i
WHERE i.inventory_id IN (
SELECT r.inventory_id
FROM rental r
WHERE r.customer_id = (
SELECT customer_id
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1
)
)
);


/* 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
You can use subqueries to accomplish this.*/

SELECT 
    customer_id, 
    SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(amount) AS customer_total
        FROM payment
        GROUP BY customer_id
    ) AS t
)
ORDER BY total_amount_spent DESC;

