CREATE TABLE IF NOT EXISTS probe_updates
(
    id UUID PRIMARY KEY NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE,
    probe_cc VARCHAR(2),
    probe_asn VARCHAR(30),
    platform VARCHAR,
    software_name VARCHAR(100),
    software_version VARCHAR,
    supported_tests VARCHAR[],
    network_type VARCHAR,
    available_bandwidth VARCHAR,
    token VARCHAR,
    probe_family VARCHAR,
    probe_id VARCHAR,
    update_type VARCHAR,
    client_id UUID
);
