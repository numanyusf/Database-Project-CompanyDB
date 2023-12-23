-- Active: 1703100583880@@127.0.0.1@5432@companydb@public


-- Create a function `track_working_hours(employee_id, project_id, total_hours)` to insert data into the hour_tracking table 
-- to track the working hours for each employee on specific projects. Make sure that data need to be validated before the insertion.
CREATE OR REPLACE FUNCTION track_working_hours(
    employee_id INT,
    project_id INT,
    total_hours DECIMAL
) RETURNS VOID AS $$
BEGIN
    -- check if the employee and project exist
    IF NOT EXISTS (SELECT 1 FROM employees WHERE e_id = employee_id) THEN
        RAISE EXCEPTION 'Employee with ID % does not exist', employee_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM projects WHERE p_id = project_id) THEN
        RAISE EXCEPTION 'Project with ID % does not exist', project_id;
    END IF;

    -- check if the total_hours value is valid
    IF total_hours < 0 THEN
        RAISE EXCEPTION 'Total hours cannot be negative';
    END IF;

    -- insert data into the hour_tracking table
    INSERT INTO hour_tracking (e_id, p_id, total_hours)
    VALUES (employee_id, project_id, total_hours);
END;
$$ LANGUAGE plpgsql;

-- data insertion into hour_tracking table
SELECT track_working_hours(20, 7, 40.5);
SELECT track_working_hours(23, 7, 32.25);
SELECT track_working_hours(12, 7, 22.75);


-- Create a function `create_project_with_teams` to create a project and assign teams to that project simultaneously.
CREATE OR REPLACE FUNCTION create_project_with_teams(
    project_name VARCHAR,
    client VARCHAR,
    start_date DATE,
    deadline DATE,
    team_ids INT[]
) RETURNS VOID AS $$
DECLARE
    new_project_id INT;
BEGIN
    -- insert data into the projects table
    INSERT INTO projects (name, client, start_date, deadline)
    VALUES (project_name, client, start_date, deadline)
    RETURNING project_id INTO new_project_id;

    -- check if the project was successfully created
    IF new_project_id IS NULL THEN
        RAISE EXCEPTION 'Failed to create the project';
    END IF;

    -- check if the array of team_ids is not empty
    IF array_length(team_ids, 1) IS NOT NULL THEN
        -- insert data into the team_projects table to assign teams to the project
        INSERT INTO team_projects (team_id, project_id)
        SELECT unnest(team_ids), new_project_id;
    
        -- check if teams were successfully assigned to the project
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Failed to assign teams to the project';
        END IF;
    ELSE
        RAISE EXCEPTION 'No teams specified for the project';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- data insertion into projects and team_projects tables
SELECT create_project_with_teams(
    'New Project',
    'Client XYZ',
    '2023-07-01',
    '2023-12-31',
    ARRAY[1, 2, 3]
);