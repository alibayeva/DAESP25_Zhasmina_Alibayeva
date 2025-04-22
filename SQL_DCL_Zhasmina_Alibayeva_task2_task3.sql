CREATE USER rentaluser WITH PASSWORD 'rentalpassword';

GRANT SELECT ON customer TO rentaluser;

CREATE ROLE rental;
GRANT rental TO rentaluser;

GRANT INSERT, UPDATE ON rental TO rental;

REVOKE INSERT ON rental FROM rental;

DO $$
DECLARE
    cust RECORD;
    role_name TEXT;
BEGIN
    FOR cust IN SELECT first_name, last_name FROM customer
    LOOP
        role_name := format('client_%s_%s', cust.first_name, cust.last_name);
        EXECUTE format('CREATE ROLE %I', role_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE rental ENABLE ROW LEVEL SECURITY;

CREATE POLICY rental_policy
    ON rental
    USING (customer_id = current_setting('app.current_customer')::INTEGER);

ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

CREATE POLICY payment_policy
    ON payment
    USING (customer_id = current_setting('app.current_customer')::INTEGER);
