-- Part 2 : Complex Table Creation
-- Task 2.1 : University Management System

-- 1. Table : students
CREATE TABLE students (
                          student_id SERIAL PRIMARY KEY,
                          first_name VARCHAR(50),
                          last_name VARCHAR(50),
                          email VARCHAR(100),
                          phone CHAR(15),
                          date_of_birth DATE,
                          enrollment_date DATE,
                          gpa NUMERIC(3, 2),
                          is_active BOOLEAN,
                          graduation_year SMALLINT
);

-- 2. Table : professors
CREATE TABLE professors (
                            professor_id SERIAL PRIMARY KEY,
                            first_name VARCHAR(50),
                            last_name VARCHAR(50),
                            email VARCHAR(100),
                            office_number VARCHAR(20),
                            hire_date DATE,
                            salary NUMERIC(12, 2),
                            is_tenured BOOLEAN,
                            years_experience INTEGER
);

-- 3. Table : courses
CREATE TABLE courses (
                         course_id SERIAL PRIMARY KEY,
                         course_code CHAR(8),
                         course_title VARCHAR(100),
                         description TEXT,
                         credits SMALLINT,
                         max_enrollment INTEGER,
                         course_fee NUMERIC(10, 2),
                         is_online BOOLEAN,
                         created_at TIMESTAMP
);


-- Task 2.2 : Time-based and Specialized Tables

CREATE TABLE class_schedule (
                                schedule_id SERIAL PRIMARY KEY,
                                course_id INTEGER,
                                professor_id INTEGER,
                                classroom VARCHAR(20),
                                class_date DATE,
                                start_time TIME,
                                end_time TIME,
                                duration INTERVAL
);

CREATE TABLE student_records (
                                 record_id SERIAL PRIMARY KEY,
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 semester VARCHAR(20),
                                 year INTEGER,
                                 grade CHAR(2),
                                 attendance_percentage NUMERIC(4, 1),
                                 submission_timestamp TIMESTAMPTZ,
                                 last_updated TIMESTAMPTZ
);