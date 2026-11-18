--1
CREATE TABLE IF NOT EXISTS departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS  employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(100),
                           dept_id INT,
                           salary DECIMAL(10,2),
                           FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE IF NOT EXISTs projects (
                          proj_id INT PRIMARY KEY,
                          proj_name VARCHAR(100),
                          budget DECIMAL(12,2),
                          dept_id INT,
                          FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
                            (101, 'IT', 'Building A'),
                            (102, 'HR', 'Building B'),
                            (103, 'Operations', 'Building C');
INSERT INTO employees VALUES
                          (1, 'John Smith', 101, 50000),
                          (2, 'Jane Doe', 101, 55000),
                          (3, 'Mike Johnson', 102, 48000),
                          (4, 'Sarah Williams', 102, 52000),
                          (5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
                         (201, 'Website Redesign', 75000, 101),
                         (202, 'Database Migration', 120000, 101),
                         (203, 'HR System Upgrade', 50000, 102);


--Part 2: Creating Basic Indexes
--2.1
CREATE INDEX emp_salary_idx
ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
-- How many indexes exist on the employees table?
--2
--emp_salary_idx, employees_pkey


--2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);


SELECT * FROM employees WHERE dept_id = 101;

--Why is it beneficial to index foreign key columns?
--An index on a foreign key column improves JOIN performance and speeds
-- up searching and filtering records. It also helps PostgreSQL find related
-- rows faster when checking references.

--2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--List all the indexes you see. Which ones were created automatically?
--automatically
--departments_pkey, projects_pkey, employees_pkey
--custom
--emp_salary_idx, emp_dept_idx

--Part 3: Multicolumn Indexes
--3.1
CREATE INDEX emp_dept_salary_idx
ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

--Would this index be useful for a query that only filters by salary (withoutdept_id)? Why or why not
--No, because dept_id is the first column in the index.

--Exercise 3.2: Understanding Column Order

CREATE INDEX emp_salary_dept_idx
    ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;

--Does the order of columns in a multicolumn index matter? Explain
--in PostgreSql the order of columns matter uses the leftmost columns
--An index on (dept_id, salary) is useful for queries filtering by dept_id first,
-- while an index on (salary, dept_id) is useful for queries filtering by salary first.

--Part 4: Unique Indexes
--4.1
ALTER TABLE employees
    ADD COLUMN email VARCHAR(100);

UPDATE employees
SET email = 'john.smith@company.com'
WHERE emp_id = 1;


UPDATE employees
SET email = 'jane.doe@company.com'
WHERE emp_id = 2;


UPDATE employees
SET email = 'mike.johnson@company.com'
WHERE emp_id = 3;


UPDATE employees
SET email = 'sarah.williams@company.com'
WHERE emp_id = 4;


UPDATE employees
SET email = 'tom.brown@company.com'
WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx
    ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

--What error message did you receive?
--it shows error duplicate key, bacause email name repeated


--4.2
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

--Did PostgreSQL automatically create an index? What type of index?
--yes,postgresql automatically creates a unique b-tree


--Part 5: Indexes and Sorting
--5.1
CREATE INDEX emp_salary_desc_idx
    ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

--How does this index help with ORDER BY queries?


--5.2
CREATE INDEX proj_budget_nulls_first_idx
    ON projects(budget NULLS FIRST );

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;




--Part 6: Indexes on Expressions
--6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

--Without an expression index, PostgreSQL would generally perform a sequential
-- scan and apply the LOWER() function to each employee name to find matching records.

--6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


--Part 7: Managing Indexes
--7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--7.2
DROP INDEX emp_salary_dept_idx;
--Why might you want to drop an index?
--if we dont use index its better to delete

--7.3
REINDEX INDEX employees_salary_index;
--When is REINDEX useful?
--REINDEX is useful when an index becomes bloated or corrupted.
-- It rebuilds the index and can improve its structure and performance



--Part 8: Practical Scenarios
--8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

--8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
    WHERE budget > 80000;

--What's the advantage of a partial index compared to a regular index?
--A partial index stores entries only for rows that satisfy a specific condition.
-- It uses less storage space and can improve query performance for frequently accessed subsets of data.


-- 8.3
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;


-- PART 9. INDEX TYPES COMPARISON

-- 9.1

CREATE INDEX IF NOT EXISTS dept_name_hash_idx
    ON departments USING HASH (dept_name);

-- Test the hash index
SELECT *
FROM departments
WHERE dept_name = 'IT';


--9.2

-- B-tree index
CREATE INDEX IF NOT EXISTS proj_name_btree_idx
    ON projects(proj_name);

-- Hash index
CREATE INDEX IF NOT EXISTS proj_name_hash_idx
    ON projects USING HASH (proj_name);

-- Equality search (B-tree and Hash can be used)
SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

-- Range search (B-tree can be used)
SELECT *
FROM projects
WHERE proj_name > 'Database';


-- PART 10. CLEANUP AND BEST PRACTICES

--10.1

SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(
            pg_relation_size(indexname::regclass)
    ) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


--10.2

DROP INDEX IF EXISTS proj_name_hash_idx;


--10.3

CREATE OR REPLACE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

-- Check the view
SELECT *
FROM index_documentation;

