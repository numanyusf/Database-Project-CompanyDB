-- Active: 1703100583880@@127.0.0.1@5432@companydb@public

-- retrieve the team names and their corresponding project count.
SELECT
    teams.team_name,
    COUNT(team_projects.project_id) AS project_count
FROM
    teams
LEFT JOIN
    team_projects ON teams.team_id = team_projects.team_id
GROUP BY
    teams.team_name;

-- Retrieve the projects managed by the managers whose first name starts with "J" or "D".
SELECT
    employees.manager_name,
    projects.name AS project_name
FROM 
    employees
INNER JOIN 
    teams ON employees.team_name = teams.team_name
INNER JOIN 
    team_projects ON teams.team_id = team_projects.team_id
INNER JOIN 
    projects ON team_projects.project_id = projects.project_id
WHERE 
    employees.manager_name LIKE 'J%'
    OR employees.manager_name LIKE 'D%'
GROUP BY
    employees.manager_name,
    projects.name;

-- Retrieve all the employees (both directly and indirectly) working under Michael Williams.    
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        employees.employee_id,
        CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name,
        employees.manager_name
    FROM
        employees
    WHERE
        employees.manager_name = 'Michael Williams'
    
    UNION ALL
    
    SELECT
        employees.employee_id,
        CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name,
        employees.manager_name
    FROM
        employees
    INNER JOIN
        EmployeeHierarchy ON employees.manager_name = EmployeeHierarchy.employee_name
)
SELECT
    *
FROM
    EmployeeHierarchy;

-- Retrieve the average hourly salary for each title.
SELECT
    title,
    ROUND(AVG(hourly_salary), 2) AS average_hourly_salary
FROM
    employees
GROUP BY
    title;

-- Retrieve the employees who have a higher hourly salary than their respective team's average hourly salary.
SELECT
    employees.employee_id,
    employees.first_name,
    employees.last_name,
    employees.hourly_salary,
    teams.team_name,
    ROUND(AVG(e2.hourly_salary), 2) AS team_avg_hourly_salary
FROM
    employees
JOIN
    teams ON employees.team_name = teams.team_name
JOIN
    employees e2 ON employees.team_name = e2.team_name
GROUP BY
    employees.employee_id, employees.first_name, employees.last_name, employees.hourly_salary, teams.team_name
HAVING
    employees.hourly_salary > AVG(e2.hourly_salary);

-- Retrieve the projects that have more than 3 teams assigned to them.
SELECT
    projects.project_id,
    projects.name AS project_name,
    COUNT(teams.team_id) AS teams_assigned
FROM
    projects
JOIN
    team_projects ON projects.project_id = team_projects.project_id
JOIN
    teams ON team_projects.team_id = teams.team_id
GROUP BY
    projects.project_id, projects.name
HAVING
    COUNT(teams.team_id) > 3;

-- Retrieve the total hourly salary expense for each team.
SELECT
    teams.team_id,
    teams.team_name,
    SUM(employees.hourly_salary) AS total_hourly_salary_expense
FROM
    teams
JOIN
    employees ON teams.team_name = employees.team_name
GROUP BY
    teams.team_id, teams.team_name
ORDER BY
    total_hourly_salary_expense DESC;