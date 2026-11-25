--Part 1: Database Setup
DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
                          station_id INT PRIMARY KEY,
                          station_name VARCHAR(50) NOT NULL,
                          city VARCHAR(40) NOT NULL,
                          capacity INT NOT NULL
);

CREATE TABLE bikes (
                       bike_id INT PRIMARY KEY,
                       model VARCHAR(50) NOT NULL,
                       station_id INT REFERENCES stations(station_id),
                       daily_rate NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
                         member_id INT PRIMARY KEY,
                         full_name VARCHAR(60) NOT NULL,
                         city VARCHAR(40) NOT NULL,
                         joined_on DATE NOT NULL
);

CREATE TABLE rentals (
                         rental_id INT PRIMARY KEY,
                         member_id INT REFERENCES members(member_id),
                         bike_id INT REFERENCES bikes(bike_id),
                         start_date DATE NOT NULL,
                         end_date DATE,
                         fee NUMERIC(8,2)
);

INSERT INTO stations VALUES
                         (10, 'Central Park', 'Almaty', 4),
                         (20, 'Riverside', 'Almaty', 3),
                         (30, 'Expo Gate', 'Astana', 5),
                         (40, 'Old Town', 'Shymkent', 2),
                         (50, 'Depot', 'Astana', 0);

INSERT INTO bikes VALUES
                      (101, 'City Cruiser', 10, 4.50),
                      (102, 'City Cruiser', 10, 4.50),
                      (103, 'Mountain X', 20, 7.00),
                      (104, 'Mountain X', 30, 7.00),
                      (105, 'Road Sprint', 30, 9.25),
                      (106, 'Folding Mini', 40, 3.75),
                      (107, 'Cargo Hauler', 20, 12.00),
                      (108, 'Road Sprint', 10, 9.25);

INSERT INTO members VALUES
                        (1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
                        (2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
                        (3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
                        (4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
                        (5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
                        (6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');

INSERT INTO rentals VALUES
                        (1,1,101,DATE '2024-04-05',DATE '2024-04-08',13.50),
                        (2,1,103,DATE '2024-06-11',DATE '2024-06-16',35.00),
                        (3,1,108,DATE '2025-02-02',DATE '2025-02-04',18.50),
                        (4,1,102,DATE '2025-05-20',DATE '2025-05-27',31.50),
                        (5,2,101,DATE '2024-05-01',DATE '2024-05-02',4.50),
                        (6,2,107,DATE '2024-11-15',DATE '2024-11-19',48.00),
                        (7,2,107,DATE '2025-03-08',DATE '2025-03-14',72.00),
                        (8,3,104,DATE '2024-02-14',DATE '2024-02-18',28.00),
                        (9,3,105,DATE '2024-08-03',DATE '2024-08-06',27.75),
                        (10,3,104,DATE '2025-01-09',DATE '2025-01-10',7.00),
                        (11,3,105,DATE '2025-06-01',DATE '2025-06-09',74.00),
                        (12,4,104,DATE '2024-07-19',DATE '2024-07-21',14.00),
                        (13,4,105,DATE '2025-04-12',DATE '2025-04-15',27.75),
                        (14,4,103,DATE '2025-07-23',DATE '2025-07-29',42.00),
                        (15,5,106,DATE '2024-10-05',DATE '2024-10-12',26.25),
                        (16,5,106,DATE '2025-01-18',DATE '2025-01-20',7.50),
                        (17,5,106,DATE '2025-08-14',DATE '2025-08-21',26.25),
                        (18,2,102,DATE '2025-09-02',DATE '2025-09-05',13.50),
                        (19,1,101,DATE '2025-10-10',NULL,NULL),
                        (20,4,108,DATE '2024-12-28',DATE '2025-01-03',55.50),
                        (21,3,103,DATE '2025-02-26',DATE '2025-03-02',28.00),
                        (22,5,104,DATE '2025-05-05',DATE '2025-05-08',21.00);

SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes) AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;

-- PART 2. FIRST FUNCTIONS
--2.1
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
    DECLARE
    v_days INT;
    BEGIN
        SELECT end_date - start_date
        INTO v_days
        FROM rentals
        WHERE rental_id=p_rental_id;
        RETURN v_days;
    end;
    $$ LANGUAGE plpgsql;

SELECT rental_days(19);  -- NULL: end_date is NULL (open rental)
SELECT rental_days(999); -- NULL: no matching rental row

--2.2

CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT $$
    DECLARE
    v_count INT;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM rentals
        WHERE member_id=p_member_id;
        RETURN v_count;
    END;
    $$ LANGUAGE plpgsql;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);

--2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR $$
    DECLARE
    v_city VARCHAR
    BEGIN
        SELECT city
        INTO v_city
        FROM stations
        WHERE station_id=p_station_id;
        RETURN v_city;
    END;
    $$ LANGUAGE plpgsql;

--2.4
SELECT rental_id,member_id,rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id)>4
ORDER BY duration_days DESC;

--Part 3: Parameter Modes
--3.1
CREATE OR REPLACE FUNCTION fee_with_discount(in p_fee NUMERIC,in p_percent NUMERIC)
RETURNS NUMERIC $$
    BEGIN
        RETURN ROUND(p_fee*(1-p_percent/100),2);
    END;
    $$ LANGUAGE plpgsql;
SELECT fee_with_discount(74.00, 15);

--3.2

CREATE OR REPLACE FUNCTION member_stats(
    IN p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
    BEGIN
        SELECT COUNT(*)::INT,
               COALESCE(SUM(fee), 0),
               MAX(start_date)
        INTO rental_cnt, total_fee, last_start
        FROM rentals
        WHERE member_id = p_member_id;
    end;
    $$ LANGUAGE plpgsql;

--3.3
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
    BEGIN
        p_fee:=p_fee+5.00;
    end;
$$ LANGUAGE plpgsql;

--3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(p_fees[g.i]), 0),
           ROUND(AVG(p_fees[g.i]), 2),
           MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

-- PART 4. DEFAULT VALUES AND OVERLOADING

-- 4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
    RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
SELECT total_fees(6);

-- 4.2 Two-argument overload
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
    RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');

-- 4.3
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
    RETURNS NUMERIC AS $$
DECLARE v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;


-- 4.4
DROP FUNCTION IF EXISTS total_fees(INTEGER);
SELECT total_fees(1);

-- 4.5
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR)
    RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM members m
             LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'::VARCHAR);
SELECT total_fees(1);

s_free INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name::VARCHAR,
           COUNT(b.bike_id)::INT,
           (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s
    LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');

-- PART 6. BLOCKS, DO AND SUBBLOCKS

-- 6.1
DO $$
    <<rental_report>>
        DECLARE
        total_rentals INTEGER := 0;
    BEGIN
        SELECT COUNT(*)::INT INTO total_rentals FROM rentals;
        RAISE NOTICE 'The rentals table holds % rows', total_rentals;
    END rental_report;
$$;

-- 6.2
DO $$
    <<outer_block>>
        DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0) INTO fee_total FROM rentals;
        RAISE NOTICE '1. Outer total before subblock: %', fee_total;

        DECLARE
            fee_total NUMERIC;
        BEGIN
            SELECT COALESCE(SUM(fee), 0)
            INTO fee_total
            FROM rentals
            WHERE start_date >= DATE '2025-01-01';

            RAISE NOTICE '2. Inner total: %', fee_total;
            RAISE NOTICE '3. Outer total from inner block: %',
                outer_block.fee_total;
        END;

        RAISE NOTICE '4. Outer total after subblock: %', fee_total;
    END outer_block;
$$;

-- 6.3
--
-- DO $$
-- BEGIN
--     DECLARE
--         inner_value INT := 10;
--     BEGIN
--         RAISE NOTICE 'Inside: %', inner_value;
--     END;
--     RAISE NOTICE 'Outside: %', inner_value; -- expected: does not exist
-- END;
-- $$;
--
-- Correct approach: declare shared_value in the outer DECLARE section,
-- then both nested blocks can read it.

DO $$
    DECLARE
        shared_value INT := 10;
    BEGIN
        DECLARE
        BEGIN
            RAISE NOTICE 'First subblock sees %', shared_value;
        END;

        DECLARE
        BEGIN
            RAISE NOTICE 'Second subblock sees %', shared_value;
        END;
    END;
$$;

-- 6.4
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date), 0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');
SELECT before_total + after_total AS combined_total
FROM fee_split(DATE '2025-01-01');


-- PART 7. PRACTICAL SCENARIOS

-- 7.1
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT
    INTO v_capacity, bikes_parked
    FROM stations s
             LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.capacity;

    IF NOT FOUND THEN
        bikes_parked := 0;
        capacity_pct := NULL;
    ELSIF v_capacity = 0 THEN
        capacity_pct := 0.0;
    ELSE
        capacity_pct := ROUND(bikes_parked * 100.0 / v_capacity, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s
         CROSS JOIN LATERAL station_load(s.station_id) l;

-- 7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
    RETURNS TABLE (
                      member_name VARCHAR,
                      rental_count BIGINT,
                      amount_spent NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT m.full_name::VARCHAR,
               COUNT(r.rental_id),
               COALESCE(SUM(r.fee), 0)::NUMERIC
        FROM members m
                 LEFT JOIN rentals r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY COALESCE(SUM(r.fee), 0) DESC, m.member_id
        LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- 7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
    RETURNS TABLE (
                      member_name VARCHAR,
                      bike_model VARCHAR,
                      duration_days INT,
                      amount_owed NUMERIC,
                      rental_status VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT m.full_name::VARCHAR,
               b.model::VARCHAR,
               (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
               ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date)
                         * b.daily_rate, 2)::NUMERIC,
               CASE WHEN r.end_date IS NULL
                        THEN 'OPEN'::VARCHAR
                    ELSE 'CLOSED'::VARCHAR
                   END
        FROM rentals r
                 JOIN members m ON m.member_id = r.member_id
                 JOIN bikes b ON b.bike_id = r.bike_id
        WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- 7.4
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
    RETURNS TABLE (
                      member_count BIGINT,
                      rental_count BIGINT,
                      total_revenue NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT COUNT(DISTINCT m.member_id),
               COUNT(r.rental_id),
               COALESCE(SUM(r.fee), 0)::NUMERIC
        FROM members m
                 LEFT JOIN rentals r ON r.member_id = m.member_id
        WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE
)
    RETURNS TABLE (
                      member_count BIGINT,
                      rental_count BIGINT,
                      total_revenue NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT COUNT(DISTINCT m.member_id),
               COUNT(r.rental_id),
               COALESCE(SUM(r.fee), 0)::NUMERIC
        FROM members m
                 LEFT JOIN rentals r
                           ON r.member_id = m.member_id
                               AND r.start_date >= p_from_date
        WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');

