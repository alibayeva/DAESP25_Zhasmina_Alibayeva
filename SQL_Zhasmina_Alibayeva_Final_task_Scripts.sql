CREATE TABLE item (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    item_type VARCHAR(100) CHECK (item_type IN ('artwork', 'artifact', 'specimen', 'historical_object')),
    acquisition_date DATE NOT NULL CHECK (acquisition_date > '2024-01-01'),
    estimated_value NUMERIC(12,2) DEFAULT 0 CHECK (estimated_value >= 0),
    status VARCHAR(50) DEFAULT 'in_storage' CHECK (status IN ('in_storage', 'on_display', 'under_maintenance'))
);

CREATE TABLE exhibition (
    exhibition_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    is_online BOOLEAN DEFAULT FALSE,
    start_date DATE,
    end_date DATE,
    CHECK (start_date <= end_date)
);

CREATE TABLE storage (
    storage_id SERIAL PRIMARY KEY,
    location_name VARCHAR(255) NOT NULL,
    temperature_celsius NUMERIC(5,2) CHECK (temperature_celsius BETWEEN 5 AND 25),
    humidity_percent NUMERIC(5,2) CHECK (humidity_percent BETWEEN 30 AND 70)
);


CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE visitor (
    visitor_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    visit_date DATE DEFAULT CURRENT_DATE CHECK (visit_date >= '2024-01-01'),
    exhibition_id INT REFERENCES exhibition(exhibition_id)
);

CREATE TABLE item_exhibition (
    item_id INT REFERENCES item(item_id),
    exhibition_id INT REFERENCES exhibition(exhibition_id),
    display_location VARCHAR(255),
    PRIMARY KEY (item_id, exhibition_id)
);

ALTER TABLE item
ADD CONSTRAINT check_estimated_value_positive CHECK (estimated_value >= 0);

ALTER TABLE item
ADD CONSTRAINT check_acquisition_date CHECK (acquisition_date >= '2024-01-01');

ALTER TABLE exhibition
ADD CONSTRAINT check_exhibition_status CHECK (status IN ('planned', 'ongoing', 'completed'));

ALTER TABLE employee
ADD CONSTRAINT check_employee_name_not_empty CHECK (LENGTH(full_name) > 0);

ALTER TABLE visitor
ADD CONSTRAINT check_visitor_name_not_empty CHECK (LENGTH(full_name) > 0);

ALTER TABLE storage
ADD CONSTRAINT check_storage_temperature CHECK (temperature_celsius BETWEEN 5 AND 25);

ALTER TABLE storage
ADD CONSTRAINT check_storage_humidity CHECK (humidity_percent BETWEEN 30 AND 70);

INSERT INTO storage (location_name, temperature_celsius, humidity_percent)
VALUES
('Main Storage Room', 22.5, 60),
('Cold Storage', 6.0, 65),
('Temporary Storage', 15.0, 45),
('Vault M', 18.0, 55),
('Vault N', 19.5, 60),
('Special Storage', 18.0, 45)
ON CONFLICT DO NOTHING;

INSERT INTO employee (full_name, position, hire_date)
VALUES 
('Alina Janybekova', 'Curator', '2024-02-15'),
('Bayan Ali', 'Exhibition Manager', '2024-03-01'),
('Kamila Esenzhanova', 'Restorer', '2024-01-10'),
('Daniyal Kokimbayev', 'Security Specialist', '2024-02-20'),
('Nurbek Nurbekov', 'Guide', '2024-01-25'),
('Zhan Zhanov', 'Archivist', '2024-03-05')
ON CONFLICT DO NOTHING;

INSERT INTO exhibition (title, is_online, start_date, end_date)
VALUES 
('Ancient Artifacts', FALSE, '2024-02-01', '2024-05-01'),
('Digital Wonders', TRUE, '2024-03-15', '2024-06-15'),
('Nature and Science', FALSE, '2024-01-10', '2024-04-10'),
('Historical Figures', TRUE, '2024-02-20', '2024-05-20'),
('World Cultures', FALSE, '2024-01-05', '2024-03-30'),
('Photography of the 20th Century', TRUE, '2024-03-01', '2024-06-01')
ON CONFLICT DO NOTHING;

INSERT INTO visitor (full_name, visit_date, exhibition_id)
VALUES 
('Ayan Nurmaganbet', '2024-03-10', 1),
('Madina Zhanat', '2024-03-12', 2),
('Dias Yermek', '2024-03-15', 3),
('Aruzhan Kairat', '2024-03-20', 4),
('Yerbolat Almas', '2024-03-18', 5),
('Zhanel Samat', '2024-03-22', 6)
ON CONFLICT DO NOTHING;

INSERT INTO item (item_name, item_type, acquisition_date, estimated_value, status)
VALUES 
('Golden Necklace', 'artifact', '2024-03-01', 1500, 'on_display'),
('Ancient Vase', 'artifact', '2024-02-15', 3000, 'in_storage'),
('Dinosaur Skull', 'specimen', '2024-01-20', 5000, 'on_display'),
('Historical Sword', 'historical_object', '2024-03-10', 800, 'on_display'),
('Modern Painting', 'artwork', '2024-02-28', 12000, 'on_display'),
('Kazakh Carpet', 'artifact', '2024-03-05', 4000, 'in_storage')
ON CONFLICT DO NOTHING;

INSERT INTO item_exhibition (item_id, exhibition_id, display_location)
VALUES 
(1, 1, 'Hall A'),
(2, 1, 'Hall B'),
(3, 3, 'Science Room'),
(4, 4, 'Weapons Hall'),
(5, 5, 'Gallery Room 1'),
(6, 6, 'Main Exhibit Room')
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION update_item_field(
    p_item_id INT,
    p_column_name TEXT,
    p_new_value TEXT
)
RETURNS VOID AS
$$
BEGIN
    EXECUTE format('UPDATE item SET %I = $1 WHERE item_id = $2', p_column_name)
    USING p_new_value, p_item_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_new_visitor(
    p_full_name VARCHAR,
    p_visit_date DATE,
    p_exhibition_id INT
)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO visitor (full_name, visit_date, exhibition_id)
    VALUES (p_full_name, p_visit_date, p_exhibition_id);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE VIEW recent_quarter_visits AS
SELECT 
    e.title AS exhibition_title,
    COUNT(v.visitor_id) AS total_visitors
FROM 
    visitor v
JOIN 
    exhibition e ON v.exhibition_id = e.exhibition_id
WHERE 
    v.visit_date >= date_trunc('quarter', CURRENT_DATE)
GROUP BY 
    e.title;

CREATE ROLE manager WITH LOGIN PASSWORD 'secure_password';

GRANT CONNECT ON DATABASE museum TO manager;
GRANT USAGE ON SCHEMA public TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO manager;