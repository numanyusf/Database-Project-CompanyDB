-- Active: 1703100583880@@127.0.0.1@5432@companydb

-- creating database named companydb
CREATE DATABASE companydb;

-- switch to the schema
SET search_path TO public;

-- creating table titles
CREATE TABLE titles (
    title_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    title VARCHAR(20)
);

-- creating table teams
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    team_name VARCHAR(20),
    location VARCHAR(50)
);

-- creating table projects
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    name VARCHAR(25),
    client VARCHAR(25),
    start_date DATE,
    deadline DATE
);

-- creating table team_projects
CREATE TABLE team_projects (
    team_id INT,
    project_id INT,
    PRIMARY KEY (team_id, project_id),
    FOREIGN KEY (team_id) REFERENCES teams (team_id),
    FOREIGN KEY (project_id) REFERENCES projects (project_id)
); 

-- creating table employees
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    hourly_salary DECIMAL(5,2),
    title_id INT,
    manager_id INT NULL,
    team INT NULL,  
    FOREIGN KEY (title_id) REFERENCES titles (title_id),
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id),
    FOREIGN KEY (team) REFERENCES teams (team_id)
);

-- creating table hours_tracking
CREATE TABLE hour_tracking (
    employee_id INT,
    project_id INT,
    total_hours DECIMAL(10, 2),
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    FOREIGN KEY (project_id) REFERENCES projects (project_id)
);


-- inserting data into table titles
COPY titles (title)
FROM 'C:/Users/numan/Projects/Database-Project-CompanyDB/data/titles.csv' 
WITH (FORMAT csv, HEADER);

-- inserting data into table teams
COPY teams (team_name, location)
FROM 'C:/Users/numan/Projects/Database-Project-CompanyDB/data/teams.csv'
WITH (FORMAT csv, DELIMITER ',', HEADER);

-- inserting data into table projects
COPY projects (name, client, start_date, deadline)
FROM 'C:/Users/numan/Projects/Database-Project-CompanyDB/data/projects.csv'
WITH (FORMAT csv, DELIMITER ',', HEADER);

-- inserting data into table team_projects
COPY team_projects (team_id, project_id)
FROM 'C:/Users/numan/Projects/Database-Project-CompanyDB/data/team_project.csv'
WITH (FORMAT csv, DELIMITER ',', HEADER);

-- inserting data into table team_projects
COPY employees (first_name, last_name, hire_date, hourly_salary, title_id, manager_id, team)
FROM 'C:/Users/numan/Projects/Database-Project-CompanyDB/data/employees.csv'
WITH (FORMAT csv, DELIMITER ';', HEADER);


-- adding columns title, manager_name and team_name to employees
ALTER TABLE employees
ADD COLUMN title character varying,
ADD COLUMN manager_name character varying,
ADD COLUMN team_name character varying;


-- Update titles in the employees table
UPDATE employees
SET title = titles.title
FROM titles
WHERE employees.title_id = titles.title_id;

-- Update team names in the employees table
UPDATE employees
SET team_name = teams.team_name
FROM teams
WHERE employees.team = teams.team_id;

-- Update manager names in the employees table
UPDATE employees
SET manager_name = (SELECT first_name || ' ' || last_name
                   FROM employees AS manager
                   WHERE manager.employee_id = employees.manager_id);

-- dropping columns title, manager_name and team_name to employees
ALTER TABLE employees
DROP COLUMN title_id,
DROP COLUMN manager_id,
DROP COLUMN team;
