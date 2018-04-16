CREATE TYPE ACCOUNT_ROLE AS ENUM ('device', 'admin', 'user');
CREATE TABLE IF NOT EXISTS accounts
(
    id SERIAL PRIMARY KEY NOT NULL,
    username VARCHAR,
    password_hash VARCHAR,
    salt VARCHAR,
    last_access TIMESTAMP WITH TIME ZONE,
    role ACCOUNT_ROLE
);
CREATE UNIQUE INDEX IF NOT EXISTS accounts_id_uindex ON accounts (id);
