-- Full Name: Bersinbayeva Aruzhan Radzhanovna
-- Laboratory Work: Database Constraints in PostgreSQL

--------------------------------------------------------------------------------
-- Part 1: CHECK Constraints
--------------------------------------------------------------------------------

-- Task 1.1: Basic CHECK Constraint
CREATE TABLE IF NOT EXISTS employees (
                           employee_id INTEGER,
                           first_name TEXT,
                           last_name TEXT,
                           age INTEGER CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);

-- Testing Task 1.1:
-- Successful insertion of valid data
INSERT INTO employees VALUES (1, '  Qvan', 'Ivanov', 25, 50000.00);
INSERT INTO employees VALUES (2, 'Sana', 'Smirnova', 42, 75000.50);

-- Unsuccessful attempts (will trigger CHECK constraint violation errors):
-- INSERT INTO employees VALUES (3, 'Petr', 'Petrov', 16, 40000.00); -- Violates age (< 18)
-- INSERT INTO employees VALUES (4, 'Olga', 'Sidorova', 30, 0);       -- Violates salary (<= 0)


-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
                                  product_id INTEGER,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0 AND
                                      discount_price > 0 AND
                                      discount_price < regular_price
                                      )
);

-- Testing Task 1.2:
INSERT INTO products_catalog VALUES (101, 'Laptop', 1000.00, 850.00);
INSERT INTO products_catalog VALUES (102, 'Mouse', 50.00, 40.00);

-- Unsuccessful attempts:
-- INSERT INTO products_catalog VALUES (103, 'Keyboard', -100.00, 50.00); -- regular_price <= 0
-- INSERT INTO products_catalog VALUES (104, 'Monitor', 200.00, 250.00);   -- discount_price >= regular_price


-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
                          booking_id INTEGER,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INTEGER,
                          CONSTRAINT chk_guests CHECK (num_guests BETWEEN 1 AND 10),
                          CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);

-- Testing Task 1.3:
INSERT INTO bookings VALUES (1, '2026-06-01', '2026-06-07', 2);
INSERT INTO bookings VALUES (2, '2026-07-10', '2026-07-15', 4);

-- Unsuccessful attempts:
-- INSERT INTO bookings VALUES (3, '2026-08-01', '2026-08-01', 3); -- check_out_date is not after check_in_date
-- INSERT INTO bookings VALUES (4, '2026-09-01', '2026-09-05', 15); -- guests > 10


--------------------------------------------------------------------------------
-- Part 2: NOT NULL Constraints
--------------------------------------------------------------------------------

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
                           customer_id INTEGER NOT NULL,
                           email TEXT NOT NULL,
                           phone TEXT, -- can be NULL
                           registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
                           item_id INTEGER NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);

-- Testing Task 2.3:
INSERT INTO customers VALUES (1, 'user1@mail.com', '+77011234567', '2026-01-10');
INSERT INTO customers VALUES (2, 'user2@mail.com', NULL, '2026-02-15'); -- phone NULL is allowed

-- Unsuccessful attempts:
-- INSERT INTO customers VALUES (3, NULL, '+77017654321', '2026-03-01'); -- email cannot be NULL


--------------------------------------------------------------------------------
-- Part 3: UNIQUE Constraints
--------------------------------------------------------------------------------

-- Task 3.1 & 3.3: Unique Constraints with Custom Names
CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT,
                       email TEXT,
                       created_at TIMESTAMP,
                       CONSTRAINT unique_username UNIQUE (username),
                       CONSTRAINT unique_email UNIQUE (email)
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_student_course_sem UNIQUE (student_id, course_code, semester)
);

-- Testing:
INSERT INTO users VALUES (1, 'student_a', 'a@mail.com', NOW());
-- Inserting a duplicate username or email will throw an error:
-- INSERT INTO users VALUES (2, 'student_a', 'b@mail.com', NOW());


--------------------------------------------------------------------------------
-- Part 4: PRIMARY KEY Constraints
--------------------------------------------------------------------------------

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'Almaty');
INSERT INTO departments VALUES (2, 'IT', 'Astana');
INSERT INTO departments VALUES (3, 'Finance', 'Shymkent');

-- Unsuccessful attempts:
-- INSERT INTO departments VALUES (1, 'Marketing', 'Almaty'); -- Error: Primary key duplication
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Almaty'); -- Error: Primary key cannot be NULL


-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 PRIMARY KEY (student_id, course_id)
);


--------------------------------------------------------------------------------
-- Part 5: FOREIGN KEY Constraints
--------------------------------------------------------------------------------

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id),
                                hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Aigul', 1, '2026-01-15');
-- Unsuccessful attempt (department with ID 999 does not exist in departments table):
-- INSERT INTO employees_dept VALUES (2, 'Damir', 999, '2026-02-01');


-- Task 5.2: Multiple Foreign Keys (Library System Schema)
CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);


-- Task 5.3: ON DELETE Behaviors (RESTRICT and CASCADE)
CREATE TABLE categories (
                            category_id INTEGER PRIMARY KEY,
                            category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
                             product_id INTEGER PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
                        order_id INTEGER PRIMARY KEY,
                        order_date DATE NOT NULL
);

CREATE TABLE order_items (
                             item_id INTEGER PRIMARY KEY,
                             order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
                             product_id INTEGER REFERENCES products_fk(product_id),
                             quantity INTEGER CHECK (quantity > 0)
);


--------------------------------------------------------------------------------
-- Part 6: Practical Application — E-commerce Database Design
--------------------------------------------------------------------------------

-- Creating e-commerce schema tables
CREATE TABLE ecommerce_customers (
                                     customer_id INTEGER PRIMARY KEY,
                                     name TEXT NOT NULL,
                                     email TEXT UNIQUE NOT NULL,
                                     phone TEXT,
                                     registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
                                    product_id INTEGER PRIMARY KEY,
                                    name TEXT NOT NULL,
                                    description TEXT,
                                    price NUMERIC NOT NULL CHECK (price >= 0),
                                    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
                                  order_id INTEGER PRIMARY KEY,
                                  customer_id INTEGER REFERENCES ecommerce_customers(customer_id) ON DELETE CASCADE,
                                  order_date DATE NOT NULL,
                                  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
                                  status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE ecommerce_order_details (
                                         order_detail_id INTEGER PRIMARY KEY,
                                         order_id INTEGER REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
                                         product_id INTEGER REFERENCES ecommerce_products(product_id) ON DELETE RESTRICT,
                                         quantity INTEGER NOT NULL CHECK (quantity > 0),
                                         unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Sample Data for E-commerce System
INSERT INTO ecommerce_customers VALUES
                                    (1, 'Aliya Nurlanova', 'aliya@mail.com', '+77011112233', '2026-01-10'),
                                    (2, 'Timur Kassymov', 'timur@mail.com', '+77022223344', '2026-02-12'),
                                    (3, 'Dinara Serikova', 'dinara@mail.com', '+77053334455', '2026-03-05'),
                                    (4, 'Yржан Omarov', 'erjan@mail.com', '+77074445566', '2026-04-20'),
                                    (5, 'Tomiris Khamit', 'tomiris@mail.com', '+77085556677', '2026-05-01');

INSERT INTO ecommerce_products VALUES
                                   (1, 'Smartphone', 'Next-generation mobile phone', 250000.00, 15),
                                   (2, 'Wireless Headphones', 'Bluetooth headphones with noise cancellation', 45000.00, 30),
                                   (3, 'E-Reader', '6-inch E-Ink display', 70000.00, 10),
                                   (4, 'Laptop Backpack', 'Water-resistant laptop backpack', 20000.00, 50),
                                   (5, 'Desk Lamp', 'LED adjustable brightness desk lamp', 12000.00, 25);

INSERT INTO ecommerce_orders VALUES
                                 (1, 1, '2026-06-01', 295000.00, 'delivered'),
                                 (2, 2, '2026-06-05', 45000.00, 'shipped'),
                                 (3, 3, '2026-06-10', 70000.00, 'processing'),
                                 (4, 4, '2026-06-15', 32000.00, 'pending'),
                                 (5, 5, '2026-06-20', 250000.00, 'cancelled');

INSERT INTO ecommerce_order_details VALUES
                                        (1, 1, 1, 1, 250000.00),
                                        (2, 1, 2, 1, 45000.00),
                                        (3, 2, 2, 1, 45000.00),
                                        (4, 3, 3, 1, 70000.00),
                                        (5, 4, 4, 1, 20000.00),
                                        (6, 4, 5, 1, 12000.00),
                                        (7, 5, 1, 1, 250000.00);