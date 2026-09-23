-- Part 5 : Table Deletion and Cleanup
-- Task 5.1 : Conditional Table Operations
-- 1. Drop tables if they exist:
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

-- 2. Recreate grade_scale table with description column:
CREATE TABLE grade_scale (
                             grade_id SERIAL PRIMARY KEY,
                             letter_grade CHAR(2),
                             min_percentage NUMERIC(4, 1),
                             max_percentage NUMERIC(4, 1),
                             gpa_points NUMERIC(3, 2),
                             description TEXT
);

-- 3. Drop and recreate with CASCADE:
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
                                   semester_id SERIAL PRIMARY KEY,
                                   semester_name VARCHAR(20),
                                   academic_year INTEGER,
                                   start_date DATE,
                                   end_date DATE,
                                   registration_deadline TIMESTAMPTZ,
                                   is_current BOOLEAN
);


-- Task 5.2 : Database Cleanup
-- 1. Database operations:
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup TEMPLATE university_main;
