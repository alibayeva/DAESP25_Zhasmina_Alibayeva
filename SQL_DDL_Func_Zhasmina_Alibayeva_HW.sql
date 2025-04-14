
--Task 1
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    DATE_PART('year', p.payment_date) AS year,
    CEIL(DATE_PART('month', p.payment_date) / 3.0)::int AS quarter,
    SUM(p.amount) AS total_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE DATE_PART('year', p.payment_date) = DATE_PART('year', CURRENT_DATE)
  AND CEIL(DATE_PART('month', p.payment_date) / 3.0)::int = CEIL(DATE_PART('month', CURRENT_DATE) / 3.0)::int
GROUP BY category, year, quarter
HAVING SUM(p.amount) > 0;

--Task 2
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(qtr int, yr int)
RETURNS TABLE (category text, total_revenue numeric) AS $$
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_revenue
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE DATE_PART('year', p.payment_date) = yr
      AND CEIL(DATE_PART('month', p.payment_date) / 3.0)::int = qtr
    GROUP BY c.name
    HAVING SUM(p.amount) > 0;
$$ LANGUAGE sql;

--Task3
CREATE OR REPLACE FUNCTION most_popular_film_by_country(countries text[])
RETURNS TABLE (country text, film text, rating text, language text, length int, release_year int) AS $$
BEGIN
    RETURN QUERY
    SELECT
        country,
        title,
        rating,
        name AS language,
        length,
        release_year
    FROM core.most_popular_films_by_countries(countries);
END;
$$ LANGUAGE plpgsql;

--Task4
CREATE OR REPLACE FUNCTION films_in_stock_by_title(search_title text)
RETURNS TABLE (row_num int, title text, language text, customer text, rental_date timestamp) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER () AS row_num,
        f.title,
        l.name AS language,
        c.first_name || ' ' || c.last_name AS customer,
        r.rental_date
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN language l ON f.language_id = l.language_id
    WHERE f.title ILIKE search_title;

    IF NOT FOUND THEN
        RAISE NOTICE 'No film found with title pattern: %', search_title;
    END IF;
END;
$$ LANGUAGE plpgsql;

--Task5 
CREATE OR REPLACE FUNCTION new_movie(title text)
RETURNS void AS $$
DECLARE
    lang_id integer;
    film_id integer;
BEGIN
    SELECT language_id INTO lang_id FROM language WHERE name = 'Klingon';
    IF NOT FOUND THEN
        INSERT INTO language(name) VALUES ('Klingon') RETURNING language_id INTO lang_id;
    END IF;

    SELECT COALESCE(MAX(film_id), 0) + 1 INTO film_id FROM film;

    DELETE FROM film WHERE title = title;

    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (film_id, title, 4.99, 3, 19.99, DATE_PART('year', CURRENT_DATE)::int, lang_id);
END;
$$ LANGUAGE plpgsql;
