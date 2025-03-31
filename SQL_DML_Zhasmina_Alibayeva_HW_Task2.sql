-- Task 1
-- Choose your top-3 favorite movies and add them to the 'film' table. Fill in rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively
INSERT INTO film (title, rental_rate, rental_duration, language_id, last_update)
SELECT title, rate, duration, 1, CURRENT_DATE
FROM (VALUES
    ('La La Land', 4.99, 7),
    ('Mickey 17', 9.99, 14),
    ('It', 19.99, 21)
) AS new_films(title, rate, duration)
WHERE NOT EXISTS (
    SELECT 1 FROM film WHERE title = new_films.title
)
RETURNING film_id;
-- Add the actors who play leading roles in your favorite movies to the 'actor' and 'film_actor' tables (6 or more actors in total) 
INSERT INTO actor (first_name, last_name, last_update)
SELECT first_name, last_name, CURRENT_DATE
FROM (VALUES
    ('Ryan', 'Gosling'),
    ('Emma', 'Stone'),
    ('Robert', 'Pattinson'),
    ('Steven', 'Yeun'),
    ('Bill', 'Skarsgård'),
    ('Jessica', 'Chastain')
) AS new_actors(first_name, last_name)
WHERE NOT EXISTS (
    SELECT 1 FROM actor WHERE first_name = new_actors.first_name AND last_name = new_actors.last_name
);
-- Add your favorite movies to any store's inventory
INSERT INTO inventory (film_id, store_id, last_update)
SELECT f.film_id, 1, CURRENT_DATE
FROM film f
WHERE f.title IN ('La La Land', 'Mickey 17', 'It')
AND NOT EXISTS (
    SELECT 1 FROM inventory i
    WHERE i.film_id = f.film_id AND i.store_id = 1
);
-- Alter any existing customer in the database with at least 43 rental and 43 payment records. Change their personal data to yours (first name, last name, address, etc.). You can use any existing address from the "address" table
UPDATE customer
SET first_name = 'Zhasmina',
    last_name = 'Alibayeva',
    email = 'zhasmina.alibayeva@gmail.com',
    last_update = CURRENT_DATE
WHERE customer_id IN (
    SELECT c.customer_id
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(r.rental_id) >= 43 AND COUNT(p.payment_id) >= 43
);
-- Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
DO $$
DECLARE
    cust_id INT;
BEGIN

    SELECT customer_id INTO cust_id
    FROM customer
    WHERE first_name = 'Zhasmina' AND last_name = 'Alibayeva';

    DELETE FROM payment_p2017_01 WHERE customer_id = cust_id;
    DELETE FROM payment_p2017_02 WHERE customer_id = cust_id;
    DELETE FROM payment_p2017_03 WHERE customer_id = cust_id;
    DELETE FROM payment_p2017_04 WHERE customer_id = cust_id;
    DELETE FROM payment_p2017_05 WHERE customer_id = cust_id;
    DELETE FROM payment_p2017_06 WHERE customer_id = cust_id;

    DELETE FROM payment WHERE customer_id = cust_id;

    DELETE FROM rental WHERE customer_id = cust_id;
-- 
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT CURRENT_DATE, i.inventory_id, c.customer_id, CURRENT_DATE + interval '7 days', 1, CURRENT_DATE
FROM inventory i
JOIN customer c ON c.first_name = 'Zhasmina' AND c.last_name = 'Alibayeva'
WHERE i.film_id IN (
    SELECT film_id FROM film WHERE title IN ('La La Land', 'Mickey 17', 'It')
);

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT c.customer_id, 1, r.rental_id, f.rental_rate, '2017-03-08'
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON c.first_name = 'Zhasmina' AND c.last_name = 'Alibayeva'
WHERE f.title IN ('La La Land', 'Mickey 17', 'It');

Task 2 
Code from the task: 
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1, (10^7)::int) x;

