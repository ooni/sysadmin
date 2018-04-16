CREATE TABLE IF NOT EXISTS active_probes
(
    id UUID PRIMARY KEY NOT NULL,
    creation_time TIMESTAMP WITH TIME ZONE,
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
    last_updated TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX IF NOT EXISTS registered_probes_id_uindex ON active_probes (id);
