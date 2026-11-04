-- ============================================================
-- LABORATORY WORK 6: SQL JOINs
-- Database: PostgreSQL
-- ============================================================

-- PART 1. DATABASE SETUP
-- Drop existing tables so this file can be run again from scratch.
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;

-- Exercise 1.1: Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- Exercise 1.2: Insert sample data
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);


-- ============================================================
-- PART 2. CROSS JOIN EXERCISES
-- ============================================================

-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
-- Expected: 5 * 4 = 20 rows.

-- Exercise 2.2a: Comma notation (same result as CROSS JOIN)
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- Exercise 2.2b: INNER JOIN with TRUE (same result as CROSS JOIN)
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Every employee paired with every project
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;
-- Expected: 5 * 5 = 25 rows.


-- ============================================================
-- PART 3. INNER JOIN EXERCISES
-- ============================================================

-- Exercise 3.1: INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Expected: 4 rows. Tom Brown is excluded because dept_id is NULL.

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- USING displays the shared dept_id column only once.

-- Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- NATURAL JOIN automatically joins columns with the same names.

-- Exercise 3.4: Join employees, departments, and projects
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
-- Expected: 6 rows. Employees in IT are paired with both IT projects.


-- ============================================================
-- PART 4. LEFT JOIN EXERCISES
-- ============================================================

-- Exercise 4.1: All employees, including those without a department
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown is included; department columns are NULL.

-- Exercise 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- Exercise 4.3: Find employees without departments
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- Expected: Tom Brown.

-- Exercise 4.4: Count employees in every department, including zero
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
-- COUNT(e.emp_id) returns 0 for departments without employees.


-- ============================================================
-- PART 5. RIGHT JOIN EXERCISES
-- ============================================================

-- Exercise 5.1: All departments, including those without employees
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- Marketing appears with NULL employee name.

-- Exercise 5.2: Same result using LEFT JOIN (reverse table order)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Exercise 5.3: Find departments without employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- Expected: Marketing, Building D.


-- ============================================================
-- PART 6. FULL JOIN EXERCISES
-- ============================================================

-- Exercise 6.1: All employees and all departments
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown has no matching department.
-- Marketing has no matching employee.

-- Exercise 6.2: All departments and all projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
-- Marketing has no project; AI Research has no department.

-- Exercise 6.3: Find employees without departments and departments without employees
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


-- ============================================================
-- PART 7. ON vs WHERE
-- ============================================================

-- Exercise 7.1: Filter in ON clause with LEFT JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
   AND d.location = 'Building A';
-- All employees remain; only Building A departments can match.

-- Exercise 7.2: Filter in WHERE clause with LEFT JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Only employees whose matched department is in Building A remain.

-- Exercise 7.3a: INNER JOIN with filter in ON
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
   AND d.location = 'Building A';


UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Self JOIN: show employees and their managers
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Departments where average employee salary is above 50000
SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- Alternative Exercise 8.3: Actual correlated subquery version
SELECT
    d.dept_name,
    (
        SELECT AVG(e.salary)
        FROM employees e
        WHERE e.dept_id = d.dept_id
    ) AS avg_salary
FROM departments d
WHERE (
    SELECT AVG(e.salary)
    FROM employees e
    WHERE e.dept_id = d.dept_id
) > 50000;


-- ============================================================
-- ADDITIONAL CHALLENGES (OPTIONAL)
-- ============================================================

-- Challenge 1: Simulate FULL OUTER JOIN using LEFT JOIN and RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id

UNION

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Challenge 2: Employees in departments with more than one project
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
    HAVING COUNT(project_id) > 1
);

-- Challenge 3: Hierarchical organization using recursive CTE
-- Mike Johnson (emp_id = 3) is the top-level manager in this sample data.
WITH RECURSIVE organization AS (
    SELECT
        emp_id,
        emp_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        o.level + 1
    FROM employees e
    INNER JOIN organization o ON e.manager_id = o.emp_id
)
SELECT emp_name, manager_id, level
FROM organization
ORDER BY level, emp_id;

-- Challenge 4: All pairs of employees in the same department
SELECT
    e1.emp_name AS employee1,
