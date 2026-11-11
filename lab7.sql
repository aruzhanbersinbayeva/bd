
-- =====================================================
-- LABORATORY WORK 7: SQL VIEWS AND ROLES
-- PostgreSQL
-- =====================================================

-- PART 1. DATABASE SETUP
-- Use the same database from Laboratory Work 6.
-- Required tables: employees, departments, projects.

-- Create table: employees
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000)
;
-- =====================================================
-- PART 2. CREATING BASIC VIEWS
-- =====================================================

-- Exercise 2.1: Simple View Creation

CREATE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 2.2: View with Aggregation

CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3: View with Multiple Joins

CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS team_size
FROM projects p
         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id;

SELECT * FROM project_overview;


-- Exercise 2.4: View with Filtering

CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;


-- =====================================================
-- PART 3. MODIFYING AND MANAGING VIEWS
-- =====================================================

-- Exercise 3.1: Replace a View

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
        END AS salary_grade
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 3.2: Rename a View

ALTER VIEW high_earners
    RENAME TO top_performers;

SELECT * FROM top_performers;


-- Exercise 3.3: Create and Drop a View

CREATE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;

DROP VIEW temp_view;


-- =====================================================
-- PART 4. UPDATABLE VIEWS
-- =====================================================

-- Exercise 4.1: Create an Updatable View

CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

SELECT * FROM employee_salaries;


-- Exercise 4.2: Update Through a View

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT *
FROM employees
WHERE emp_name = 'John Smith';


-- Exercise 4.3: Insert Through a View

INSERT INTO employee_salaries
(emp_id, emp_name, dept_id, salary)
VALUES
    (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees;


-- Exercise 4.4: View with CHECK OPTION

CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;

SELECT * FROM it_employees;

-- EXPECTED ERROR: Run separately to test CHECK OPTION.
-- INSERT INTO it_employees
-- (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);


-- =====================================================
-- PART 5. MATERIALIZED VIEWS
-- =====================================================

-- Exercise 5.1: Create a Materialized View

CREATE MATERIALIZED VIEW dept_summary_mv AS

WITH employee_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        COALESCE(SUM(salary), 0) AS total_salaries
    FROM employees
    GROUP BY dept_id
),

     project_stats AS (
         SELECT
             dept_id,
             COUNT(*) AS total_projects,
             COALESCE(SUM(budget), 0) AS total_project_budget
         FROM projects
         GROUP BY dept_id
     )

SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
         LEFT JOIN employee_stats e
                   ON d.dept_id = e.dept_id
         LEFT JOIN project_stats p
                   ON d.dept_id = p.dept_id
WITH DATA;

SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;


-- Exercise 5.2: Refresh Materialized View

INSERT INTO employees
(emp_id, emp_name, dept_id, salary)
VALUES
    (8, 'Charlie Brown', 101, 54000);

-- Check before refresh

SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;

-- Refresh

REFRESH MATERIALIZED VIEW dept_summary_mv;

-- Check after refresh

SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;


-- Exercise 5.3: Concurrent Refresh

CREATE UNIQUE INDEX dept_summary_mv_idx
    ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;


-- Exercise 5.4: Materialized View with NO DATA

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS employee_count
FROM projects p
         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id
WITH NO DATA;

-- EXPECTED ERROR: Run separately before refreshing.
-- SELECT * FROM project_stats_mv;

-- Fix the error

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;


-- =====================================================
-- PART 6. DATABASE ROLES
-- =====================================================

-- Exercise 6.1: Create Basic Roles

CREATE ROLE analyst NOLOGIN;

CREATE ROLE data_viewer
    WITH LOGIN PASSWORD 'viewer123';

CREATE USER report_user
    WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';


-- Exercise 6.2: Role with Specific Attributes

CREATE ROLE db_creator
    WITH LOGIN CREATEDB PASSWORD 'creator789';

CREATE ROLE user_manager
    WITH LOGIN CREATEROLE PASSWORD 'manager101';

CREATE ROLE admin_user
    WITH LOGIN SUPERUSER PASSWORD 'admin999';


-- Exercise 6.3: Grant Privileges to Roles

GRANT USAGE ON SCHEMA public
    TO analyst, data_viewer, report_user;

GRANT SELECT ON employees, departments, projects
    TO analyst;

GRANT ALL PRIVILEGES ON employee_details
    TO data_viewer;

GRANT SELECT, INSERT ON employees
    TO report_user;


-- Exercise 6.4: Create Group Roles

CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE ROLE hr_user1
    WITH LOGIN PASSWORD 'hr001';

CREATE ROLE hr_user2
    WITH LOGIN PASSWORD 'hr002';

CREATE ROLE finance_user1
    WITH LOGIN PASSWORD 'fin001';

GRANT USAGE ON SCHEMA public
    TO hr_team, finance_team, it_team;

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;

GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees
    TO hr_team;

GRANT SELECT ON dept_statistics
    TO finance_team;


-- Exercise 6.5: Revoke Privileges

REVOKE UPDATE ON employees
    FROM hr_team;

REVOKE hr_team FROM hr_user2;

REVOKE ALL PRIVILEGES ON employee_details
    FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes

ALTER ROLE analyst
    WITH LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager
    WITH SUPERUSER;

ALTER ROLE analyst
    PASSWORD NULL;

ALTER ROLE data_viewer
    CONNECTION LIMIT 5;


-- =====================================================
-- PART 7. ADVANCED ROLE MANAGEMENT
-- =====================================================

-- Exercise 7.1: Role Hierarchies

CREATE ROLE read_only NOLOGIN;

GRANT USAGE ON SCHEMA public
    TO read_only;

GRANT SELECT ON ALL TABLES IN SCHEMA public
    TO read_only;

CREATE ROLE junior_analyst
    WITH LOGIN PASSWORD 'junior123';

CREATE ROLE senior_analyst
    WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;

GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees
    TO senior_analyst;


-- Exercise 7.2: Object Ownership

CREATE ROLE project_manager
    WITH LOGIN PASSWORD 'pm123';

GRANT USAGE, CREATE ON SCHEMA public
    TO project_manager;

ALTER VIEW dept_statistics
    OWNER TO project_manager;

ALTER TABLE projects
    OWNER TO project_manager;

SELECT
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public';


-- Exercise 7.3: Reassign and Drop Roles

CREATE ROLE temp_owner
    WITH LOGIN;

CREATE TABLE temp_table (
                            id INT
);

ALTER TABLE temp_table
    OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;


-- Exercise 7.4: Role-Specific Views

CREATE VIEW hr_employee_view AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view
    TO hr_team;


CREATE VIEW finance_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees;

GRANT SELECT ON finance_employee_view
    TO finance_team;


-- =====================================================
-- PART 8. PRACTICAL SCENARIOS
-- =====================================================

-- Exercise 8.1: Department Dashboard View

CREATE VIEW dept_dashboard AS

WITH employee_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary), 2) AS average_salary
    FROM employees
    GROUP BY dept_id
),

     project_stats AS (
         SELECT
             dept_id,
             COUNT(*) AS active_projects,
             SUM(budget) AS total_project_budget
         FROM projects
         GROUP BY dept_id
     )

SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    COALESCE(e.average_salary, 0) AS average_salary,
    COALESCE(p.active_projects, 0) AS active_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget,

    ROUND(
            COALESCE(p.total_project_budget, 0)::NUMERIC
                / NULLIF(COALESCE(e.employee_count, 0), 0),
            2
    ) AS budget_per_employee

FROM departments d

         LEFT JOIN employee_stats e
                   ON d.dept_id = e.dept_id

         LEFT JOIN project_stats p
                   ON d.dept_id = p.dept_id;

SELECT * FROM dept_dashboard;


-- Exercise 8.2: Audit View

ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,

    CASE
        WHEN p.budget > 150000
            THEN 'Critical Review Required'

        WHEN p.budget > 100000
            THEN 'Management Approval Needed'

        ELSE 'Standard Process'
        END AS approval_status

FROM projects p

         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id

WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;


-- Exercise 8.3: Create Access Control System

-- Level 1: Viewer Role

CREATE ROLE viewer_role NOLOGIN;

GRANT USAGE ON SCHEMA public
    TO viewer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public
    TO viewer_role;


-- Level 2: Entry Role

CREATE ROLE entry_role NOLOGIN;

GRANT viewer_role TO entry_role;

GRANT INSERT ON employees, projects
    TO entry_role;


-- Level 3: Analyst Role

CREATE ROLE analyst_role NOLOGIN;

GRANT entry_role TO analyst_role;

GRANT UPDATE ON employees, projects
    TO analyst_role;


-- Level 4: Manager Role

CREATE ROLE manager_role NOLOGIN;

GRANT analyst_role TO manager_role;

GRANT DELETE ON employees, projects
    TO manager_role;


-- Create Users

CREATE ROLE alice
    WITH LOGIN PASSWORD 'alice123';

CREATE ROLE bob
    WITH LOGIN PASSWORD 'bob123';

CREATE ROLE charlie
    WITH LOGIN PASSWORD 'charlie123';


-- Assign Users to Roles

GRANT viewer_role TO alice;

GRANT analyst_role TO bob;

GRANT manager_role TO charlie;


-- =====================================================
-- FINAL CHECKS
-- =====================================================

-- Check all views

SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;


-- Check materialized views

SELECT matviewname
FROM pg_matviews
WHERE schemaname = 'public';


-- Check roles

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;


-- Check role memberships

SELECT
    r.rolname AS role_name,
    m.rolname AS member_name
FROM pg_auth_members am
         JOIN pg_roles r
              ON am.roleid = r.oid
         JOIN pg_roles m
              ON am.member = m.oid
ORDER BY r.rolname;


