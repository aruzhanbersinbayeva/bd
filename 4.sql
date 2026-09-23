-- Part 4 : Table Relationships and Management
-- Task 4.1 : Additional Supporting Tables
-- 1. Table : departments
CREATE TABLE departments (
                             department_id SERIAL PRIMARY KEY,
                             department_name VARCHAR(100),
                             department_code CHAR(5),
                             building VARCHAR(50),
                             phone VARCHAR(15),
                             budget NUMERIC(12, 2),
                             established_year INTEGER
);

-- 2. Table : library_books
CREATE TABLE library_books (
                               book_id SERIAL PRIMARY KEY,
                               isbn CHAR(13),
                               title VARCHAR(200),
                               author VARCHAR(100),
                               publisher VARCHAR(100),
                               publication_date DATE,
                               price NUMERIC(10, 2),
                               is_available BOOLEAN,
                               acquisition_timestamp TIMESTAMP
);

-- 3. Table : student_book_loans
CREATE TABLE student_book_loans (
                                    loan_id SERIAL PRIMARY KEY,
                                    student_id INTEGER,
                                    book_id INTEGER,
                                    loan_date DATE,
                                    due_date DATE,
                                    return_date DATE,
                                    fine_amount NUMERIC(10, 2),
                                    loan_status VARCHAR(20)
);

-- Task 4.2 : Table Modifications for Integration

-- 1. Add foreign key columns (just adding columns)
ALTER TABLE professors ADD COLUMN department_id INTEGER;
ALTER TABLE students ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses ADD COLUMN department_id INTEGER;

-- 2. Create lookup tables:

-- Table : grade_scale
CREATE TABLE grade_scale (
                             grade_id SERIAL PRIMARY KEY,
                             letter_grade CHAR(2),
                             min_percentage NUMERIC(4, 1),
                             max_percentage NUMERIC(4, 1),
                             gpa_points NUMERIC(3, 2)
);

-- Table : semester_calendar
CREATE TABLE semester_calendar (
                                   semester_id SERIAL PRIMARY KEY,
                                   semester_name VARCHAR(20),
                                   academic_year INTEGER,
                                   start_date DATE,
                                   end_date DATE,
                                   registration_deadline TIMESTAMPTZ,
                                   is_current BOOLEAN
);