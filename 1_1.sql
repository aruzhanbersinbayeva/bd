-- 1. Create database and tables
DROP DATABASE advanced_lab;
CREATE DATABASE advanced_lab;

DROP TABLE employees;
CREATE TABLE employees(
                          emp_id SERIAL PRIMARY KEY,
                          first_name VARCHAR,
                          last_name VARCHAR,
                          department VARCHAR,
                          salary INT,
                          hire_date DATE,
                          status VARCHAR DEFAULT 'Active'
);

DROP TABLE departments;
CREATE TABLE departments(
                            dept_id SERIAL PRIMARY KEY,
                            dept_name VARCHAR,
                            budget INT,
                            manager_id INT
);

DROP TABLE projects;
CREATE TABLE projects(
                         project_id SERIAL PRIMARY KEY,
                         project_name VARCHAR,
                         dept_id INT,
                         start_date DATE,
                         end_date DATE,
                         budget INT
);

INSERT INTO departments (dept_name, budget, manager_id) VALUES
        ('IT', 120000, 1),
        ('Sales', 80000, 2),
        ('HR', 50000, 3);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
        ('Alice', 'Smith', 'IT', 75000, '2019-03-15', 'Active'),
        ('Bob', 'Jones', 'Sales', 55000, '2021-06-01', 'Active'),
        ('Charlie', 'Brown', 'IT', 85000, '2018-01-10', 'Active'),
        ('Diana', 'Prince', 'Sales', 62000, '2019-11-20', 'Active'),
        ('Evan', 'Wright', 'HR', 45000, '2022-04-12', 'Inactive'),
        ('Frank', 'Miller', 'HR', 38000, '2023-05-01', 'Terminated');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
        ('Cloud Migration', 1, '2022-01-01', '2022-12-31', 60000),
        ('Sales Expansion', 2, '2023-02-01', '2023-11-30', 40000);

-- Part B: Advanced INSERT Operations

INSERT INTO employees(emp_id,first_name, last_name, department)
VALUES(101, 'Aidar', 'Nurlan', 'IT'),
      (102, 'Aigerim', 'Sarsen', 'HR');

INSERT INTO employees(emp_id,first_name, last_name, department, salary,hire_date, status)
VALUES(DEFAULT,'Dana', 'Kairat', 'Finance', DEFAULT, '2024-03-15', DEFAULT);


INSERT INTO departments (dept_name, budget, manager_id)
VALUES('Finance', 90000, NULL),
      ('Marketing', 70000, NULL),
      ('Legal', 60000, NULL);


INSERT INTO employees(first_name,last_name,department,hire_date,status)
VALUES('Ian','Malcolm','R&D',CURRENT_DATE,50000*1.1);

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0; -- Create empty matching structure

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';


-- Part C: Complex UPDATE Operations

--7. UPDATE with arithmetic expressions

UPDATE employees
SET salary=salary*1.10
WHERE;

--8. UPDATE with WHERE clause and multiple conditions

UPDATE employees
SET status='Senior'
WHERE salary>60000 and hire_date<'2020-01-01';

--9. UPDATE using CASE expression

UPDATE employees
SET department=CASE
    WHEN salary>80000 THEN 'Management'
    WHEN salary>50000 and salary<80000 THEN 'Senior'
    ELSE 'Junior'
END;

--10. UPDATE with DEFAULT

UPDATE employees
SET department=DEFAULT
WHERE status='Inactive';

-- 11. UPDATE with subquery

UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

--12. UPDATE multiple columns

UPDATE employees
SET salary=salary*1.15,
    status='Promoted'
WHERE department ='Sales';

--Part D: Advanced DELETE Operations

--13. DELETE with simple WHERE condition

DELETE FROM employees
WHERE status='Terminated';


--14. DELETE with complex WHERE clause

DELETE FROM employees
WHERE salary<40000 AND hire_date >'2023-01-01' AND department IS NULL;

--15. DELETE with subquery

DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);


--16. DELETE with RETURNING clause

DELETE FROM projects
WHERE end_date<'2023-01-01'
RETURNING *;

--Part E: Operations with NULL Values

--17. INSERT with NULL values

INSERT INTO employees(first_name,last_name, salary, department)
VALUES('Qairat','Qui',NULL,NULL);
INSERT INTO departments (dept_name, budget, manager_id) VALUES
        ('IT', 120000, 1),
        ('Sales', 80000, 2),
        ('HR', 50000, 3);
--18. UPDATE NULL handling

UPDATE employees
WHERE salary IS NULL OR department IS NULL;


-- ============================================================================
-- Part F: RETURNING Clause Operations
-- ============================================================================

-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Karen', 'Page', 'Legal', 65000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- ============================================================================
-- Part G: Advanced DML Patterns
-- ============================================================================

-- 23. Conditional INSERT using WHERE NOT EXISTS
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Luke', 'Cage', 'Security', 55000
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Luke' AND last_name = 'Cage'
);

-- 24. UPDATE with JOIN logic using subqueries
UPDATE employees e
SET salary = CASE
                 WHEN (
                          SELECT d.budget
                          FROM departments d
                          WHERE d.dept_name = e.department
                      ) > 100000 THEN e.salary * 1.10
                 ELSE e.salary * 1.05
    END
WHERE e.department IS NOT NULL;

-- 25. Bulk operations
-- Step A: Bulk Insert
INSERT INTO employees (first_name, last_name, department, salary) VALUES
            ('User1', 'Test', 'IT', 50000),
            ('User2', 'Test', 'IT', 51000),
            ('User3', 'Test', 'Sales', 52000),
            ('User4', 'Test', 'Sales', 53000),
            ('User5', 'Test', 'HR', 54000);

-- Step B: Bulk Update on inserted rows
UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';

-- 26. Data migration simulation
-- Create archive table matching structure
CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

-- Move rows to archive via INSERT from SELECT
INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

-- Remove moved rows from original table
DELETE FROM employees
WHERE status = 'Inactive';

-- 27. Complex business logic
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
          SELECT COUNT(*)
          FROM employees e
                   JOIN departments d ON e.department = d.dept_name
          WHERE d.dept_id = p.dept_id
      ) > 3;


