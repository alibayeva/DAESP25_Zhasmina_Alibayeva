-- Part 1 - Task 1
-- All animation movies released between 2017 and 2019 with rate more than 1, alphabetical
SELECT title
FROM film
WHERE release_year BETWEEN 2017 AND 2019
  AND rating IS NOT NULL
  AND rental_rate > 1
  AND film_id IN (
      SELECT film_id
      FROM film_category fc
      JOIN category c ON fc.category_id = c.category_id
      WHERE c.name = 'Animation'
  )
ORDER BY title;
-- Part 1 - Task 2
-- The revenue earned by each rental store after March 2017
SELECT 
  CONCAT(a.address, ' ', COALESCE(a.address2, '')) AS full_address,
  SUM(p.amount) AS revenue
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id
JOIN store st ON s.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
WHERE p.payment_date > '2017-03-31'
GROUP BY a.address, a.address2
ORDER BY revenue DESC;
-- Part 1 - Task 3
-- Top-5 actors by number of movies (released after 2015) they took part in
SELECT 
  a.first_name,
  a.last_name,
  COUNT(*) AS number_of_movies
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.release_year > 2015
GROUP BY a.actor_id
ORDER BY number_of_movies DESC
LIMIT 5;
-- Part 1 - Task 4
-- Number of Drama, Travel, Documentary per year (columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order)
SELECT 
  f.release_year,
  COUNT(CASE WHEN c.name = 'Drama' THEN 1 END) AS number_of_drama_movies,
  COUNT(CASE WHEN c.name = 'Travel' THEN 1 END) AS number_of_travel_movies,
  COUNT(CASE WHEN c.name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;
-- Part 2 - Task 1
-- Which three employees generated the most revenue in 2017? They should be awarded a bonus for their outstanding performance. 
SELECT 
    s.first_name,
    s.last_name,
    s.store_id,
    SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
  AND p.payment_date = (
      SELECT MAX(p2.payment_date)
      FROM payment p2
      WHERE p2.staff_id = p.staff_id
        AND EXTRACT(YEAR FROM p2.payment_date) = 2017
  )
GROUP BY s.first_name, s.last_name, s.store_id
ORDER BY total_revenue DESC
LIMIT 3;
-- Part 2 - Task 1
-- Which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies?  
SELECT 
    f.title,
    COUNT(r.rental_id) AS rental_count,
    f.rating,
    CASE 
        WHEN f.rating = 'G' THEN 'All ages'
        WHEN f.rating = 'PG' THEN '10+'
        WHEN f.rating = 'PG-13' THEN '13+'
        WHEN f.rating = 'R' THEN '17+'
        WHEN f.rating = 'NC-17' THEN 'Adults only'
        ELSE 'Unknown'
    END AS expected_audience_age
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY rental_count DESC
LIMIT 5;
-- Part 3 - Task 1
-- V1: gap between the latest release_year and current year per each actor
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS full_name,
    MAX(f.release_year) AS last_movie_year,
    2025 - MAX(f.release_year) AS years_inactive
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY full_name
ORDER BY years_inactive DESC;

