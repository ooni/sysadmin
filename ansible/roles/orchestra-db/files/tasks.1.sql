CREATE TYPE TASK_STATE AS ENUM ('ready', 'notified', 'accepted', 'rejected', 'done');
CREATE TABLE IF NOT EXISTS tasks
(
    id UUID NOT NULL,
    probe_id UUID,
    job_id UUID,
    test_name VARCHAR,
    arguments JSONB,
    state TASK_STATE,
    progress INT,
    creation_time TIMESTAMP WITH TIME ZONE,
    notification_time TIMESTAMP WITH TIME ZONE,
    accept_time TIMESTAMP WITH TIME ZONE,
    done_time TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
)
