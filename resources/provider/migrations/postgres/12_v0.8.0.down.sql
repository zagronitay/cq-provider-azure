-- Autogenerated by migration tool on 2022-03-07 15:57:32
-- CHANGEME: Verify or edit this file before proceeding

-- Resource: account.locations
DROP TABLE IF EXISTS azure_account_locations;

-- Resource: eventhub.namespaces
ALTER TABLE IF EXISTS "azure_eventhub_namespaces" DROP COLUMN IF EXISTS "network_rule_set";

-- Resource: search.services
DROP TABLE IF EXISTS azure_search_service_private_endpoint_connections;
DROP TABLE IF EXISTS azure_search_service_shared_private_link_resources;
DROP TABLE IF EXISTS azure_search_services;

-- Resource: security.assessments
DROP TABLE IF EXISTS azure_security_assessments;

-- Resource: sql.servers
ALTER TABLE IF EXISTS "azure_sql_databases" DROP COLUMN IF EXISTS "backup_long_term_retention_policy";

-- Resource: streamanalytics.jobs
DROP TABLE IF EXISTS azure_streamanalytics_jobs;
