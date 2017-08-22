CREATE TABLE IF NOT EXISTS jobs
(
    id UUID PRIMARY KEY NOT NULL,
    comment VARCHAR,
    creation_time TIMESTAMP WITH TIME ZONE,
    schedule VARCHAR,
    delay INT,
    target_countries VARCHAR(2) [],
    target_platforms VARCHAR(10) [],
    task_test_name VARCHAR,
    task_arguments JSONB,
    times_run INT,
    next_run_at TIME WITH TIME ZONE
);
